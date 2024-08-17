script {
    use std::signer;
    use std::string;

    use aptos_friend_addr::aptos_friend;

    // This Move script runs atomically, i.e. it issues a share and buys some of it in the same transaction.
    // Move script is how we batch multiple function calls in 1 tx, similar to Solana allows multiple instructions in 1 tx
    fun issue_share_and_buy_share(sender: &signer) {
        let sender_addr = signer::address_of(sender);
        // issue my share
        aptos_friend::issue_share(sender, string::utf8(b"user_1"));
        let issuer_obj = aptos_friend::get_issuer_obj(sender_addr);
        // buy 10 shares of my own share
        aptos_friend::buy_share(sender, issuer_obj, 10);
    }
}
