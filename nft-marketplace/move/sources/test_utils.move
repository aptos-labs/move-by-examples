#[test_only]
module marketplace_addr::test_utils {
    use std::signer;
    use std::string;
    use std::vector;
    use aptos_framework::account;
    use aptos_framework::aptos_coin;
    use aptos_framework::coin;
    use aptos_framework::object;
    use aptos_token_objects::token;
    use aptos_token_objects::aptos_token;
    use aptos_token_objects::collection;
    use marketplace_addr::marketplace;

    public inline fun setup(
        aptos_framework: &signer,
        marketplace: &signer,
        seller: &signer,
        purchaser: &signer,
    ): (address, address, address) {
        marketplace::setup_test(marketplace);
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos_framework);

        let marketplace_addr = signer::address_of(marketplace);
        account::create_account_for_test(marketplace_addr);
        coin::register<aptos_coin::AptosCoin>(marketplace);

        let seller_addr = signer::address_of(seller);
        account::create_account_for_test(seller_addr);
        coin::register<aptos_coin::AptosCoin>(seller);

        let purchaser_addr = signer::address_of(purchaser);
        account::create_account_for_test(purchaser_addr);
        coin::register<aptos_coin::AptosCoin>(purchaser);

        let coins = coin::mint(10000, &mint_cap);
        coin::deposit(seller_addr, coins);
        let coins = coin::mint(10000, &mint_cap);
        coin::deposit(purchaser_addr, coins);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);

        (marketplace_addr, seller_addr, purchaser_addr)
    }

    public fun mint_tokenv2_with_collection(seller: &signer): (object::Object<collection::Collection>, object::Object<token::Token>) {
        let collection_name = string::utf8(b"collection_name");

        let collection_object = aptos_token::create_collection_object(
            seller,
            string::utf8(b"collection description"),
            2,
            collection_name,
            string::utf8(b"collection uri"),
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            1,
            100,
        );

        let aptos_token = aptos_token::mint_token_object(
            seller,
            collection_name,
            string::utf8(b"description"),
            string::utf8(b"token_name"),
            string::utf8(b"uri"),
            vector::empty(),
            vector::empty(),
            vector::empty(),
        );
        (object::convert(collection_object), object::convert(aptos_token))
    }

    public fun mint_tokenv2(seller: &signer): object::Object<token::Token> {
        let (_collection, token) = mint_tokenv2_with_collection(seller);
        token
    }
}