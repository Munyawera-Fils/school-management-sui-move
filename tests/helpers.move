#[test_only]
module school_monitor::helpers {
    use sui::test_scenario::{Self as ts, Scenario};
 
    const ADMIN: address = @0xA;

    public fun init_test_helper() : Scenario {
       let scenario_val = ts::begin(ADMIN);
       let scenario = &mut scenario_val;

       scenario_val
    }

}