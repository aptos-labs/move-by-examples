module taxed_fa_addr::taxed_fa {
    use aptos_framework::object::{Self, Object, ExtendRef, ObjectCore};
    use aptos_framework::fungible_asset::{
        Self,
        TransferRef,
        Metadata,
        FungibleAsset,
        FungibleStore
    };
    use aptos_framework::primary_fungible_store;
    use aptos_framework::dispatchable_fungible_asset;
    use aptos_framework::function_info;
    use aptos_framework::simple_map::{Self, SimpleMap};

    use std::signer;
    use std::option;
    use std::string::{Self, utf8};

    /// The caller is unauthorized.
    const ERR_UNAUTHORIZED: u64 = 1;
    /// The amount is too low, tax cannot be imposed, please swap more than 10 tokens.
    const ERR_LOW_AMOUNT: u64 = 2;

    const ASSET_NAME: vector<u8> = b"Taxed Fungible Asset";
    const ASSET_SYMBOL: vector<u8> = b"TFA";
    const TAX_RATE: u64 = 10;
    const SCALE_FACTOR: u64 = 100;
    // 6 decimal places, total is 1m tokens
    const MAX_SUPPLY: u64 = 1_000_000_000;

    struct Config has key {
        extend_ref: ExtendRef,
        transfer_ref: TransferRef,
        registered_pools: SimpleMap<Object<FungibleStore>, bool>
    }

    // This function is only called once when the module is published for the first time.
    // init_module is optional, you can also have an entry function as the initializer.
    fun init_module(deployer: &signer) {
        // Create the fungible asset metadata object.
        let constructor_ref = &object::create_named_object(deployer, ASSET_SYMBOL);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::some((MAX_SUPPLY as u128)),
            utf8(ASSET_NAME),
            utf8(ASSET_SYMBOL),
            6,
            utf8(b"http://example.com/favicon.ico"),
            utf8(b"http://example.com")
        );

        let mint_ref = &fungible_asset::generate_mint_ref(constructor_ref);
        // mint the whole supply to the deployer
        primary_fungible_store::mint(mint_ref, @tfa_recipient_addr, MAX_SUPPLY);

        // Generate a signer for the asset metadata object.
        let metadata_object_signer = &object::generate_signer(constructor_ref);

        move_to(
            metadata_object_signer,
            Config {
                extend_ref: object::generate_extend_ref(constructor_ref),
                transfer_ref: fungible_asset::generate_transfer_ref(constructor_ref),
                registered_pools: simple_map::new()
            }
        );

        // Override the deposit and withdraw function
        let custom_withdraw =
            function_info::new_function_info(
                deployer,
                string::utf8(b"taxed_fa"),
                string::utf8(b"custom_withdraw")
            );
        let custom_deposit =
            function_info::new_function_info(
                deployer,
                string::utf8(b"taxed_fa"),
                string::utf8(b"custom_deposit")
            );

        dispatchable_fungible_asset::register_dispatch_functions(
            constructor_ref,
            option::some(custom_withdraw),
            option::some(custom_deposit),
            option::none()
        );
    }

    // ======================== Write functions ========================

    /// Register the pool address (can only be called by the creator)
    public entry fun register_pool(
        sender: &signer, pool_store: Object<FungibleStore>
    ) acquires Config {
        assert_admin(signer::address_of(sender));

        let config = borrow_global_mut<Config>(metadata_address());
        simple_map::add(&mut config.registered_pools, pool_store, true);
    }

    /// Custom withdraw function that applies tax for sell transactions
    public fun custom_withdraw<T: key>(
        store: Object<T>, amount: u64, transfer_ref: &TransferRef
    ): FungibleAsset acquires Config {
        let config = borrow_global<Config>(metadata_address());

        if (!simple_map::contains_key(
            &config.registered_pools, &object::convert(store)
        )) {
            return fungible_asset::withdraw_with_ref(transfer_ref, store, amount)
        };

        assert_can_impose_tax(amount);

        // Calculate tax amount
        let tax_amount = (amount * TAX_RATE) / SCALE_FACTOR;
        if (tax_amount == 0) {
            return fungible_asset::withdraw_with_ref(transfer_ref, store, amount)
        };

        let user_amount = amount - tax_amount;

        // Withdraw both user amount and tax
        let user_asset =
            fungible_asset::withdraw_with_ref(transfer_ref, store, user_amount);
        let tax_asset = fungible_asset::withdraw_with_ref(
            transfer_ref, store, tax_amount
        );

        // Send tax to creator
        let creator_store =
            primary_fungible_store::ensure_primary_store_exists(
                @tfa_recipient_addr, metadata()
            );
        fungible_asset::deposit_with_ref(transfer_ref, creator_store, tax_asset);

        user_asset
    }

    /// Custom deposit function that applies tax for buy transactions
    public fun custom_deposit<T: key>(
        store: Object<T>, fa: FungibleAsset, transfer_ref: &TransferRef
    ) acquires Config {
        let config = borrow_global<Config>(metadata_address());

        if (!simple_map::contains_key(
            &config.registered_pools, &object::convert(store)
        )) {
            return fungible_asset::deposit_with_ref(transfer_ref, store, fa)
        };

        assert_can_impose_tax(fungible_asset::amount(&fa));

        // Calculate tax amount
        let tax_amount = (fungible_asset::amount(&fa) * TAX_RATE) / SCALE_FACTOR;
        if (tax_amount == 0) {
            return fungible_asset::deposit_with_ref(transfer_ref, store, fa)
        };

        // Extract tax tokens from the incoming amount
        let tax_asset = fungible_asset::extract(&mut fa, tax_amount);

        // Deposit user's portion to their store
        fungible_asset::deposit_with_ref(transfer_ref, store, fa);

        // Deposit tax to creator
        let creator_store =
            primary_fungible_store::ensure_primary_store_exists(
                @tfa_recipient_addr, metadata()
            );
        fungible_asset::deposit_with_ref(transfer_ref, creator_store, tax_asset);
    }

    // /// Transfer assets from one account to another.
    // public entry fun transfer(from: &signer, to: address, amount: u64) acquires Config {
    //     // Withdraw the assets from the sender's store and deposit them to the recipient's store.
    //     let config = borrow_global<Config>(metadata_address());
    //     let from_store =
    //         primary_fungible_store::ensure_primary_store_exists(
    //             signer::address_of(from), metadata()
    //         );
    //     let to_store = primary_fungible_store::ensure_primary_store_exists(
    //         to, metadata()
    //     );
    //     let assets = custom_withdraw(from_store, amount, &config.transfer_ref);
    //     // fungible_asset::deposit_with_ref(&config.transfer_ref, to_store, assets);
    //     custom_deposit(to_store, assets, &config.transfer_ref);
    // }

    // ======================== Read Functions ========================

    #[view]
    public fun metadata_address(): address {
        object::create_object_address(&@taxed_fa_addr, ASSET_SYMBOL)
    }

    #[view]
    public fun metadata(): Object<Metadata> {
        object::address_to_object(metadata_address())
    }

    #[view]
    public fun deployer_store(): Object<FungibleStore> {
        primary_fungible_store::ensure_primary_store_exists(@taxed_fa_addr, metadata())
    }

    #[view]
    public fun get_registered_pools(): vector<Object<FungibleStore>> acquires Config {
        let config = borrow_global<Config>(metadata_address());
        simple_map::keys(&config.registered_pools)
    }

    // ======================== Helper Functions ========================

    fun assert_admin(sender: address) {
        let is_admin =
            if (sender == @taxed_fa_addr) { true }
            else {
                if (object::is_object(@taxed_fa_addr)) {
                    let obj = object::address_to_object<ObjectCore>(@taxed_fa_addr);
                    object::is_owner(obj, sender)
                } else { false }
            };
        assert!(is_admin, ERR_UNAUTHORIZED);
    }

    fun assert_can_impose_tax(amount: u64) {
        assert!(amount > 10, ERR_LOW_AMOUNT);
    }

    // ================================= Uint Tests Helper ================================== //

    #[test_only]
    public fun init_for_test(deployer: &signer) {
        init_module(deployer);
    }
}
