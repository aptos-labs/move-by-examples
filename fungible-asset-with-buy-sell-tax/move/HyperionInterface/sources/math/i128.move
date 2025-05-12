module hyperion_interface_addr::i128 {
    const OVERFLOW: u64 = 0;

    const MIN_AS_U128: u128 = 1 << 127;
    const MAX_AS_U128: u128 = 0x7fffffffffffffffffffffffffffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I128 has copy, drop, store {
        bits: u128
    }

    public fun zero(): I128 {
        I128 { bits: 0 }
    }
}
