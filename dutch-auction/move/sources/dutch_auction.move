module dutch_auction_address::dutch_auction {
    use std::error;
    use std::string::{Self, String};
    use std::option;
    use std::signer;
    use std::vector;
    use aptos_framework::event;
    use aptos_framework::object::{Self, Object, TransferRef};
    use aptos_framework::fungible_asset::{Metadata};
    use aptos_framework::primary_fungible_store;
    use aptos_framework::timestamp;
    use aptos_token_objects::collection;
    use aptos_token_objects::collection::Collection;
    use aptos_token_objects::token::{Self, Token};

    const ENOT_OWNER: u64 = 1;
    const ETOKEN_SOLD: u64 = 2;
    const EINVALID_AUCTION_OBJECT: u64 = 3;
    const EOUTDATED_AUCTION: u64 = 4;
    const EINVALID_PRICES: u64 = 5;
    const EINVALID_DURATION: u64 = 6;

    const DUTCH_AUCTION_COLLECTION_NAME: vector<u8> = b"DUTCH_AUCTION_NAME";
    const DUTCH_AUCTION_COLLECTION_DESCRIPTION: vector<u8> = b"DUTCH_AUCTION_DESCRIPTION";
    const DUTCH_AUCTION_COLLECTION_URI: vector<u8> = b"DUTCH_AUCTION_URI";

    const DUTCH_AUCTION_SEED_PREFIX: vector<u8> = b"AUCTION_SEED_PREFIX";

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Auction has key {
        sell_token: Object<Token>,
        buy_token: Object<Metadata>,
        max_price: u64,
        min_price: u64,
        duration: u64,
        started_at: u64
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct TokenConfig has key, drop {
        transfer_ref: TransferRef
    }

    #[event]
    struct AuctionCreated has drop, store {
        auction: Object<Auction>
    }

    fun init_module(creator: &signer) {
        let description = string::utf8(DUTCH_AUCTION_COLLECTION_DESCRIPTION);
        let name = string::utf8(DUTCH_AUCTION_COLLECTION_NAME);
        let uri = string::utf8(DUTCH_AUCTION_COLLECTION_URI);

        collection::create_unlimited_collection(
            creator,
            description,
            name,
            option::none(),
            uri,
        );
    }

    entry public fun start_auction(
        owner: &signer,
        token_name: String,
        token_description: String,
        token_uri: String,
        buy_token: Object<Metadata>,
        max_price: u64,
        min_price: u64,
        duration: u64
    ) {
        only_owner(owner);

        assert!(max_price >= min_price, error::invalid_argument(EINVALID_PRICES));
        assert!(duration > 0, error::invalid_argument(EINVALID_DURATION));

        let collection_name = string::utf8(DUTCH_AUCTION_COLLECTION_NAME);

        let sell_token_ctor = token::create_named_token(
            owner,
            collection_name,
            token_description,
            token_name,
            option::none(),
            token_uri,
        );
        let transfer_ref = object::generate_transfer_ref(&sell_token_ctor);
        let sell_token = object::object_from_constructor_ref<Token>(&sell_token_ctor);

        let auction = Auction {
            sell_token,
            buy_token,
            max_price,
            min_price,
            duration,
            started_at: timestamp::now_seconds()
        };

        let auction_seed = get_auction_seed(token_name);
        let auction_ctor = object::create_named_object(owner, auction_seed);
        let auction_signer = object::generate_signer(&auction_ctor);

        move_to(&auction_signer, auction);
        move_to(&auction_signer, TokenConfig { transfer_ref });

        let auction = object::object_from_constructor_ref<Auction>(&auction_ctor);

        event::emit(AuctionCreated { auction });
    }

    fun get_collection_seed(): vector<u8> {
        DUTCH_AUCTION_COLLECTION_NAME
    }

    fun get_token_seed(token_name: String): vector<u8> {
        let collection_name = string::utf8(DUTCH_AUCTION_COLLECTION_NAME);

        /// concatinates collection_name::token_name
        token::create_token_seed(&collection_name, &token_name)
    }

    fun get_auction_seed(token_name: String): vector<u8> {
        let token_seed = get_token_seed(token_name);

        let seed = DUTCH_AUCTION_SEED_PREFIX;
        vector::append(&mut seed, b"::");
        vector::append(&mut seed, token_seed);

        seed
    }

    inline fun only_owner(owner: &signer) {
        assert!(signer::address_of(owner) == @dutch_auction_address, error::permission_denied(ENOT_OWNER));
    }

    entry public fun bid(customer: &signer, auction: Object<Auction>) acquires Auction, TokenConfig {
        let auction_address = object::object_address(&auction);
        let auction = borrow_global_mut<Auction>(auction_address);

        assert!(exists<TokenConfig>(auction_address), error::unavailable(ETOKEN_SOLD));

        let current_price = must_have_price(auction);

        primary_fungible_store::transfer(customer, auction.buy_token, @dutch_auction_address, current_price);

        let transfer_ref = &borrow_global_mut<TokenConfig>(auction_address).transfer_ref;
        let linear_transfer_ref = object::generate_linear_transfer_ref(transfer_ref);

        object::transfer_with_ref(linear_transfer_ref, signer::address_of(customer));

        move_from<TokenConfig>(auction_address);
    }

    fun must_have_price(auction: &Auction): u64 {
        let time_now = timestamp::now_seconds();

        assert!(time_now <= auction.started_at + auction.duration, error::unavailable(EOUTDATED_AUCTION));

        let time_passed = time_now - auction.started_at;
        let discount = ((auction.max_price - auction.min_price) * time_passed) / auction.duration;

        auction.max_price - discount
    }

    #[view]
    public fun get_auction_object(token_name: String): Object<Auction> {
        let auction_seed = get_auction_seed(token_name);
        let auction_address = object::create_object_address(&@dutch_auction_address, auction_seed);

        object::address_to_object(auction_address)
    }

    #[view]
    public fun get_collection_object(): Object<Collection> {
        let collection_seed = get_collection_seed();
        let collection_address = object::create_object_address(&@dutch_auction_address, collection_seed);

        object::address_to_object(collection_address)
    }

    #[view]
    public fun get_token_object(token_name: String): Object<Token> {
        let token_seed = get_token_seed(token_name);
        let token_object = object::create_object_address(&@dutch_auction_address, token_seed);

        object::address_to_object<Token>(token_object)
    }

    #[view]
    public fun get_auction(auction_object: Object<Auction>): Auction acquires Auction {
        let auction_address = object::object_address(&auction_object);
        let auction = borrow_global<Auction>(auction_address);

        Auction {
            sell_token: auction.sell_token,
            buy_token: auction.buy_token,
            max_price: auction.max_price,
            min_price: auction.min_price,
            duration: auction.duration,
            started_at: auction.started_at
        }
    }

    #[test(aptos_framework = @std, owner = @dutch_auction_address, customer = @0x1234)]
    fun test_auction_happy_path(
        aptos_framework: &signer,
        owner: &signer,
        customer: &signer
    ) acquires Auction, TokenConfig {
        init_module(owner);

        timestamp::set_time_has_started_for_testing(aptos_framework);
        timestamp::update_global_time_for_test_secs(1000);

        let buy_token = setup_buy_token(owner, customer);

        let token_name = string::utf8(b"token_name");
        let token_description = string::utf8(b"token_description");
        let token_uri = string::utf8(b"token_uri");
        let max_price = 10;
        let min_price = 1;
        let duration = 300;

        start_auction(
            owner,
            token_name,
            token_description,
            token_uri,
            buy_token,
            max_price,
            min_price,
            duration
        );

        let token = get_token_object(token_name);

        assert!(object::is_owner(token, @dutch_auction_address), 1);

        let auction_created_events = event::emitted_events<AuctionCreated>();
        let auction = vector::borrow(&auction_created_events, 0).auction;

        assert!(auction == get_auction_object(token_name), 1);
        assert!(primary_fungible_store::balance(signer::address_of(customer), buy_token) == 50, 1);

        bid(customer, auction);

        assert!(object::is_owner(token, signer::address_of(customer)), 1);
        assert!(primary_fungible_store::balance(signer::address_of(customer), buy_token) == 40, 1);
    }

    #[test_only]
    fun setup_buy_token(owner: &signer, customer: &signer): Object<Metadata> {
        use aptos_framework::fungible_asset;

        let ctor_ref = object::create_sticky_object(signer::address_of(owner));

        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            &ctor_ref,
            option::none<u128>(),
            string::utf8(b"token"),
            string::utf8(b"symbol"),
            0,
            string::utf8(b"icon_uri"),
            string::utf8(b"project_uri")
        );

        let metadata = object::object_from_constructor_ref<Metadata>(&ctor_ref);
        let mint_ref = fungible_asset::generate_mint_ref(&ctor_ref);

        let customer_store = primary_fungible_store::ensure_primary_store_exists(
            signer::address_of(customer),
            metadata
        );

        fungible_asset::mint_to(&mint_ref, customer_store, 50);

        metadata
    }
}
