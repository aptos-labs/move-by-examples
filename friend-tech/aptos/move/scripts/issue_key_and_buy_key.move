script {
    use std::signer;
    use std::string;
    use friend_tech_addr::friend_tech;

    fun issue_key_and_buy_key(sender: &signer) {
        let sender_addr = signer::address_of(sender);
        // issue my own key
        friend_tech::issue_key(sender, string::utf8(b"user_1"));
        // buy 10 shares of my own key
        friend_tech::buy_key(sender, sender_addr, 10);
    }
}
