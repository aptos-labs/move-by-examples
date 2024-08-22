module counter_app_addr::counter_app {
    use std::signer;

    struct Counter has key {
        count: u64
    }

    /// If you deploy the module under an object, sender is the object's signer
    /// If you deploy the module under your own account, sender is your account's signer
    fun init_module(_sender: &signer) {}

    public entry fun click(sender: &signer) acquires Counter {
        let sender_addr = signer::address_of(sender);
        if (!exists<Counter>(sender_addr)) {
            move_to(sender, Counter {
                count: 0
            })
        };
        let counter = borrow_global_mut<Counter>(sender_addr);
        counter.count = counter.count + 1
    }

    #[view]
    public fun count(user_addr: address): u64 acquires Counter {
        let counter = borrow_global<Counter>(user_addr);
        counter.count
    }
}
