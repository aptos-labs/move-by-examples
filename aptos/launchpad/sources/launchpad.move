module launchpad_addr::launchpad {
    use std::bcs::to_bytes;
    use aptos_framework::object;
    use aptos_framework::fungible_asset::{Self, Metadata, FungibleAsset};
    use aptos_framework::object::Object;
    use playground_addr::managed_fungible_asset;
    use std::string::utf8;
    use aptos_std::string_utils;

    const ASSET_SYMBOL: vector<u8> = b"FA";

    struct Counter has key {
        count: u64,
    }

    fun init_module(sender: &signer) {
        move_to(sender, Counter { count: 0 })
    }

    // ================================= Entry Functions ================================= //

    public entry fun create_fa(sender: &signer) acquires Counter {
        let counter = borrow_global_mut<Counter>(@playground_addr);
        let symbol = to_bytes(&string_utils::format2(&b"{}_{}", ASSET_SYMBOL, counter.count));
        let constructor_ref = &object::create_named_object(sender, symbol);
        managed_fungible_asset::initialize(
            constructor_ref,
            0, /* maximum_supply. 0 means no maximum */
            utf8(b"You only live once"), /* name */
            utf8(symbol), /* symbol */
            8, /* decimals */
            utf8(b"http://example.com/favicon.ico"), /* icon */
            utf8(b"http://example.com"), /* project */
            vector[true, true, true], /* mint_ref, transfer_ref, burn_ref */
        );
        counter.count = counter.count + 1;
    }

    /// Mint as the owner of metadata object.
    public entry fun mint(admin: &signer, counter: u64, to: address, amount: u64) {
        managed_fungible_asset::mint_to_primary_stores(admin, get_metadata(counter), vector[to], vector[amount]);
    }

    /// Transfer as the owner of metadata object ignoring `frozen` field.
    public entry fun transfer(admin: &signer, counter: u64,from: address, to: address, amount: u64) {
        managed_fungible_asset::transfer_between_primary_stores(
            admin,
            get_metadata(counter),
            vector[from],
            vector[to],
            vector[amount]
        );
    }

    /// Burn fungible assets as the owner of metadata object.
    public entry fun burn(admin: &signer, counter: u64,from: address, amount: u64) {
        managed_fungible_asset::burn_from_primary_stores(admin, get_metadata(counter), vector[from], vector[amount]);
    }

    /// Freeze an account so it cannot transfer or receive fungible assets.
    public entry fun freeze_account(admin: &signer, counter: u64, account: address) {
        managed_fungible_asset::set_primary_stores_frozen_status(admin, get_metadata(counter), vector[account], true);
    }

    /// Unfreeze an account so it can transfer or receive fungible assets.
    public entry fun unfreeze_account(admin: &signer, counter: u64,account: address) {
        managed_fungible_asset::set_primary_stores_frozen_status(admin, get_metadata(counter), vector[account], false);
    }

    // ================================= View Functions ================================== //

    #[view]
    /// Return the address of the metadata that's created when this module is deployed.
    public fun get_metadata(counter: u64): Object<Metadata> {
        let symbol = to_bytes(&string_utils::format2(&b"{}_{}", ASSET_SYMBOL, counter));
        let metadata_address = object::create_object_address(&@playground_addr, symbol);
        object::address_to_object<Metadata>(metadata_address)
    }

    // ================================= Helpers ================================== //

    /// Withdraw as the owner of metadata object ignoring `frozen` field.
    public fun withdraw(admin: &signer, counter: u64,from: address, amount: u64): FungibleAsset {
        managed_fungible_asset::withdraw_from_primary_stores(admin, get_metadata(counter), vector[from], vector[amount])
    }

    /// Deposit as the owner of metadata object ignoring `frozen` field.
    public fun deposit(admin: &signer, fa: FungibleAsset, to: address) {
        let amount = fungible_asset::amount(&fa);
        managed_fungible_asset::deposit_to_primary_stores(
            admin,
            &mut fa,
            vector[to],
            vector[amount]
        );
        fungible_asset::destroy_zero(fa);
    }

    // ================================= Tests ================================== //

    #[test_only]
    use aptos_framework::primary_fungible_store;
    #[test_only]
    use std::signer;

    #[test(creator = @playground_addr)]
    fun test_basic_flow(creator: &signer) acquires Counter {
        init_module(creator);
        // let counter = borrow_global<Counter>(@playground_addr);
        create_fa(creator);
        let creator_address = signer::address_of(creator);
        let aaron_address = @0xface;

        mint(creator, 0, creator_address, 100);
        let metadata = get_metadata(0);
        assert!(primary_fungible_store::balance(creator_address, metadata) == 100, 4);
        freeze_account(creator, 0, creator_address);
        assert!(primary_fungible_store::is_frozen(creator_address, metadata), 5);
        transfer(creator, 0,creator_address, aaron_address, 10);
        assert!(primary_fungible_store::balance(aaron_address, metadata) == 10, 6);

        unfreeze_account(creator,0, creator_address);
        assert!(!primary_fungible_store::is_frozen(creator_address, metadata), 7);
        burn(creator, 0, creator_address, 90);


        create_fa(creator);
        let creator_address = signer::address_of(creator);
        let aaron_address = @0xface;

        mint(creator, 1, creator_address, 100);
        let metadata = get_metadata(1);
        assert!(primary_fungible_store::balance(creator_address, metadata) == 100, 4);
        freeze_account(creator, 1, creator_address);
        assert!(primary_fungible_store::is_frozen(creator_address, metadata), 5);
        transfer(creator, 1,creator_address, aaron_address, 10);
        assert!(primary_fungible_store::balance(aaron_address, metadata) == 10, 6);

        unfreeze_account(creator,1, creator_address);
        assert!(!primary_fungible_store::is_frozen(creator_address, metadata), 7);
        burn(creator, 1, creator_address, 90);
    }

    // #[test(creator = @playground_addr, aaron = @0xface)]
    // #[expected_failure(abort_code = 0x50001, location = playground_addr::managed_fungible_asset)]
    // fun test_permission_denied(creator: &signer, aaron: &signer) acquires Counter {
    //     create_fa(creator);
    //     let creator_address = signer::address_of(creator);
    //     mint(aaron, creator_address, 100);
    // }
}
