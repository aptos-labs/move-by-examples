module permissioned_fa_addr::permissioned_fa {
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_framework::fungible_asset::{
        Self,
        MintRef,
        TransferRef,
        BurnRef,
        Metadata,
        FungibleAsset
    };
    use aptos_framework::primary_fungible_store;
    use aptos_framework::dispatchable_fungible_asset;
    use aptos_framework::function_info;
    use aptos_framework::smart_table::{Self, SmartTable};

    use std::signer;
    use std::option;
    use std::event;
    use std::string::{Self, utf8};

    /// The caller is unauthorized.
    const ERR_UNAUTHORIZED: u64 = 1;
    /// The address is blocked from performing operations.
    const ERR_BLOCKED: u64 = 2;

    const ASSET_NAME: vector<u8> = b"Permissioned Fungible Asset";
    const ASSET_SYMBOL: vector<u8> = b"PFA";

    struct Management has key {
        extend_ref: ExtendRef,
        mint_ref: MintRef,
        burn_ref: BurnRef,
        transfer_ref: TransferRef,
        blocklist: SmartTable<address, bool>
    }

    /* Events */
    #[event]
    struct Mint has drop, store {
        minter: address,
        to: address,
        amount: u64
    }

    #[event]
    struct Burn has drop, store {
        minter: address,
        from: address,
        amount: u64
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
            6,
            utf8(b"http://example.com/favicon.ico"),
            utf8(b"http://example.com")
        );

        // Generate a signer for the asset metadata object.
        let metadata_object_signer = &object::generate_signer(constructor_ref);

        // Generate asset management refs and move to the metadata object.
        move_to(
            metadata_object_signer,
            Management {
                extend_ref: object::generate_extend_ref(constructor_ref),
                mint_ref: fungible_asset::generate_mint_ref(constructor_ref),
                burn_ref: fungible_asset::generate_burn_ref(constructor_ref),
                transfer_ref: fungible_asset::generate_transfer_ref(constructor_ref),
                blocklist: smart_table::new()
            }
        );

        // Override the withdraw function.
        // This ensures all transfer will call the withdraw function in this module and impose a tax.
        let custom_withdraw =
            function_info::new_function_info(
                deployer,
                string::utf8(b"permissioned_fa"),
                string::utf8(b"custom_withdraw")
            );
        let custom_deposit =
            function_info::new_function_info(
                deployer,
                string::utf8(b"permissioned_fa"),
                string::utf8(b"custom_deposit")
            );
        dispatchable_fungible_asset::register_dispatch_functions(
            constructor_ref,
            option::some(custom_withdraw),
            option::some(custom_deposit),
            option::none()
        );
    }

    /// Withdraw function, no override now, but can be overridden in the future upgrade.
    public fun custom_withdraw<T: key>(
        store: Object<T>, amount: u64, transfer_ref: &TransferRef
    ): FungibleAsset {
        fungible_asset::withdraw_with_ref(transfer_ref, store, amount)
    }

    /// Deposit function override to check blocklist before allowing deposit.
    public fun custom_deposit<T: key>(
        store: Object<T>, fa: FungibleAsset, transfer_ref: &TransferRef
    ) acquires Management {
        let management = borrow_global<Management>(metadata_address());
        assert!(
            !management.blocklist.contains(object::owner(store)),
            ERR_BLOCKED
        );

        fungible_asset::deposit_with_ref(transfer_ref, store, fa)
    }

    // ======================== Write functions ========================

    /// Update the blocklist for the asset.
    public entry fun update_blocklist(
        deployer: &signer, address: address, is_blocked: bool
    ) acquires Management {
        assert_admin(deployer);
        let management = borrow_global_mut<Management>(metadata_address());
        if (is_blocked) {
            management.blocklist.add(address, true);
        } else {
            management.blocklist.remove(address);
        }
    }

    /// Mint new assets to the specified account.
    public entry fun mint(deployer: &signer, to: address, amount: u64) acquires Management {
        assert_admin(deployer);
        let management = borrow_global<Management>(metadata_address());
        let assets = fungible_asset::mint(&management.mint_ref, amount);
        fungible_asset::deposit_with_ref(
            &management.transfer_ref,
            primary_fungible_store::ensure_primary_store_exists(to, metadata()),
            assets
        );

        event::emit(Mint { minter: signer::address_of(deployer), to, amount });
    }

    /// Burn assets from the specified account.
    public entry fun burn(deployer: &signer, from: address, amount: u64) acquires Management {
        assert_admin(deployer);
        // Withdraw the assets from the account and burn them.
        let management = borrow_global<Management>(metadata_address());
        let assets =
            custom_withdraw(
                primary_fungible_store::ensure_primary_store_exists(from, metadata()),
                amount,
                &management.transfer_ref
            );
        fungible_asset::burn(&management.burn_ref, assets);

        event::emit(Burn { minter: signer::address_of(deployer), from, amount });
    }

    // ======================== Read Functions ========================

    /* View Functions */
    #[view]
    public fun metadata_address(): address {
        object::create_object_address(&@permissioned_fa_addr, ASSET_SYMBOL)
    }

    #[view]
    public fun metadata(): Object<Metadata> {
        object::address_to_object(metadata_address())
    }

    // ======================== Helper Functions ========================

    fun assert_admin(deployer: &signer) {
        assert!(signer::address_of(deployer) == @permissioned_fa_addr, ERR_UNAUTHORIZED);
    }

    // ================================= Uint Tests Helper ================================== //

    #[test_only]
    public fun init_for_test(deployer: &signer) {
        init_module(deployer);
    }
}
