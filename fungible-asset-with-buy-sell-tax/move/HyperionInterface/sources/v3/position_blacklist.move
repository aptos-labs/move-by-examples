module hyperion_interface_addr::position_blacklist {
    use aptos_std::smart_vector::{SmartVector};

    struct PositionBlackList has store {
        addresses: SmartVector<address>
    }

    const EALREADY_ADDED: u64 = 140001;
    const ENOT_CONTAINTED: u64 = 140002;
}
