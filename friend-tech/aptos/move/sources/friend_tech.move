module friend_tech_addr::friend_tech {
    use std::bcs;
    use std::signer;
    use std::string;
    use std::vector;
    use aptos_std::math64;
    use aptos_std::string_utils;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::event;
    use aptos_framework::object;

    /// User already issued key
    const E_USER_ALREADY_ISSUED_KEY: u64 = 1;
    /// Insufficient balance
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    /// Issuer does not exist
    const E_ISSUER_NOT_EXIST: u64 = 3;
    /// Holding does not exist
    const E_HOLDING_NOT_EXIST: u64 = 4;
    /// User does not exist
    const E_USER_NOT_EXIST: u64 = 5;
    /// Holder does not exist
    const E_HOLDER_NOT_EXIST: u64 = 6;

    const VAULT_SEED: vector<u8> = b"VAULT";

    struct Holding {
        issuer_obj: object::Object<Issuer>,
        holder: address,
        shares: u64,
    }

    struct User has key {
        holdings: vector<object::Object<Holding>>,
    }

    struct Issuer has key {
        addr: address,
        social_media_handle: string::String,
        total_issued_shares: u64,
        holder_holdings: vector<object::Object<Holding>>,
    }

    struct IssuerRegistry has key {
        issuers: vector<object::Object<Issuer>>
    }

    struct Config has key {
        protocol_fee_collector: address
    }

    struct Vault has key {
        extend_ref: object::ExtendRef,
    }

    #[event]
    struct IssueKeyEvent has store, drop {
        issuer_addr: address,
        issuer_obj: object::Object<Issuer>,
        username: string::String,
    }

    #[event]
    struct BuyKeyEvent has store, drop {
        issuer_addr: address,
        issuer_obj: object::Object<Issuer>,
        buyer_addr: address,
        buyer_user_obj: object::Object<User>,
        amount: u64,
        key_cost: u64,
        issuer_fee: u64,
        protocol_fee: u64,
        total_cost: u64,
    }

    #[event]
    struct SellKeyEvent has store, drop {
        issuer_addr: address,
        issuer_obj: object::Object<Issuer>,
        seller_addr: address,
        seller_user_obj: object::Object<User>,
        amount: u64,
        key_cost: u64,
        issuer_fee: u64,
        protocol_fee: u64,
        total_cost: u64,
    }

    // If you deploy the module under an object, sender is the object's signer
    // If you deploy the moduelr under your own account, sender is your account's signer
    fun init_module(sender: &signer, protocol_fee_collector: address) {
        let vault_constructor_ref = &object::create_named_object(sender, VAULT_SEED);
        let vault_signer = &object::generate_signer(vault_constructor_ref);

        move_to(vault_signer, Vault {
            extend_ref: object::generate_extend_ref(vault_constructor_ref),
        });
        move_to(sender, IssuerRegistry {
            issuers: vector::empty()
        });
        move_to(sender, Config {
            protocol_fee_collector
        });
    }

    // ================================= Entry Functions ================================= //

    public entry fun issue_key(
        sender: &signer,
        username: string::String,
    ) acquires User, IssuerRegistry {
        let sender_addr = signer::address_of(sender);
        assert!(exists<Issuer>(get_issuer_obj_addr(sender_addr)), E_USER_ALREADY_ISSUED_KEY);
        let issuer_obj_constructor_ref = &object::create_named_object(
            sender,
            construct_issuer_object_seed(sender_addr)
        );
        let holding_obj_constructor_ref = &object::create_named_object(
            sender,
            construct_holding_object_seed(sender_addr, sender_addr)
        );

        let issuer_obj_signer = object::generate_signer(issuer_obj_constructor_ref);
        let holding_obj_signer = object::generate_signer(holding_obj_constructor_ref);

        move_to(&issuer_obj_signer, Issuer {
            addr: sender_addr,
            social_media_handle: username,
            total_issued_shares: 1,
            holder_holdings: vector[get_holding_obj(sender_addr, sender_addr)],
        });

        move_to(&holding_obj_signer, Holding {
            issuer_obj: object::address_to_object(get_issuer_obj_addr(sender_addr)),
            holder: sender_addr,
            shares: 1,
        });

        if (exists<User>(get_user_obj_addr(sender_addr))) {
            let user_obj = borrow_global_mut<User>(get_user_obj_addr(sender_addr));
            vector::push_back(&mut user_obj.holdings, get_holding_obj(sender_addr, sender_addr));
        } else {
            let user_obj_constructor_ref = &object::create_named_object(
                sender,
                construct_issuer_object_seed(sender_addr)
            );
            let user_obj_signer = object::generate_signer(user_obj_constructor_ref);
            move_to(&user_obj_signer, User {
                holdings: vector[get_holding_obj(sender_addr, sender_addr)],
            });
        };

        let registry = borrow_global_mut<IssuerRegistry>(@launchpad_addr);
        vector::push_back(&mut registry.issuers, get_issuer_obj(sender_addr));

        event::emit(IssueKeyEvent {
            issuer_addr: sender_addr,
            issuer_obj: get_issuer_obj(sender_addr),
            username,
        });
    }

    public entry fun buy_key(
        sender: &signer,
        issuer_addr: address,
        amount: u64,
    ) acquires Issuer, Holding, User, Config {
        let sender_addr = signer::address_of(sender);
        let (key_cost, issuer_fee, protocol_fee, total_cost) = calculate_buy_key_cost(issuer_addr, amount);
        assert!(coin::balance<aptos_coin::AptosCoin>(sender_addr) >= total_cost, E_INSUFFICIENT_BALANCE);

        let issuer_obj_addr = get_issuer_obj_addr(issuer_addr);
        assert!(exists<Issuer>(issuer_obj_addr), E_ISSUER_NOT_EXIST);

        let issuer = borrow_global_mut<Issuer>(issuer_obj_addr);
        issuer.total_issued_shares = issuer.total_issued_shares + amount;

        let holding_obj_addr = get_holding_obj_addr(issuer_addr, sender_addr);
        if (exists<Holding>(holding_obj_addr)) {
            // existing holder buys more shares
            let holding = borrow_global_mut<Holding>(holding_obj_addr);
            holding.shares = holding.shares + amount;
        } else {
            // new holder buys shares
            let holding_obj_constructor_ref = &object::create_named_object(
                sender,
                construct_holding_object_seed(issuer_addr, sender_addr)
            );
            let holding_obj_signer = object::generate_signer(holding_obj_constructor_ref);
            move_to(&holding_obj_signer, Holding {
                issuer_obj: object::address_to_object(issuer_obj_addr),
                holder: sender_addr,
                shares: amount,
            });

            vector::push_back(&mut issuer.holder_holdings, get_holding_obj(issuer_addr, sender_addr));

            let buyer_obj_addr = get_user_obj_addr(sender_addr);
            if (exists<User>(buyer_obj_addr)) {
                let buyer_obj = borrow_global_mut<User>(buyer_obj_addr);
                vector::push_back(&mut buyer_obj.holdings, get_holding_obj(issuer_addr, sender_addr));
            } else {
                let buyer_obj_constructor_ref = &object::create_named_object(
                    sender,
                    construct_issuer_object_seed(sender_addr)
                );
                let buyer_obj_signer = object::generate_signer(buyer_obj_constructor_ref);
                move_to(&buyer_obj_signer, User {
                    holdings: vector[get_holding_obj(issuer_addr, sender_addr)],
                });
            };
        };

        coin::transfer<aptos_coin::AptosCoin>(sender, get_vault_addr(), key_cost);
        coin::transfer<aptos_coin::AptosCoin>(sender, get_protocol_fee_collector(), protocol_fee);
        coin::transfer<aptos_coin::AptosCoin>(sender, issuer_addr, issuer_fee);

        event::emit(
            BuyKeyEvent {
                issuer_addr,
                issuer_obj: get_issuer_obj(issuer_addr),
                buyer_addr: sender_addr,
                buyer_user_obj: get_user_obj(sender_addr),
                amount,
                key_cost,
                issuer_fee,
                protocol_fee,
                total_cost,
            }
        );
    }

    public entry fun sell_key(
        sender: &signer,
        issuer_addr: address,
        amount: u64,
    ) acquires Issuer, Holding, User, Config, Vault {
        let sender_addr = signer::address_of(sender);
        let (key_cost, issuer_fee, protocol_fee, total_cost) = calculate_sell_key_cost(issuer_addr, amount);
        assert!(coin::balance<aptos_coin::AptosCoin>(sender_addr) >= total_cost, E_INSUFFICIENT_BALANCE);

        let issuer_obj_addr = get_issuer_obj_addr(issuer_addr);
        assert!(exists<Issuer>(issuer_obj_addr), E_ISSUER_NOT_EXIST);

        let holding_obj_addr = get_holding_obj_addr(issuer_addr, sender_addr);
        assert!(exists<Holding>(holding_obj_addr), E_HOLDING_NOT_EXIST);

        let user_obj_addr = get_user_obj_addr(sender_addr);
        assert!(exists<User>(user_obj_addr), E_USER_NOT_EXIST);

        let issuer = borrow_global_mut<Issuer>(issuer_obj_addr);
        issuer.total_issued_shares = issuer.total_issued_shares + amount;

        let seller = borrow_global_mut<User>(user_obj_addr);

        let holding = borrow_global_mut<Holding>(holding_obj_addr);
        let holding_obj = get_holding_obj(issuer_addr, sender_addr);
        holding.shares = holding.shares - amount;

        if (holding.shares == 0) {
            let (found, idx) = vector::index_of(&mut issuer.holder_holdings, &holding_obj);
            assert!(found, E_HOLDER_NOT_EXIST);
            vector::remove(&mut issuer.holder_holdings, idx);

            let (found, idx) = vector::index_of(&mut seller.holdings, &holding_obj);
            assert!(found, E_HOLDING_NOT_EXIST);
            vector::remove(&mut seller.holdings, idx);
        };

        coin::transfer<aptos_coin::AptosCoin>(&get_vault_signer(), sender_addr, key_cost);
        coin::transfer<aptos_coin::AptosCoin>(sender, get_protocol_fee_collector(), protocol_fee);
        coin::transfer<aptos_coin::AptosCoin>(sender, issuer_addr, issuer_fee);

        event::emit(
            SellKeyEvent {
                issuer_addr,
                issuer_obj: get_issuer_obj(issuer_addr),
                seller_addr: sender_addr,
                seller_user_obj: get_user_obj(sender_addr),
                amount,
                key_cost,
                issuer_fee,
                protocol_fee,
                total_cost,
            }
        );
    }

    // ================================= View Functions ================================== //

    #[view]
    public fun get_vault_addr(): address {
        object::create_object_address(&@friend_tech_addr, VAULT_SEED)
    }

    #[view]
    public fun get_vault_obj(): object::Object<Vault> {
        object::address_to_object<>(get_vault_addr())
    }

    #[view]
    public fun get_protocol_fee_collector(): address acquires Config {
        let config = borrow_global<Config>(@friend_tech_addr);
        config.protocol_fee_collector
    }

    #[view]
    public fun get_issuer_registry(): vector<object::Object<Issuer>> acquires IssuerRegistry {
        let registry = borrow_global<IssuerRegistry>(@friend_tech_addr);
        registry.issuers
    }

    #[view]
    public fun get_issuer_obj_addr(issuer_addr: address): address {
        object::create_object_address(&issuer_addr, construct_issuer_object_seed(issuer_addr))
    }

    #[view]
    public fun get_user_obj_addr(user_addr: address): address {
        object::create_object_address(&user_addr, construct_user_object_seed(user_addr))
    }

    #[view]
    public fun get_holding_obj_addr(issuer_addr: address, holder_addr: address): address {
        object::create_object_address(&issuer_addr, construct_holding_object_seed(issuer_addr, holder_addr))
    }

    #[view]
    public fun get_issuer_obj(issuer_addr: address): object::Object<Issuer> {
        object::address_to_object<>(get_issuer_obj_addr(issuer_addr))
    }

    #[view]
    public fun get_user_obj(user_addr: address): object::Object<User> {
        object::address_to_object(get_user_obj_addr(user_addr))
    }

    #[view]
    public fun get_holding_obj(issuer_addr: address, holder_addr: address): object::Object<Holding> {
        object::address_to_object<>(get_holding_obj_addr(issuer_addr, holder_addr))
    }

    #[view]
    public fun calculate_buy_key_cost(issuer_addr: address, amount: u64): (u64, u64, u64, u64) acquires Issuer {
        let issuer_obj_addr = get_issuer_obj_addr(issuer_addr);
        let issuer = borrow_global<Issuer>(issuer_obj_addr);
        let old_share = issuer.total_issued_shares;

        let key_cost = calculate_key_cost(old_share, amount);
        let issuer_fee = key_cost * 5 / 100;
        let protocol_fee = key_cost * 5 / 100;
        let total_cost = key_cost + issuer_fee + protocol_fee;

        (key_cost, issuer_fee, protocol_fee, total_cost)
    }

    #[view]
    public fun calculate_sell_key_cost(issuer_addr: address, amount: u64): (u64, u64, u64, u64) acquires Issuer {
        let issuer_obj_addr = get_issuer_obj_addr(issuer_addr);
        let issuer = borrow_global<Issuer>(issuer_obj_addr);
        let old_share = issuer.total_issued_shares;

        let key_cost = calculate_key_cost(old_share - amount, amount);
        let issuer_fee = key_cost * 5 / 100;
        let protocol_fee = key_cost * 5 / 100;
        let total_cost = issuer_fee + protocol_fee;

        (key_cost, issuer_fee, protocol_fee, total_cost)
    }

    // ================================= Helper functions ================================== //

    fun get_vault_signer(): signer acquires Vault {
        let vault = borrow_global<Vault>(get_vault_addr());
        object::generate_signer_for_extending(&vault.extend_ref)
    }

    fun construct_issuer_object_seed(issuer_addr: address): vector<u8> {
        bcs::to_bytes(&string_utils::format2(&b"{}_issuer_{}", @friend_tech_addr, issuer_addr))
    }

    fun construct_user_object_seed(user_addr: address): vector<u8> {
        bcs::to_bytes(&string_utils::format2(&b"{}_user_{}", @friend_tech_addr, user_addr))
    }

    fun construct_holding_object_seed(issuer_addr: address, holder_addr: address): vector<u8> {
        bcs::to_bytes(
            &string_utils::format3(
                &b"{}_key_issued_by_{}_hold_by_{}",
                @friend_tech_addr,
                issuer_addr,
                holder_addr,
            )
        )
    }

    fun get_oct_per_aptos(): u64 {
        math64::pow(10, (coin::decimals<aptos_coin::AptosCoin>() as u64))
    }

    fun calculate_key_cost(supply: u64, amount: u64): u64 {
        let temp1 = supply - 1;
        let temp2 = 2 * temp1 + 1;
        let sum1 = temp1 * supply * temp2 / 6;

        let temp3 = temp1 + amount;
        let temp4 = supply + amount;
        let temp5 = 2 * temp3 + 1;
        let sum2 = temp3 * temp4 * temp5 / 6;

        let summation = sum2 - sum1;

        let key_cost = summation * get_oct_per_aptos() / 16000;
        key_cost
    }

    // ================================= Tests ================================== //

    #[test(sender = @launchpad_addr, protocol_fee_collector = 0x998)]
    fun test_happy_path(sender: &signer, protocol_fee_collector: address) {
        let sender_addr = signer::address_of(sender);
        init_module(sender, protocol_fee_collector);
    }
}