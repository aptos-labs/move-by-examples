module aptos_friend_addr::aptos_friend {
    use std::bcs;
    use std::signer;
    use std::string::String;
    use std::vector;

    use aptos_std::math64;
    use aptos_std::string_utils;

    use aptos_framework::aptos_account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;
    use aptos_framework::object::{Self, Object, ExtendRef};

    /// User already issued share
    const ERR_USER_ALREADY_ISSUED_SHARE: u64 = 1;
    /// Insufficient balance
    const ERR_INSUFFICIENT_BALANCE: u64 = 2;
    /// Holding does not exist
    const ERR_HOLDING_NOT_EXIST: u64 = 3;
    /// User does not exist
    const ERR_USER_NOT_EXIST: u64 = 4;
    /// Holder does not exist
    const ERR_HOLDER_NOT_EXIST: u64 = 5;
    /// Not enough shares to sell
    const ERR_NOT_ENOUGH_SHARES_TO_SELL: u64 = 6;
    /// Issuer cannot sell last share
    const ERR_ISSUER_CANNOT_SELL_LAST_SHARE: u64 = 7;

    const VAULT_SEED: vector<u8> = b"vault";

    /// Holding stores the share issuer, holder and the number of shares held
    struct Holding has key {
        issuer: address,
        holder: address,
        shares: u64,
    }

    /// User stores the holdings of the user, anyone who bought shares will have a User object
    struct User has key {
        holdings: vector<Object<Holding>>,
    }

    /// Issuer stores the issuer's address, username, total issued shares and the holder holdings
    /// Only users who called issue_share will have an Issuer object
    struct Issuer has key {
        addr: address,
        username: String,
        total_issued_shares: u64,
        holder_holdings: vector<Object<Holding>>,
    }

    /// IssuerRegistry stores the list of issuers
    /// This can be replaced with an off-chain indexer for efficiency
    struct IssuerRegistry has key {
        issuers: vector<Object<Issuer>>
    }

    /// Vault stores the APT to be sent to sellers
    struct Vault has key {
        extend_ref: ExtendRef,
    }

    #[event]
    struct IssueShareEvent has store, drop {
        issuer_addr: address,
        issuer_obj: Object<Issuer>,
        username: String,
    }

    #[event]
    struct BuyShareEvent has store, drop {
        issuer_addr: address,
        issuer_obj: Object<Issuer>,
        buyer_addr: address,
        buyer_user_obj: Object<User>,
        amount: u64,
        share_cost: u64,
        issuer_fee: u64,
        protocol_fee: u64,
        total_cost: u64,
    }

    #[event]
    struct SellShareEvent has store, drop {
        issuer_addr: address,
        issuer_obj: Object<Issuer>,
        seller_addr: address,
        seller_user_obj: Object<User>,
        amount: u64,
        share_cost: u64,
        issuer_fee: u64,
        protocol_fee: u64,
        total_cost: u64,
    }

    // If you deploy the module under an object, sender is the object's signer
    // If you deploy the moduelr under your own account, sender is your account's signer
    fun init_module(sender: &signer) {
        let vault_constructor_ref = &object::create_named_object(sender, VAULT_SEED);
        let vault_signer = &object::generate_signer(vault_constructor_ref);

        move_to(vault_signer, Vault {
            extend_ref: object::generate_extend_ref(vault_constructor_ref),
        });
        move_to(sender, IssuerRegistry {
            issuers: vector::empty()
        });
    }

    // ================================= Entry Functions ================================= //

    /// Anyone can call once, to start issuing shares
    /// This will also issue 1 share to the issuer
    /// So after this function has called, there is 1 share holder which is the issuer
    public entry fun issue_share(
        sender: &signer,
        username: String,
    ) acquires User, IssuerRegistry {
        let sender_addr = signer::address_of(sender);
        assert!(!exists<Issuer>(get_issuer_obj_addr(sender_addr)), ERR_USER_ALREADY_ISSUED_SHARE);
        let issuer_obj_constructor_ref = &object::create_named_object(
            sender,
            construct_issuer_object_seed(sender_addr)
        );
        let issuer_obj_signer = object::generate_signer(issuer_obj_constructor_ref);

        let holding_obj_constructor_ref = &object::create_named_object(
            sender,
            construct_holding_object_seed(sender_addr, sender_addr)
        );
        let holding_obj_signer = object::generate_signer(holding_obj_constructor_ref);

        move_to(&holding_obj_signer, Holding {
            issuer: sender_addr,
            holder: sender_addr,
            shares: 1,
        });

        move_to(&issuer_obj_signer, Issuer {
            addr: sender_addr,
            username,
            total_issued_shares: 1,
            holder_holdings: vector[get_holding_obj(sender_addr, sender_addr)],
        });

        if (exists<User>(get_user_obj_addr(sender_addr))) {
            let user_obj = borrow_global_mut<User>(get_user_obj_addr(sender_addr));
            vector::push_back(&mut user_obj.holdings, get_holding_obj(sender_addr, sender_addr));
        } else {
            let user_obj_constructor_ref = &object::create_named_object(
                sender,
                construct_user_object_seed(sender_addr)
            );
            let user_obj_signer = object::generate_signer(user_obj_constructor_ref);
            move_to(&user_obj_signer, User {
                holdings: vector[get_holding_obj(sender_addr, sender_addr)],
            });
        };

        let registry = borrow_global_mut<IssuerRegistry>(@aptos_friend_addr);
        vector::push_back(&mut registry.issuers, get_issuer_obj(sender_addr));

        event::emit(IssueShareEvent {
            issuer_addr: sender_addr,
            issuer_obj: get_issuer_obj(sender_addr),
            username,
        });
    }

    /// Anyone can call, buy shares of an issuer
    public entry fun buy_share(
        sender: &signer,
        issuer_obj: Object<Issuer>,
        amount: u64,
    ) acquires Issuer, Holding, User {
        let sender_addr = signer::address_of(sender);
        let (share_cost, issuer_fee, protocol_fee, total_cost) = calculate_buy_share_cost(issuer_obj, amount);
        assert!(coin::balance<AptosCoin>(sender_addr) >= total_cost, ERR_INSUFFICIENT_BALANCE);

        let issuer = borrow_global_mut<Issuer>(object::object_address(&issuer_obj));
        let issuer_addr = issuer.addr;
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
                issuer: issuer_addr,
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
                    construct_user_object_seed(sender_addr)
                );
                let buyer_obj_signer = object::generate_signer(buyer_obj_constructor_ref);
                move_to(&buyer_obj_signer, User {
                    holdings: vector[get_holding_obj(issuer_addr, sender_addr)],
                });
            };
        };

        aptos_account::transfer(sender, get_vault_addr(), share_cost);
        aptos_account::transfer(sender, @aptos_friend_addr, protocol_fee);
        aptos_account::transfer(sender, issuer_addr, issuer_fee);

        event::emit(
            BuyShareEvent {
                issuer_addr,
                issuer_obj: get_issuer_obj(issuer_addr),
                buyer_addr: sender_addr,
                buyer_user_obj: get_user_obj(sender_addr),
                amount,
                share_cost,
                issuer_fee,
                protocol_fee,
                total_cost,
            }
        );
    }

    /// Anyone can call, sell shares of an issuer
    public entry fun sell_share(
        sender: &signer,
        issuer_obj: Object<Issuer>,
        amount: u64,
    ) acquires Issuer, Holding, User, Vault {
        let sender_addr = signer::address_of(sender);
        let (share_cost, issuer_fee, protocol_fee, total_cost) = calculate_sell_share_cost(issuer_obj, amount);
        assert!(coin::balance<AptosCoin>(sender_addr) >= total_cost, ERR_INSUFFICIENT_BALANCE);

        let issuer = borrow_global_mut<Issuer>(object::object_address(&issuer_obj));
        let issuer_addr = issuer.addr;

        let holding_obj_addr = get_holding_obj_addr(issuer_addr, sender_addr);
        assert!(exists<Holding>(holding_obj_addr), ERR_HOLDING_NOT_EXIST);

        let user_obj_addr = get_user_obj_addr(sender_addr);
        assert!(exists<User>(user_obj_addr), ERR_USER_NOT_EXIST);

        issuer.total_issued_shares = issuer.total_issued_shares - amount;

        let seller = borrow_global_mut<User>(user_obj_addr);

        let holding = borrow_global_mut<Holding>(holding_obj_addr);
        assert!(holding.shares >= amount, ERR_NOT_ENOUGH_SHARES_TO_SELL);
        assert!(sender_addr != issuer_addr || holding.shares > amount, ERR_ISSUER_CANNOT_SELL_LAST_SHARE);

        holding.shares = holding.shares - amount;

        let holding_obj = get_holding_obj(issuer_addr, sender_addr);

        if (holding.shares == 0) {
            let (found, idx) = vector::index_of(&mut issuer.holder_holdings, &holding_obj);
            assert!(found, ERR_HOLDER_NOT_EXIST);
            vector::remove(&mut issuer.holder_holdings, idx);

            let (found, idx) = vector::index_of(&mut seller.holdings, &holding_obj);
            assert!(found, ERR_HOLDING_NOT_EXIST);
            vector::remove(&mut seller.holdings, idx);
        };

        aptos_account::transfer(&get_vault_signer(), sender_addr, share_cost);
        aptos_account::transfer(sender, @aptos_friend_addr, protocol_fee);
        aptos_account::transfer(sender, issuer_addr, issuer_fee);

        event::emit(
            SellShareEvent {
                issuer_addr,
                issuer_obj: get_issuer_obj(issuer_addr),
                seller_addr: sender_addr,
                seller_user_obj: get_user_obj(sender_addr),
                amount,
                share_cost,
                issuer_fee,
                protocol_fee,
                total_cost,
            }
        );
    }

    // ================================= View Functions ================================== //

    #[view]
    /// Get vault address
    public fun get_vault_addr(): address {
        object::create_object_address(&@aptos_friend_addr, VAULT_SEED)
    }

    #[view]
    /// Get issuer registry
    public fun get_issuer_registry(): vector<Object<Issuer>> acquires IssuerRegistry {
        let registry = borrow_global<IssuerRegistry>(@aptos_friend_addr);
        registry.issuers
    }

    #[view]
    /// Check if user has issued share
    public fun has_issued_share(user_addr: address): bool {
        exists<Issuer>(get_issuer_obj_addr(user_addr))
    }

    #[view]
    /// Get issuer object address
    public fun get_issuer_obj_addr(issuer_addr: address): address {
        let seed = construct_issuer_object_seed(issuer_addr);
        object::create_object_address(&issuer_addr, seed)
    }

    #[view]
    /// Get user object address
    public fun get_user_obj_addr(user_addr: address): address {
        let seed = construct_user_object_seed(user_addr);
        object::create_object_address(&user_addr, seed)
    }

    #[view]
    /// Get holding object address
    public fun get_holding_obj_addr(issuer_addr: address, holder_addr: address): address {
        let seed = construct_holding_object_seed(issuer_addr, holder_addr);
        object::create_object_address(&holder_addr, seed)
    }

    #[view]
    /// Get issuer object
    public fun get_issuer_obj(issuer_addr: address): Object<Issuer> {
        object::address_to_object(get_issuer_obj_addr(issuer_addr))
    }

    #[view]
    /// Get user object
    public fun get_user_obj(user_addr: address): Object<User> {
        object::address_to_object(get_user_obj_addr(user_addr))
    }

    #[view]
    /// Get holding object
    public fun get_holding_obj(issuer_addr: address, holder_addr: address): Object<Holding> {
        object::address_to_object(get_holding_obj_addr(issuer_addr, holder_addr))
    }

    #[view]
    /// Get issuer
    public fun get_issuer(
        issuer_obj: Object<Issuer>
    ): (address, String, u64) acquires Issuer {
        let issuer = borrow_global<Issuer>(object::object_address(&issuer_obj));
        (issuer.addr, issuer.username, issuer.total_issued_shares)
    }

    #[view]
    /// Get issuer's holder holdings
    public fun get_issuer_holder_holdings(issuer_obj: Object<Issuer>): vector<Object<Holding>> acquires Issuer {
        let issuer = borrow_global<Issuer>(object::object_address(&issuer_obj));
        issuer.holder_holdings
    }

    #[view]
    /// Get user's holdings
    public fun get_user_holdings(user_obj: Object<User>): vector<Object<Holding>> acquires User {
        let user = borrow_global<User>(object::object_address(&user_obj));
        user.holdings
    }

    #[view]
    /// Get holding
    public fun get_holding(holding_obj: Object<Holding>): (address, address, u64) acquires Holding {
        let holding = borrow_global<Holding>(object::object_address(&holding_obj));
        (holding.issuer, holding.holder, holding.shares)
    }

    #[view]
    /// Calculate buy share cost
    public fun calculate_buy_share_cost(issuer_obj: Object<Issuer>, amount: u64): (u64, u64, u64, u64) acquires Issuer {
        let issuer_obj_addr = object::object_address(&issuer_obj);
        let issuer = borrow_global<Issuer>(issuer_obj_addr);
        let old_supply = issuer.total_issued_shares;

        let share_cost = calculate_share_cost(old_supply, amount);
        let issuer_fee = share_cost * 5 / 100;
        let protocol_fee = share_cost * 5 / 100;
        let total_cost = share_cost + issuer_fee + protocol_fee;

        (share_cost, issuer_fee, protocol_fee, total_cost)
    }

    #[view]
    /// Calculate sell share cost
    public fun calculate_sell_share_cost(
        issuer_obj: Object<Issuer>,
        amount: u64
    ): (u64, u64, u64, u64) acquires Issuer {
        let issuer_obj_addr = object::object_address(&issuer_obj);
        let issuer = borrow_global<Issuer>(issuer_obj_addr);
        let old_supply = issuer.total_issued_shares;

        let share_cost = calculate_share_cost(old_supply - amount, amount);
        let issuer_fee = share_cost * 5 / 100;
        let protocol_fee = share_cost * 5 / 100;
        let total_cost = issuer_fee + protocol_fee;

        (share_cost, issuer_fee, protocol_fee, total_cost)
    }

    // ================================= Helper functions ================================== //

    /// Generate vault signer to send APT to sellers
    fun get_vault_signer(): signer acquires Vault {
        let vault = borrow_global<Vault>(get_vault_addr());
        object::generate_signer_for_extending(&vault.extend_ref)
    }

    /// Construct issuer object seed
    fun construct_issuer_object_seed(issuer_addr: address): vector<u8> {
        bcs::to_bytes(&string_utils::format2(&b"{}_issuer_{}", @aptos_friend_addr, issuer_addr))
    }

    /// Construct user object seed
    fun construct_user_object_seed(user_addr: address): vector<u8> {
        bcs::to_bytes(&string_utils::format2(&b"{}_user_{}", @aptos_friend_addr, user_addr))
    }

    /// Construct holding object seed
    fun construct_holding_object_seed(issuer_addr: address, holder_addr: address): vector<u8> {
        bcs::to_bytes(
            &string_utils::format3(
                &b"{}_share_issued_by_{}_hold_by_{}",
                @aptos_friend_addr,
                issuer_addr,
                holder_addr,
            )
        )
    }

    /// Get APT in smallest unit
    fun get_oct_per_aptos(): u64 {
        math64::pow(10, (coin::decimals<AptosCoin>() as u64))
    }

    /// Calculate share cost
    fun calculate_share_cost(supply: u64, amount: u64): u64 {
        let temp1 = supply - 1;
        let temp2 = 2 * temp1 + 1;
        let sum1 = temp1 * supply * temp2 / 6;

        let temp3 = temp1 + amount;
        let temp4 = supply + amount;
        let temp5 = 2 * temp3 + 1;
        let sum2 = temp3 * temp4 * temp5 / 6;

        let summation = sum2 - sum1;

        let share_cost = summation * get_oct_per_aptos() / 16000;
        share_cost
    }

    // ================================= Uint Tests Helper ================================== //

    #[test_only]
    use aptos_framework::aptos_coin;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::coin::{BurnCapability, MintCapability};

    #[test_only]
    public fun init_module_for_test(
        aptos_framework: &signer,
        sender: &signer
    ): (BurnCapability<AptosCoin>, MintCapability<AptosCoin>) {
        init_module(sender);

        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);

        let deployer_addr = signer::address_of(sender);
        account::create_account_for_test(deployer_addr);
        coin::register<AptosCoin>(sender);

        (burn_cap, mint_cap)
    }
}
