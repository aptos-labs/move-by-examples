module deployer::taxed_fa {
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset, FungibleStore };
    use aptos_framework::primary_fungible_store;
    use aptos_framework::dispatchable_fungible_asset;
    use aptos_framework::function_info;
    use std::signer;
    use std::option;
    use std::event;
    use std::string::{Self, utf8};
    use aptos_std::math64;


    /* Errors */
    /// The caller is unauthorized.
    const EUNAUTHORIZED: u64 = 1;
    /// The amount is too low, tax cannot be imposed.
    const ELOW_AMOUNT: u64 = 2;

    /* Constants */
    const ASSET_NAME: vector<u8> = b"Taxed Fungible Asset";
    const ASSET_SYMBOL: vector<u8> = b"TFA";
    const TAX_RATE: u64 = 10;
    const SCALE_FACTOR: u64 = 100;

    /* Resources */
    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Management has key {
        extend_ref: ExtendRef,
        mint_ref: MintRef,
        burn_ref: BurnRef,
        transfer_ref: TransferRef,
    }

    /* Events */
    #[event]
    struct Mint has drop, store {
        minter: address,
        to: address,
        amount: u64,
    }

    #[event]
    struct Burn has drop, store {
        minter: address,
        from: address,
        amount: u64,
    }

    /* View Functions */
    #[view]
    public fun metadata_address(): address {
        object::create_object_address(&@deployer, ASSET_SYMBOL)
    }

    #[view]
    public fun metadata(): Object<Metadata> {
        object::address_to_object(metadata_address())
    }

    #[view]
    public fun deployer_store(): Object<FungibleStore> {
        primary_fungible_store::ensure_primary_store_exists(@deployer, metadata())
    }

    /* Initialization - Asset Creation, Register Dispatch Functions */
    fun init_module(deployer: &signer) {
        // Create the fungible asset metadata object. 
        let constructor_ref = &object::create_named_object(deployer, ASSET_SYMBOL);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(ASSET_NAME), 
            utf8(ASSET_SYMBOL), 
            8, 
            utf8(b"http://example.com/favicon.ico"), 
            utf8(b"http://example.com"), 
        );

        // Generate a signer for the asset metadata object. 
        let metadata_object_signer = &object::generate_signer(constructor_ref);

        // Generate asset management refs and move to the metadata object.
        move_to(metadata_object_signer, Management {
            extend_ref: object::generate_extend_ref(constructor_ref),
            mint_ref: fungible_asset::generate_mint_ref(constructor_ref),
            burn_ref: fungible_asset::generate_burn_ref(constructor_ref),
            transfer_ref: fungible_asset::generate_transfer_ref(constructor_ref),
        });

        // Override the withdraw function.
        // This ensures all transfer will call the withdraw function in this module and impose a tax.
        let withdraw = function_info::new_function_info(
            deployer,
            string::utf8(b"taxed_fa"),
            string::utf8(b"withdraw"),
        );
        dispatchable_fungible_asset::register_dispatch_functions(
            constructor_ref,
            option::some(withdraw),
            option::none(),
            option::none(),
        );       
    }

    /* Dispatchable Hooks */
    /// Withdraw function override to impose tax on operation.
    public fun withdraw<T: key>(
        store: Object<T>,
        amount: u64,
        transfer_ref: &TransferRef,
    ): FungibleAsset {
        assert!(amount > 10, ELOW_AMOUNT);
        // Calculate a 10% tax on the amount. 
        // Amount has to be greater than 10 to impose tax.
        let tax = math64::mul_div(amount, TAX_RATE, SCALE_FACTOR);
        let remaining_amount = amount - tax;

        // Withdraw the taxed amount from the input store and deposit it to the deployer's store.
        let taxed_assets = fungible_asset::withdraw_with_ref(transfer_ref, store, tax);
        fungible_asset::deposit_with_ref(transfer_ref, deployer_store(), taxed_assets);

        // Withdraw the remaining amount from the input store and return it.
        fungible_asset::withdraw_with_ref(transfer_ref, store, remaining_amount)
    }

    /* Minting and Burning */
    /// Mint new assets to the specified account. 
    public entry fun mint(deployer: &signer, to: address, amount: u64) acquires Management {
        assert_admin(deployer);
        let management = borrow_global<Management>(metadata_address());
        let assets = fungible_asset::mint(&management.mint_ref, amount);
        fungible_asset::deposit_with_ref(&management.transfer_ref, primary_fungible_store::ensure_primary_store_exists(to, metadata()), assets);

        event::emit(Mint {
            minter: signer::address_of(deployer),
            to,
            amount,
        });
    }

    /// Burn assets from the specified account. 
    public entry fun burn(deployer: &signer, from: address, amount: u64) acquires Management {
        assert_admin(deployer);
        // Withdraw the assets from the account and burn them.
        let management = borrow_global<Management>(metadata_address());
        let assets = withdraw(primary_fungible_store::ensure_primary_store_exists(from, metadata()), amount, &management.transfer_ref);
        fungible_asset::burn(&management.burn_ref, assets);

        event::emit(Burn {
            minter: signer::address_of(deployer),
            from,
            amount,
        });
    }

    /* Transfer */
    /// Transfer assets from one account to another. 
    public entry fun transfer(from: &signer, to: address, amount: u64) acquires Management {
        // Withdraw the assets from the sender's store and deposit them to the recipient's store.
        let management = borrow_global<Management>(metadata_address());
        let from_store = primary_fungible_store::ensure_primary_store_exists(signer::address_of(from), metadata());
        let to_store = primary_fungible_store::ensure_primary_store_exists(to, metadata());
        let assets = withdraw(from_store, amount, &management.transfer_ref);
        fungible_asset::deposit_with_ref(&management.transfer_ref, to_store, assets);
    }

    inline fun assert_admin(deployer: &signer) {
        assert!(signer::address_of(deployer) == @deployer, EUNAUTHORIZED);
    }

    #[test_only]
    public fun init_for_test(deployer: &signer) {
        init_module(deployer);
    }
}