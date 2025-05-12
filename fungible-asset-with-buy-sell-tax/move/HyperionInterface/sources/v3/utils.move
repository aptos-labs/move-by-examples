module hyperion_interface_addr::utils {
    use aptos_std::comparator;
    use std::string::{Self, String};
    use aptos_framework::object::{Self, Object};
    use aptos_framework::fungible_asset::{Self, Metadata};

    const EIDENTICAL_TOKENS: u64 = 130001;

    #[view]
    public fun is_sorted(
        token_1: Object<Metadata>, token_2: Object<Metadata>
    ): bool {
        let token_1_addr = object::object_address(&token_1);
        let token_2_addr = object::object_address(&token_2);
        let result = comparator::compare(&token_1_addr, &token_2_addr);
        assert!(!result.is_equal(), EIDENTICAL_TOKENS);
        comparator::compare(&token_1_addr, &token_2_addr).is_smaller_than()
    }

    #[view]
    public fun lp_token_name(
        token_1: Object<Metadata>, token_2: Object<Metadata>
    ): String {
        let token_symbol = string::utf8(b"LP-");
        token_symbol.append(fungible_asset::symbol(token_1));
        token_symbol.append_utf8(b"-");
        token_symbol.append(fungible_asset::symbol(token_2));
        token_symbol
    }

    #[view]
    public fun u64x64_to_u64(num: u128): u64 {
        (num >> 64 as u64)
    }

    #[view]
    public fun u64_to_u64x64(num: u64): u128 {
        (num as u128) << 64
    }
}
