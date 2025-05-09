module hyperion_interface_addr::tick_bitmap {

    use aptos_std::table::{Table};

    use hyperion_interface_addr::i32::{I32};

    // u32 as tick, higher 24 bits represents words, lower 8 bits represents tick bit position
    // tick need to be
    struct BitMap has store {
        map: Table<I32, u256>
    }
}
