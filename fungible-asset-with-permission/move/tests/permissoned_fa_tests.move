#[test_only]
module permissioned_fa_addr::permissioned_fa_tests {
    use permissioned_fa_addr::permissioned_fa;

    use aptos_framework::primary_fungible_store;

    use std::signer;

    #[test(deployer = @permissioned_fa_addr, user1 = @0x11, user2 = @0x12)]
    #[
        expected_failure(
            abort_code = permissioned_fa::ERR_BLOCKED, location = permissioned_fa
        )
    ]
    fun test_basic_flow(
        deployer: &signer, user1: &signer, user2: &signer
    ) {
        permissioned_fa::init_for_test(deployer);

        let user1_addr = signer::address_of(user1);
        let user2_addr = signer::address_of(user2);

        let asset = permissioned_fa::metadata();

        // Mint 1000 assets to the user1's account.
        permissioned_fa::mint(deployer, user1_addr, 1000);
        // Transfer 500 assets from the user1's account to user2's account.
        primary_fungible_store::transfer(user1, asset, user2_addr, 500);

        // Check the balances.
        let deployer_balance =
            primary_fungible_store::balance(@permissioned_fa_addr, asset);
        let user1_balance = primary_fungible_store::balance(user1_addr, asset);
        let user2_balance = primary_fungible_store::balance(user2_addr, asset);
        assert!(deployer_balance == 0, 0);
        assert!(user1_balance == 500, 1);
        assert!(user2_balance == 500, 2);

        // Burn 100 assets from user2's account.
        permissioned_fa::burn(deployer, user2_addr, 100);
        let user2_balance = primary_fungible_store::balance(user2_addr, asset);
        assert!(user2_balance == 400, 3);

        // add user2 to the blocklist
        permissioned_fa::update_blocklist(deployer, user2_addr, true);
        // Try to transfer from user1 to user2, which should fail due to blocklist.
        primary_fungible_store::transfer(user1, asset, user2_addr, 100);
    }

    #[test(deployer = @permissioned_fa_addr, user1 = @0x11)]
    #[
        expected_failure(
            abort_code = permissioned_fa::ERR_UNAUTHORIZED, location = permissioned_fa
        )
    ]
    fun only_admin_can_update_blocklist(
        deployer: &signer, user1: &signer
    ) {
        permissioned_fa::init_for_test(deployer);
        permissioned_fa::update_blocklist(user1, @0x12, true);
    }
}
