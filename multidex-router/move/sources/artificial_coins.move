module multidex_router_addr::artificial_coins {
    use std::signer;
    use std::string::utf8;
    use aptos_framework::coin::{Self, MintCapability, BurnCapability};

    struct AT {}
    struct BT {}

    struct Caps<phantom CoinType> has key {
        mint: MintCapability<CoinType>,
        burn: BurnCapability<CoinType>,
    }

    public entry fun register_coins(owner: &signer) {
        let (at_b, at_f, at_m) = coin::initialize<AT>(owner, utf8(b"TokenA"), utf8(b"AT"), 8, true);
        let (bt_b, bt_f, bt_m) = coin::initialize<BT>(owner, utf8(b"TokenB"), utf8(b"BT"), 8, true);

        coin::destroy_freeze_cap(at_f);
        coin::destroy_freeze_cap(bt_f);

        move_to(owner, Caps<AT> {mint: at_m, burn: at_b});
        move_to(owner, Caps<BT> {mint: bt_m, burn: bt_b});
    }

    public entry fun mint_coin<CoinType>(owner: &signer, acc_addr: address, amount: u64) acquires Caps {
        let owner_addr = signer::address_of(owner);
        let caps = borrow_global<Caps<CoinType>>(owner_addr);
        let coins = coin::mint<CoinType>(amount, &caps.mint);
        coin::deposit(acc_addr, coins);
    }
}