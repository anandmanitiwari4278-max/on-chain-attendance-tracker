
module MyModule::AttendanceTracker {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::vector;

    /// Struct representing an attendance record for a user
    struct AttendanceRecord has store, key {
        check_ins: vector<u64>,    // Vector of timestamps when user checked in
        total_attendance: u64,     // Total number of check-ins
    }

    /// Function to initialize attendance tracking for a user
    public fun initialize_attendance(user: &signer) {
        let attendance = AttendanceRecord {
            check_ins: vector::empty<u64>(),
            total_attendance: 0,
        };
        move_to(user, attendance);
    }

    /// Function to mark attendance (check-in) for a user
    public fun mark_attendance(user: &signer) acquires AttendanceRecord {
        let user_address = signer::address_of(user);
        
        // Check if user has initialized attendance tracking
        if (!exists<AttendanceRecord>(user_address)) {
            initialize_attendance(user);
        };

        let attendance_record = borrow_global_mut<AttendanceRecord>(user_address);
        let current_time = timestamp::now_seconds();
        
        // Add current timestamp to check-ins vector
        vector::push_back(&mut attendance_record.check_ins, current_time);
        
        // Increment total attendance count
        attendance_record.total_attendance = attendance_record.total_attendance + 1;
    }

    // View function to get total attendance count for a user
    #[view]
    public fun get_attendance_count(user_address: address): u64 acquires AttendanceRecord {
        if (!exists<AttendanceRecord>(user_address)) {
            return 0
        };
        let attendance_record = borrow_global<AttendanceRecord>(user_address);
        attendance_record.total_attendance
    }

    #[view]
    public fun get_check_in_history(user_address: address): vector<u64> acquires AttendanceRecord {
        if (!exists<AttendanceRecord>(user_address)) {
            return vector::empty<u64>()
        };
        let attendance_record = borrow_global<AttendanceRecord>(user_address);
        attendance_record.check_ins
    }
}
