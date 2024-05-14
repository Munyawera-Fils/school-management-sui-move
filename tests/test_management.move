#[test_only]
module school_monitor::test_management {
    use sui::test_scenario::{Self as ts, Scenario, next_tx, ctx};
    use sui::transfer;
    use sui::test_utils::{assert_eq};
    use sui::coin::{mint_for_testing, Self};
    use sui::object;
    use sui::tx_context::{TxContext};
    use std::string::{Self, String};

    use school_monitor::school_management::{Self, School, Student, Fee};
    use school_monitor::helpers::{init_test_helper};

    const ADMIN: address = @0xA;
    const TEST_ADDRESS1: address = @0xB;
    const TEST_ADDRESS2: address = @0xC;

    // Initialize the test scenario with admin capability
    #[test]
    public fun test() {

        let scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        next_tx(scenario, ADMIN);
        {
            // Create a school
            let name = string::utf8(b"School 1");
            let location = string::utf8(b"Location 1");
            let contact = string::utf8(b"Contact 1");
            let type = string::utf8(b"Type 1");
            let price: u64 = 100; // Example price

            let (school, cap) = school_management::create_school(name, location, contact, type, price, ctx(scenario));

            // Test creating a school
            assert_eq!(school.name, "School 1", "School name mismatch");
            assert_eq!(school.location, "Location 1", "School location mismatch");
            assert_eq!(school.contact_info, "Contact 1", "School contact info mismatch");
            assert_eq!(school.school_type, "Type 1", "School type mismatch");

            transfer::public_share_object(school);
            transfer::public_transfer(cap, ADMIN);
        };

        next_tx(scenario, ADMIN);
        {
            // Create another school
            let name = string::utf8(b"School 2");
            let location = string::utf8(b"Location 2");
            let contact = string::utf8(b"Contact 2");
            let type = string::utf8(b"Type 2");
            let price: u64 = 200; // Example price

            let (school, cap) = school_management::create_school(name, location, contact, type, price, ctx(scenario));

            // Test creating another school
            assert_eq!(school.name, "School 2", "School name mismatch");
            assert_eq!(school.location, "Location 2", "School location mismatch");
            assert_eq!(school.contact_info, "Contact 2", "School contact info mismatch");
            assert_eq!(school.school_type, "Type 2", "School type mismatch");

            transfer::public_share_object(school);
            transfer::public_transfer(cap, ADMIN);
        };

        next_tx(scenario, ADMIN);
        {
            // Create a student
            let name = string::utf8(b"Student 1");
            let age: u64 = 15;
            let gender: u8 = 0; // Assuming 0 for male and 1 for female
            let contact_info = string::utf8(b"Student Contact 1");
            let emergency_contact = string::utf8(b"Emergency Contact 1");
            let admission_reason = string::utf8(b"Admission Reason 1");
            let school_id = object::get_id(ctx(scenario), ADMIN); // Assuming the admin is the school owner
            let admission_date: u64 = 1622433600000; // Example: Unix timestamp in milliseconds for June 1, 2021

            let student = school_management::admit_student(school_id, name, age, gender, contact_info, emergency_contact, admission_reason, admission_date, ctx(scenario));

            // Test admitting a student
            assert_eq!(student.name, "Student 1", "Student name mismatch");
            assert_eq!(student.age, 15, "Student age mismatch");
            assert_eq!(student.gender, 0, "Student gender mismatch");
            assert_eq!(student.contact_info, "Student Contact 1", "Student contact info mismatch");
            assert_eq!(student.emergency_contact, "Emergency Contact 1", "Student emergency contact mismatch");
            assert_eq!(student.admission_reason, "Admission Reason 1", "Student admission reason mismatch");
            assert_eq!(student.school_id, school_id, "Student school ID mismatch");
            assert_eq!(student.admission_date, 1622433600000, "Student admission date mismatch");
        };

        ts::end(scenario_test);      
    }
}
