module hyperion_interface_addr::tick {

    use hyperion_interface_addr::i32::{I32};
    use hyperion_interface_addr::i128::{I128};

    struct TickInfo has store, copy, drop {
        // the total position liquidity that references this tick
        liquidity_gross: u128,
        // amount of net liquidity added (subtracted) when tick is crossed from left to right (right to left),
        liquidity_net: I128,
        // fee growth per unit of liquidity on the _other_ side of this tick (relative to the current tick)
        // only has relative meaning, not absolute the value depends on when the tick is initialized
        fee_growth_outside_a: u128,
        fee_growth_outside_b: u128,
        // the cumulative tick value on the other side of the tick
        tick_cumulative_outside: u64,
        // the seconds per unit of liquidity on the _other_ side of this tick (relative to the current tick)
        // only has relative meaning, not absolute the value depends on when the tick is initialized
        seconds_per_liquidity_oracle_outside: u128,
        seconds_per_liquidity_incentive_outside: u128,
        emissions_per_liquidity_incentive_outside: vector<u128>,
        // the seconds spent on the other side of the tick (relative to the current tick)
        // only has relative meaning, not absolute the value depends on when the tick is initialized
        seconds_outside: u64,
        // true iff the tick is initialized, i.e. the value is exactly equivalent to the expression liquidityGross != 0
        // these 8 bits are set to prevent fresh sstores when crossing newly initialized ticks
        initialized: bool
    }

    #[event]
    struct TickUpdatedEvent has store, drop {
        tick: I32,
        liquidity_gross_before: u128,
        liquidity_gross_after: u128,
        liquidity_net_before: I128,
        liquidity_net_after: I128,
        flipped: bool,
        fee_growth_updated: bool,
        fee_growth_outside_a_before: u128,
        fee_growth_outside_b_before: u128,
        emissions_per_liquidity_incentive_outside_before: vector<u128>
    }
}
