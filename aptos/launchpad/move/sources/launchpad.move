module launchpad_addr::launchpad {
    use std::option;
    use std::signer;
    use std::string;
    use std::vector;
    use aptos_std::math128;
    use aptos_std::math64;
    use aptos_framework::event;
    use aptos_framework::fungible_asset;
    use aptos_framework::object;
    use aptos_framework::primary_fungible_store;

    #[event]
    struct CreateFAEvent has store, drop {
        creator_addr: address,
        fa_obj_addr: address,
        max_supply: option::Option<u128>,
        name: string::String,
        symbol: string::String,
        decimals: u8,
        icon_uri: string::String,
        project_uri: string::String,
    }

    #[event]
    struct MintFAEvent has store, drop {
        fa_obj_addr: address,
        amount: u64,
        recipient_addr: address,
    }

    struct FAController has key {
        mint_ref: fungible_asset::MintRef,
        burn_ref: fungible_asset::BurnRef,
        transfer_ref: fungible_asset::TransferRef
    }

    struct Registry has key {
        fa_obj_addresses: vector<address>
    }

    fun init_module(sender: &signer) {
        move_to(sender, Registry {
            fa_obj_addresses: vector::empty<address>()
        });
    }

    // ================================= Entry Functions ================================= //

    public entry fun create_fa(
        sender: &signer,
        max_supply: option::Option<u128>,
        name: string::String,
        symbol: string::String,
        decimals: u8,
        icon_uri: string::String,
        project_uri: string::String
    ) acquires Registry {
        let fa_obj_constructor_ref = &object::create_sticky_object(@launchpad_addr);
        let fa_obj_signer = object::generate_signer(fa_obj_constructor_ref);
        let converted_max_supply = if (option::is_some(&max_supply)) {
            option::some(option::extract(&mut max_supply) * math128::pow(10, (decimals as u128)))
        } else {
            option::none()
        };
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            fa_obj_constructor_ref,
            converted_max_supply,
            name,
            symbol,
            decimals,
            icon_uri,
            project_uri
        );
        let mint_ref = fungible_asset::generate_mint_ref(fa_obj_constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(fa_obj_constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(fa_obj_constructor_ref);
        move_to(&fa_obj_signer, FAController {
            mint_ref,
            burn_ref,
            transfer_ref,
        });

        let registry = borrow_global_mut<Registry>(@launchpad_addr);
        vector::push_back(&mut registry.fa_obj_addresses, signer::address_of(&fa_obj_signer));

        event::emit(CreateFAEvent {
            creator_addr: signer::address_of(sender),
            fa_obj_addr: signer::address_of(&fa_obj_signer),
            max_supply: converted_max_supply,
            name,
            symbol,
            decimals,
            icon_uri,
            project_uri,
        });
    }

    public entry fun mint_fa(sender: &signer, fa_obj_addr: address, amount: u64) acquires FAController {
        let sender_addr = signer::address_of(sender);
        let config = borrow_global<FAController>(fa_obj_addr);
        let (_, _, decimals) = get_metadata(fa_obj_addr);
        let minted_fa = fungible_asset::mint(&config.mint_ref, amount * math64::pow(10, (decimals as u64)));
        primary_fungible_store::deposit(sender_addr, minted_fa);

        event::emit(MintFAEvent {
            fa_obj_addr,
            amount,
            recipient_addr: sender_addr,
        });
    }

    // ================================= View Functions ================================== //

    #[view]
    public fun get_registry(): vector<address> acquires Registry {
        let registry = borrow_global<Registry>(@launchpad_addr);
        registry.fa_obj_addresses
    }

    #[view]
    public fun get_metadata(fa_obj_addr: address): (string::String, string::String, u8) {
        let metadata_obj = object::address_to_object<fungible_asset::Metadata>(fa_obj_addr);
        (
            fungible_asset::name(metadata_obj),
            fungible_asset::symbol(metadata_obj),
            fungible_asset::decimals(metadata_obj),
        )
    }

    #[view]
    public fun get_current_supply(fa_obj_addr: address): u128 {
        let fa_obj = object::address_to_object<object::ObjectCore>(fa_obj_addr);
        let maybe_supply = fungible_asset::supply(fa_obj);
        if (option::is_some(&maybe_supply)) {
            option::extract(&mut maybe_supply)
        } else {
            0
        }
    }

    #[view]
    public fun get_max_supply(fa_obj_addr: address): u128 {
        let fa_obj = object::address_to_object<object::ObjectCore>(fa_obj_addr);
        let maybe_supply = fungible_asset::maximum(fa_obj);
        if (option::is_some(&maybe_supply)) {
            option::extract(&mut maybe_supply)
        } else {
            0
        }
    }

    #[view]
    public fun get_balance(fa_obj_addr: address, user: address): u64 {
        let fa_obj = object::address_to_object<object::ObjectCore>(fa_obj_addr);
        primary_fungible_store::balance(user, fa_obj)
    }

    // ================================= Tests ================================== //

    #[test(sender = @launchpad_addr)]
    fun test_happy_path(sender: &signer) acquires Registry, FAController {
        let sender_addr = signer::address_of(sender);

        init_module(sender);

        // create first FA

        create_fa(
            sender,
            option::some(100),
            string::utf8(b"FA1"),
            string::utf8(b"FA1"),
            2,
            string::utf8(b"icon_url"),
            string::utf8(b"project_url")
        );
        let registry = get_registry();
        let fa_obj_addr_1 = *vector::borrow(&registry, vector::length(&registry) - 1);
        assert!(get_current_supply(fa_obj_addr_1) == 0, 1);

        mint_fa(sender, fa_obj_addr_1, 2);
        assert!(get_current_supply(fa_obj_addr_1) == 200, 2);
        assert!(get_balance(fa_obj_addr_1, sender_addr) == 200, 3);

        // create second FA

        create_fa(
            sender,
            option::some(100),
            string::utf8(b"FA2"),
            string::utf8(b"FA2"),
            3,
            string::utf8(b"icon_url"),
            string::utf8(b"project_url")
        );
        let registry = get_registry();
        let fa_obj_addr_2 = *vector::borrow(&registry, vector::length(&registry) - 1);
        assert!(get_current_supply(fa_obj_addr_2) == 0, 4);

        mint_fa(sender, fa_obj_addr_2, 3);
        assert!(get_current_supply(fa_obj_addr_2) == 3000, 5);
        assert!(get_balance(fa_obj_addr_2, sender_addr) == 3000, 6);
    }
}