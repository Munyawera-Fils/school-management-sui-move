module school_monitor::school_management {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext, sender};
    use sui::clock::{Clock, timestamp_ms};
    use sui::balance::{Self, Balance};
    use sui::sui::{SUI};
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    
    use std::string::{String};

    const MALE: u8 = 0;
    const FEMALE: u8 = 1;

    const ERROR_INVALID_GENDER: u64 = 0;
    const ERROR_INVALID_ACCESS: u64 = 1;
    const ERROR_INSUFFICIENT_FUNDS: u64 = 2;
    const ERROR_INVALID_TIME: u64 = 3;

    // School Structure
    struct School has key, store {
        id: UID,
        name: String,
        location: String,
        contact_info: String,
        school_type: String,
        fees: Table<address, Fee>,
        balance: Balance<SUI>
    }

    struct SchoolCap has key, store {
        id: UID,
        school: ID,
    }

    // Student Structure
    struct Student has key {
        id: UID,
        school: ID,
        name: String,
        age: u64,
        gender: u8,
        contact_info: String,
        admission_date: u64,
        fees_paid: bool
    }

    // Fee Structure
    struct Fee has copy, store, drop {
        student_id: ID,
        amount: u64,
        payment_date: u64,
    }

    // Create a new school
    public fun create_school(name: String, location: String, contact_info: String, school_type: String, ctx: &mut TxContext): (School, SchoolCap) {
        let id_ = object::new(ctx);
        let inner_ = object::uid_to_inner(&id_);
        let school = School {
            id: id_,
            name,
            location,
            contact_info,
            school_type,
            fees: table::new(ctx),
            balance: balance::zero()
        };
        let cap = SchoolCap {
            id: object::new(ctx),
            school: inner_,
        };
        (school, cap)
    }

    // // Enroll a student
    public fun enroll_student(school: ID, name: String, age: u64, gender: u8, contact_info: String, date: u64, c: &Clock, ctx: &mut TxContext): Student {
        assert!(gender == 0 || gender == 1, ERROR_INVALID_GENDER);
        Student {
            id: object::new(ctx),
            school,
            name,
            age,
            gender,
            contact_info,
            admission_date: timestamp_ms(c) + date,
            fees_paid: false
        }
    }

    // Generate a fee for a student
    public fun generate_fee(cap: &SchoolCap, school: &mut School, student_id: ID, amount: u64, date: u64, c: &Clock, ctx: &mut TxContext) {
        assert!(cap.school == object::id(school), ERROR_INVALID_ACCESS);
        let fee = Fee {
            student_id,
            amount,
            payment_date: timestamp_ms(c) + date,
        };
        table::add(&mut school.fees, sender(ctx), fee);
    }

    // // Pay fee
    public fun pay_fee(school: &mut School, student: &mut Student, coin: Coin<SUI>, c: &Clock, ctx: &mut TxContext) {
        let fee = table::remove(&mut school.fees, sender(ctx));
        assert!(coin::value(&coin) == fee.amount, ERROR_INSUFFICIENT_FUNDS);
        assert!(fee.payment_date < timestamp_ms(c), ERROR_INVALID_TIME);
        // join the balance 
        let balance_ = coin::into_balance(coin);
        balance::join(&mut school.balance, balance_);
        // fee paid
        student.fees_paid = true;
    }

    public fun withdraw(cap: &SchoolCap, school: &mut School, ctx: &mut TxContext) : Coin<SUI> {
        assert!(cap.school == object::id(school), ERROR_INVALID_ACCESS);
        let balance_ = balance::withdraw_all(&mut school.balance);
        let coin_ = coin::from_balance(balance_, ctx);
        coin_
    }

    // // =================== Public view functions ===================
    public fun get_school_balance(school: &School) : u64 {
        balance::value(&school.balance)
    }

    public fun get_student_fee_status(student: &Student) : bool {
        student.fees_paid
    }

    public fun get_fee_amount(school: &School, ctx: &mut TxContext) : u64 {
        let fee = table::borrow(&school.fees, sender(ctx));
        fee.amount
    }
}
