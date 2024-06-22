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


    /* Errors */
    /// The asset is paused.
    const EPAUSED: u64 = 1;
    /// The caller is unauthorized.
    const EUNAUTHORIZED: u64 = 2;

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

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct State has key {
        paused: bool,
        burn: bool,
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

    #[event]
    struct Pause has drop, store {
        pauser: address,
        is_paused: bool,
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

        // Set the state to be unpaused by default and move to metadata object. 
        move_to(metadata_object_signer, State { paused: false, burn: false}); 

        // Override the withdraw and deposit functions.
        // This ensures all transfer will call the deposit function in this module and impose a tax.
        // It also ensures that there is no global pause in effect in both steps. 
        let deposit = function_info::new_function_info(
            deployer,
            string::utf8(b"taxed_fa"),
            string::utf8(b"deposit"),
        );
        let withdraw = function_info::new_function_info(
            deployer,
            string::utf8(b"taxed_fa"),
            string::utf8(b"withdraw"),
        );
        dispatchable_fungible_asset::register_dispatch_functions(
            constructor_ref,
            option::some(withdraw),
            option::some(deposit),
            option::none(),
        );       
    }

    /* Dispatchable Hooks */
    /// Deposit function override to ensure that there is no global pause effect AND we impose a tax during the operation.
    public fun deposit<T: key>(
        store: Object<T>,
        fa: FungibleAsset,
        transfer_ref: &TransferRef,
    ) acquires State {
        assert_not_paused();
        fungible_asset::deposit_with_ref(transfer_ref, store, fa);
    }

    /// Withdraw function override to ensure that there is no global pause in effect.
    public fun withdraw<T: key>(
        store: Object<T>,
        amount: u64,
        transfer_ref: &TransferRef,
    ): FungibleAsset acquires State {
        assert_not_paused();
        let burn_status = borrow_global<State>(metadata_address()).burn;

        // If the burn flag is set, withdraw the amount without imposing a tax.
        if (burn_status) {
            fungible_asset::withdraw_with_ref(transfer_ref, store, amount)
        } else {
            // Calculate a 10% tax on the amount.
            let tax = amount * TAX_RATE / SCALE_FACTOR;
            let remaining_amount = amount - tax;

            // Withdraw the taxed amount from the input store and deposit it to the deployer's store.
            let taxed_assets = fungible_asset::withdraw_with_ref(transfer_ref, store, tax);
            fungible_asset::deposit_with_ref(transfer_ref, deployer_store(), taxed_assets);

            // Withdraw the remaining amount from the input store and return it.
            fungible_asset::withdraw_with_ref(transfer_ref, store, remaining_amount)
        }
    }

    /* Minting and Burning */
    /// Mint new assets to the specified account. 
    public entry fun mint(deployer: &signer, to: address, amount: u64) acquires Management, State {
        assert_not_paused();

        let management = borrow_global<Management>(metadata_address());
        let assets = fungible_asset::mint(&management.mint_ref, amount);
        deposit(primary_fungible_store::ensure_primary_store_exists(to, metadata()), assets, &management.transfer_ref);

        event::emit(Mint {
            minter: signer::address_of(deployer),
            to,
            amount,
        });
    }

    /// Burn assets from the specified account. 
    public entry fun burn(deployer: &signer, from: address, amount: u64) acquires Management, State {
        assert_not_paused();

        // Set the burn flag to true to prevent a tax being imposed.
        let state = borrow_global_mut<State>(metadata_address());
        state.burn = true;

        // Withdraw the assets from the account and burn them.
        let management = borrow_global<Management>(metadata_address());
        let assets = withdraw(primary_fungible_store::ensure_primary_store_exists(from, metadata()), amount, &management.transfer_ref);
        fungible_asset::burn(&management.burn_ref, assets);

        event::emit(Burn {
            minter: signer::address_of(deployer),
            from,
            amount,
        });

        // Set the burn flag to false.
        let state = borrow_global_mut<State>(metadata_address());
        state.burn = false;
    }

    /* Transfer */
    /// Transfer assets from one account to another. 
    public entry fun transfer(from: &signer, to: address, amount: u64) acquires Management, State {
        assert_not_paused();

        // Withdraw the assets from the sender's store and deposit them to the recipient's store.
        let management = borrow_global<Management>(metadata_address());
        let from_store = primary_fungible_store::ensure_primary_store_exists(signer::address_of(from), metadata());
        let to_store = primary_fungible_store::ensure_primary_store_exists(to, metadata());
        let assets = withdraw(from_store, amount, &management.transfer_ref);
        deposit(to_store, assets, &management.transfer_ref);
    }

    /* Pause and Unpause */
    /// Pause or unpause the fungible asset. 
    public entry fun set_pause(pauser: &signer, paused: bool) acquires State {
        assert!(signer::address_of(pauser) == @deployer, EUNAUTHORIZED);

        // If the state is already in the desired state, return early.
        // Otherwise, update the state and emit an event.
        let state = borrow_global_mut<State>(metadata_address());
        if (state.paused == paused) { return };
        state.paused = paused;

        event::emit(Pause {
            pauser: signer::address_of(pauser),
            is_paused: paused,
        });
    }

    /* Inline Functions */
    inline fun assert_not_paused() acquires State {
        let state = borrow_global<State>(metadata_address());
        assert!(!state.paused, EPAUSED);
    }

    #[test_only]
    public fun init_for_test(deployer: &signer) {
        init_module(deployer);
    }
}
