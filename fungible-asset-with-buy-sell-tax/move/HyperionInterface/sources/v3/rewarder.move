module hyperion_interface_addr::rewarder {

    use aptos_framework::object::{Object};
    use aptos_framework::fungible_asset::{FungibleStore, Metadata};

    const EINSUFICIEENT_BALANCE: u64 = 1100001;
    const EINVALID_EMISSION_RATE: u64 = 11000002;
    const EREWARDS_LENGTH_ERR: u64 = 1100003;
    const EREWARD_TOO_LESS_TO_REMOVE: u64 = 1100004;
    const EREWARD_PAUSED: u64 = 1100005;

    struct RewarderManager has store {
        rewarders: vector<Rewarder>,
        last_updated_time: u64,
        pause: bool
    }

    struct Rewarder has copy, drop, store {
        reward_store: Object<FungibleStore>,
        emissions_per_second: u64,
        emissions_per_second_max: u64,
        emissions_per_liquidity_start: u128,
        emissions_per_liquidity_latest: u128,
        user_owed: u64,
        pause: bool
    }

    /// The Position's rewarder record
    struct PositionReward has drop, copy, store {
        emissions_per_liquidity_inside: u128,
        amount_owned: u64
    }

    #[event]
    struct CreateRewarderEvent has drop, store {
        pool_id: address,
        reward_fa: Object<Metadata>,
        emissions_per_second: u64,
        emissions_per_second_max: u64,
        emissions_per_liquidity_start: u128,
        index: u64
    }

    #[event]
    struct AddIncentiveEvent has drop, store {
        pool_id: address,
        reward_metadata: Object<Metadata>,
        amount: u64,
        index: u64
    }

    #[event]
    struct RemoveIncentiveEvent has drop, store {
        pool_id: address,
        reward_metadata: Object<Metadata>,
        amount: u64,
        index: u64
    }

    #[event]
    struct ClaimRewardsEvent has drop, store {
        pool_id: address,
        position_id: address,
        reward_fa: Object<Metadata>,
        amount: u64,
        owner: address,
        index: u64
    }

    #[event]
    struct RewardEmissionUpdateEvent has drop, store {
        pool_id: address,
        reward_fa: Object<Metadata>,
        old_emission_rate: u64,
        new_emission_rate: u64,
        index: u64
    }

    struct PendingReward has drop, copy {
        reward_fa: Object<Metadata>,
        amount_owed: u64
    }

    struct RewardRate {
        reward_fa: Object<Metadata>,
        rate: u128
    }

    public fun pending_rewards_unpack(info: &PendingReward): (Object<Metadata>, u64) {
        (info.reward_fa, info.amount_owed)
    }
}
