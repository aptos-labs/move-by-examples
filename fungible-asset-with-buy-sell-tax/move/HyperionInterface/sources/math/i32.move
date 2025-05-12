module hyperion_interface_addr::i32 {
    const EOverflow: u64 = 0;

    const MIN_AS_U32: u32 = 1 << 31;
    const MAX_AS_U32: u32 = 0x7fffffff;

    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    struct I32 has copy, drop, store {
        bits: u32
    }

    struct I32_RES has copy, drop {
        sign: bool,
        value: u32
    }

    public fun zero(): I32 {
        I32 { bits: 0 }
    }

    public fun as_u32(_v: I32): u32 {
        0
    }

    public fun from_u32(v: u32): I32 {
        I32 { bits: v }
    }
}
