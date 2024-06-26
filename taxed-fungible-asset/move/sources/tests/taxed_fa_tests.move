#[test_only]
module deployer::taxed_fa_tests {
    use deployer::taxed_fa;
    use aptos_framework::primary_fungible_store;
    use std::signer;


    #[test(deployer = @0xcafe, kc = @0xfeed, aaron = @0xdead)]
    fun test_basic_flow(deployer: &signer, kc: &signer) {
        taxed_fa::init_for_test(deployer);

        let deployer_address = @0xcafe;
        let kc_address = @0xfeed;
        let aaron_address = @0xdead;
        
        let asset = taxed_fa::metadata();
        
        // Mint 1000 assets to the deployer's account.
        taxed_fa::mint(deployer, kc_address, 1000);
        // Transfer 500 assets from the deployer's account to kc's account.
        taxed_fa::transfer(kc, aaron_address, 500);
        
        // Check the balances.
        let deployer_balance = primary_fungible_store::balance(deployer_address, asset);
        let aaron_balance = primary_fungible_store::balance(aaron_address, asset);
        let kc_balance = primary_fungible_store::balance(kc_address, asset);
        assert!(deployer_balance == 50, 0);
        assert!(aaron_balance == 450, 0);
        assert!(kc_balance == 500, 0);

        // Burn 100 assets from kc's account.
        taxed_fa::burn(deployer, kc_address, 100);
        let kc_balance = primary_fungible_store::balance(kc_address, asset);
        assert!(kc_balance == 400, 0);
        assert!(deployer_balance == 50, 0);
    }
}