module aptos_escrow_addr::AptosEscrow {
    use std::signer;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::fungible_asset::{Self, Metadata, FungibleStore};
    use aptos_framework::primary_fungible_store;
    use std::vector;

    struct Offers has key {
        offers: vector<Object<Escrow>>,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Escrow has key {
        maker: address,
        fa_a: Object<Metadata>,
        fa_b: Object<Metadata>,
        receive: u64,
        store: Object<FungibleStore>,
        extend_ref: object::ExtendRef,
        delete_ref: object::DeleteRef,
    }

    const E_NOT_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;

    fun init_module(creator: &signer){
        move_to(creator, Offers {
            offers: vector::empty(),
        })
    }

    public entry fun make(
        user: &signer,
        fa_a: Object<Metadata>,
        fa_b: Object<Metadata>,
        deposit: u64,
        receive: u64
    ) acquires Offers {
        let user_address = signer::address_of(user);
        let constructor_ref = object::create_object(user_address);
        let object_signer = object::generate_signer(&constructor_ref);
        let balance = primary_fungible_store::balance(user_address, fa_a);
        assert!(balance >= deposit, EINSUFFICIENT_BALANCE);
        let fa = primary_fungible_store::withdraw(user, fa_a, deposit);
        let store = fungible_asset::create_store<Metadata>(&constructor_ref, fa_a);
        fungible_asset::deposit(store, fa);
        move_to(&object_signer, Escrow {
            maker: user_address,
            fa_a,
            fa_b,
            receive,
            store,
            extend_ref: object::generate_extend_ref(&constructor_ref),
            delete_ref: object::generate_delete_ref(&constructor_ref),
        });
        let object = object::object_from_constructor_ref<Escrow>(&constructor_ref);
        let offers = &mut borrow_global_mut<Offers>(@aptos_escrow_addr).offers;
        vector::push_back(offers, object);
    }

    public entry fun refund(
        user: &signer, 
        escrow: Object<Escrow>
    ) acquires Escrow, Offers {
        let user_address = signer::address_of(user);
        assert!(object::is_owner(escrow, user_address), E_NOT_OWNER);
        let escrow_address = object::object_address<Escrow>(&escrow);
        let Escrow {
            maker: _,
            fa_a,
            fa_b: _,
            receive: _,
            store,
            extend_ref,
            delete_ref
        } = move_from<Escrow>(escrow_address);
        let balance = fungible_asset::balance<FungibleStore>(store);
        let obj_signer = object::generate_signer_for_extending(&extend_ref);
        let fa = fungible_asset::withdraw<FungibleStore>(&obj_signer, store, balance);
        let user_primary_store = primary_fungible_store::ensure_primary_store_exists<Metadata>(user_address, fa_a);
        fungible_asset::deposit(user_primary_store, fa);
        object::delete(delete_ref);
        let make_offers = borrow_global_mut<Offers>(@aptos_escrow_addr);
        let (exists, i) = vector::index_of(&make_offers.offers, &escrow);
        if(exists == true){
            vector::remove(&mut make_offers.offers, i);
        }
    }

    public entry fun take(
        user: &signer,
        escrow: Object<Escrow>,
    ) acquires Escrow, Offers {
        let user_address = signer::address_of(user);
        let escrow_address = object::object_address<Escrow>(&escrow);
        let Escrow {
            maker,
            fa_a: metadata_a,
            fa_b: metadata_b,
            receive,
            store,
            extend_ref,
            delete_ref
        } = move_from<Escrow>(escrow_address);
        let balance = primary_fungible_store::balance(user_address, metadata_b);
        assert!(balance >= receive, EINSUFFICIENT_BALANCE);
        let obj_signer = object::generate_signer_for_extending(&extend_ref);
        let taker_primary_fungible_store = primary_fungible_store::ensure_primary_store_exists<Metadata>(user_address, metadata_a);
        let maker_primary_fungible_store = primary_fungible_store::ensure_primary_store_exists<Metadata>(maker, metadata_b);
        let balance = fungible_asset::balance<FungibleStore>(store);
        let fa_a = fungible_asset::withdraw<FungibleStore>(&obj_signer, store, balance); 
        let fa_b = primary_fungible_store::withdraw(user, metadata_b, receive);
        fungible_asset::deposit(taker_primary_fungible_store, fa_a);
        fungible_asset::deposit(maker_primary_fungible_store, fa_b);
        object::delete(delete_ref);
        let make_offers = borrow_global_mut<Offers>(@aptos_escrow_addr);
        let (exists, i) = vector::index_of(&make_offers.offers, &escrow);
        if(exists == true){
            vector::remove(&mut make_offers.offers, i);
        }
    }   

