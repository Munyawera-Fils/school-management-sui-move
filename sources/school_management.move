module school_monitor::school_management {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext, sender};
    use sui::clock::{Clock, timestamp_ms};
    use sui::balance::{Self, Balance};
    use sui::sui::{SUI};
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::error::{Error, ERR_INVALID_GENDER, ERR_INVALID_ACCESS, ERR_INSUFFICIENT_FUNDS, ERR_INVALID_TIME};

    use std::string::{String};

    const MALE: u8 = 0;
    const FEMALE: u8 = 1;

    const ERROR_INVALID_GENDER: u64 = 0;
    const ERROR_INVALID_ACCESS: u64 = 1;
    const ERROR_INSUFFICIENT_FUNDS: u64 = 2;
    const ERROR_INVALID_TIME: u64 = 3;
    const ERROR_STUDENT_NOT_ENROLLED: u64 = 4;

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
    public fun create_school(name: String, location: String, contact_info: String, school_type: String, ctx: &mut TxContext) -> (School, SchoolCap) {
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

    // Enroll a student
    public fun enroll_student(school: ID, name: String, age: u64, gender: u8, contact_info: String, date: u64, c: &Clock, ctx: &mut TxContext) -> Student {
        if !(gender == MALE || gender == FEMALE) {
            Error::revert(ERR_INVALID_GENDER);
        }
        let admission_date = timestamp_ms(c) + date;
        Student {
            id: object::new(ctx),
            school,
            name,
            age,
            gender,
            contact_info,
            admission_date,
            fees_paid: false
        }
    }

    // Generate a fee for a student
    public fun generate_fee(cap: &SchoolCap, school: &mut School, student_id: ID, amount: u64, offset_days: u64, c: &Clock, ctx: &mut TxContext) {
        if cap.school != object::id(school) {
            Error::revert(ERR_INVALID_ACCESS);
        }
        let fee = Fee {
            student_id,
            amount,
            payment_date: timestamp_ms(c) + offset_days * 24 * 60 * 60 * 1000, // Convert days to milliseconds
        };
        table::add(&mut school.fees, sender(ctx), fee);
    }

    // Pay fee
    public fun pay_fee(school: &mut School, student: &mut Student, coin: Coin<SUI>, c: &Clock, ctx: &mut TxContext) {
        let fee = table::remove(&mut school.fees, sender(ctx));
        if coin::value(&coin) != fee.amount {
            // Refund fee and revert transaction
            table::add(&mut school.fees, sender(ctx), fee);
            Error::revert(ERR_INSUFFICIENT_FUNDS);
        }
        if fee.payment_date >= timestamp_ms(c) {
            // Refund fee and revert transaction
            table::add(&mut school.fees, sender(ctx), fee);
            Error::revert(ERR_INVALID_TIME);
        }
        // Join the balance 
        let balance_ = coin::into_balance(coin);
        balance::join(&mut school.balance, balance_);
        // Fee paid
        student.fees_paid = true;
    }

    // Withdraw funds from school balance
    public fun withdraw(cap: &SchoolCap, school: &mut School, ctx: &mut TxContext) -> Coin<SUI> {
        if cap.school != object::id(school) {
            Error::revert(ERR_INVALID_ACCESS);
        }
        let balance_ = balance::withdraw_all(&mut school.balance);
        coin::from_balance(balance_, ctx)
    }

    // Public view functions

    // Get school balance
    public view fun get_school_balance(school: &School) -> u64 {
        balance::value(&school.balance)
    }

    // Check if student has paid fees
    public view fun get_student_fee_status(student: &Student) -> bool {
        student.fees_paid
    }

    // Get fee amount for a student
    public view fun get_fee_amount(school: &School, student_id: ID, ctx: &mut TxContext) -> u64 {
        let fee = table::borrow(&school.fees, student_id);
        if fee.student_id != student_id {
            Error::revert(ERROR_STUDENT_NOT_ENROLLED);
        }
        fee.amount
    }
}
