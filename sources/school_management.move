module school_monitor::school_management {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext, sender};
    use sui::clock::{Clock, timestamp_ms};
    use sui::balance::{Self, Balance};
    use sui::sui::{SUI};
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    
    use std::string::{Self, String};

    const ERROR_INVALID_GENDER: u64 = 0;
    const ERROR_INVALID_ACCESS: u64 = 1;
    const ERROR_INSUFFICIENT_FUNDS: u64 = 2;
    const ERROR_INVALID_TIME: u64 = 3;

    // School Structure
    struct School has key, store {
        id: UID,
        students: Table<address, bool>,
        name: String,
        location: String,
        contact_info: String,
        school_type: String,
        price: u64,
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
        for: address,
        name: String,
        age: u64,
        gender: String,
        contact_info: String,
        admission_date: u64,
        fees_paid: bool
    }

    // Create a new school
    public fun create_school(name: String, location: String, contact_info: String, school_type: String, price: u64, ctx: &mut TxContext): (School, SchoolCap) {
        let id_ = object::new(ctx);
        let inner_ = object::uid_to_inner(&id_);
        let school = School {
            id: id_,
            students: table::new(ctx),
            name,
            location,
            contact_info,
            school_type,
            price: price,
            balance: balance::zero()
        };
        let cap = SchoolCap {
            id: object::new(ctx),
            school: inner_,
        };
        (school, cap)
    }

    // // Enroll a student
    public fun new_student(school: ID, name: String, age: u64, gender: String, contact_info: String, date: u64, c: &Clock, ctx: &mut TxContext): Student {
        assert!(gender == string::utf8(b"MALE") || gender == string::utf8(b"FAMALE"), ERROR_INVALID_GENDER);        
        let id_ = object::new(ctx);
        let for_ = object::uid_to_address(&id_); // we will use the object id's address for table key 
        Student {
            id: id_,
            school,
            name,
            for: for_,
            age,
            gender,
            contact_info,
            admission_date: timestamp_ms(c) + date,
            fees_paid: false
        }
    }
    // enroll the students
    public fun enroll(self: &mut School, student: &mut Student, coin: Coin<SUI>) {
        assert!(coin::value(&coin) == self.price, ERROR_INSUFFICIENT_FUNDS);
        coin::put(&mut self.balance, coin);
        table::add(&mut self.students, student.for, true);
    }

    public fun remove(cap: &SchoolCap, school: &mut School, student: address) {
        assert!(cap.school == object::id(school), ERROR_INVALID_ACCESS);
        table::remove(&mut school.students, student);
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
}