    #[view]
    public fun get_an_object_for_testing(idx: u64): Object<Escrow> acquires Offers {
        let offers = borrow_global<Offers>(@aptos_escrow_addr).offers;
        *vector::borrow(&offers, idx)
    }

    #[test_only]
    use std::string::utf8;

    #[test_only]
    use std::option;

    #[test_only]
    use aptos_framework::fungible_asset::{MintRef, TransferRef};

    #[test_only]
    fun create_fa(aptos_framework: &signer, symbol: vector<u8>): (Object<Metadata>, MintRef, TransferRef) {
        let constructor_ref = &object::create_named_object(aptos_framework, symbol);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(b"Test Coin"),
            utf8(symbol),
            8,
            utf8(b"https://avatars.githubusercontent.com/u/62602303"),
            utf8(b"https://github.com/ajaythxkur"),
        );
        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);
        let asset_address = object::create_object_address(&signer::address_of(aptos_framework), symbol);
        (object::address_to_object(asset_address), mint_ref, transfer_ref)
    }

    #[test_only]
    fun mint_fa(asset: Object<Metadata>, mint_ref: &MintRef, transfer_ref: &TransferRef, to: address, amount: u64){
        let fa = fungible_asset::mint(mint_ref, amount);
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        fungible_asset::deposit_with_ref(transfer_ref, to_wallet, fa);
    }   

    #[test(maker=@0xCAFE, taker=@0x123, aptos_framework=@aptos_escrow_addr)]
    fun test_make_refund_take(maker: &signer, taker: &signer, aptos_framework: &signer) acquires Offers, Escrow {
        init_module(aptos_framework);
        let (metadata_a, mint_ref_a, transfer_ref_a) = create_fa(aptos_framework, b"ASSET A");
        let (metadata_b, mint_ref_b, transfer_ref_b) = create_fa(aptos_framework, b"ASSET B");

        mint_fa(metadata_a, &mint_ref_a, &transfer_ref_a, signer::address_of(maker), 1_000_000_000); 

        mint_fa(metadata_b, &mint_ref_b, &transfer_ref_b, signer::address_of(taker), 10_000_000_000);
        make(maker, metadata_a, metadata_b, 1_000_000_000, 10_000_000_000);

        let object = get_an_object_for_testing(0);
        refund(maker, object);

        make(maker, metadata_a, metadata_b, 1_000_000_000, 10_000_000_000);
        let object = get_an_object_for_testing(0);

        take(taker, object);
    }

    #[test(maker=@0xCAFE, hacker=@0xBACE, aptos_framework=@aptos_escrow_addr)]
    #[expected_failure]
    fun test_not_object_owner(maker: &signer, hacker: &signer, aptos_framework: &signer) acquires Offers, Escrow {
        init_module(aptos_framework);
        let (metadata_a, mint_ref_a, transfer_ref_a) = create_fa(aptos_framework, b"ASSET A");
        let (metadata_b, _, _) = create_fa(aptos_framework, b"ASSET B");

        mint_fa(metadata_a, &mint_ref_a, &transfer_ref_a, signer::address_of(maker), 100); 
        make(maker, metadata_a, metadata_b, 100, 1000);

        let object = get_an_object_for_testing(0);
        refund(hacker, object);
    }

}