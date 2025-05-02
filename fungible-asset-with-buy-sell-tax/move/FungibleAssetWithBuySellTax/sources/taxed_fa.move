module taxed_fa_addr::taxed_fa {
    use aptos_framework::object::{Self, Object, ExtendRef, ObjectCore};
    use aptos_framework::fungible_asset::{
        Self,
        TransferRef,
        Metadata,
        FungibleAsset
    };
    use aptos_framework::primary_fungible_store;
    use aptos_framework::dispatchable_fungible_asset;
    use aptos_framework::function_info;
    use aptos_framework::simple_map::{Self, SimpleMap};

    use std::signer;
    use std::option;
    use std::string::{Self, utf8};
    use aptos_framework::event;

    /// The caller is unauthorized.
    const ERR_UNAUTHORIZED: u64 = 1;
    /// The amount is too low, tax cannot be imposed, please swap more than 10 tokens.
    const ERR_LOW_AMOUNT: u64 = 2;

    const ASSET_NAME: vector<u8> = b"Taxed Fungible Asset";
    const ASSET_SYMBOL: vector<u8> = b"TFA1";
    const TAX_RATE: u64 = 10;
    const SCALE_FACTOR: u64 = 100;
    // 6 decimal places, total is 1m tokens
    const MAX_SUPPLY: u64 = 1_000_000_000;

    struct Config has key {
        extend_ref: ExtendRef,
        transfer_ref: TransferRef,
        registered_lps: SimpleMap<Object<Metadata>, bool>
    }

    #[event]
    struct BuyTaxCollectedEvent has drop, store {
        tax_recipient: address,
        tax_amount: u64,
        buyer_received_amount: u64
    }

    #[event]
    struct SellTaxCollectedEvent has drop, store {
        tax_recipient: address,
        tax_amount: u64,
        pool_received_amount: u64
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
                registered_lps: simple_map::new()
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

    /// Register the lp pool object, this object iself is also an FA
    /// can only be called by the creator
    public entry fun register_lp(
        sender: &signer, lp_fa: Object<Metadata>
    ) acquires Config {
        assert_admin(signer::address_of(sender));

        let config = borrow_global_mut<Config>(metadata_address());
        simple_map::add(&mut config.registered_lps, lp_fa, true);
    }

    /// Custom withdraw function that applies tax for buy transactions
    /// When user buys TFA from the pool, TFA will be withdrawn from the pool
    public fun custom_withdraw<T: key>(
        store: Object<T>, amount: u64, transfer_ref: &TransferRef
    ): FungibleAsset acquires Config {
        let config = borrow_global<Config>(metadata_address());

        // check if store is owned by the lp fa object
        // because all thala lp stores are owned by the lp fa object
        if (!simple_map::contains_key(
            &config.registered_lps, &object::address_to_object(object::owner(store))
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

        event::emit(
            BuyTaxCollectedEvent {
                tax_recipient: @tfa_recipient_addr,
                tax_amount,
                buyer_received_amount: user_amount
            }
        );

        user_asset
    }

    /// Custom deposit function that applies tax for sell transactions
    /// When user sells TFA to the pool, TFA will be deposited to the pool
    public fun custom_deposit<T: key>(
        store: Object<T>, fa: FungibleAsset, transfer_ref: &TransferRef
    ) acquires Config {
        let config = borrow_global<Config>(metadata_address());

        // check if store is owned by the lp fa object
        // because all thala lp stores are owned by the lp fa object
        if (!simple_map::contains_key(
            &config.registered_lps, &object::address_to_object(object::owner(store))
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

        let pool_received_amount = fungible_asset::amount(&fa);

        // Deposit user's portion to their store
        fungible_asset::deposit_with_ref(transfer_ref, store, fa);

        // Deposit tax to creator
        let creator_store =
            primary_fungible_store::ensure_primary_store_exists(
                @tfa_recipient_addr, metadata()
            );
        fungible_asset::deposit_with_ref(transfer_ref, creator_store, tax_asset);

        event::emit(
            SellTaxCollectedEvent {
                tax_recipient: @tfa_recipient_addr,
                tax_amount,
                pool_received_amount
            }
        );
    }

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
    public fun get_registered_lps(): vector<Object<Metadata>> acquires Config {
        let config = borrow_global<Config>(metadata_address());
        simple_map::keys(&config.registered_lps)
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
