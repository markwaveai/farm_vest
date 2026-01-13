import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Model for a Staff Member - now with nullable fields for safety
class Staff {
  final String? name;
  final String? role;
  final String? status;
  final String? phone;
  final String? designation;

  Staff({
    this.name,
    this.role,
    this.status,
    this.phone,
    this.designation,
  });
}

class StaffListState {
  final List<Staff> staff;
  final bool isLoading;

  StaffListState({this.staff = const [], this.isLoading = false});

  StaffListState copyWith({List<Staff>? staff, bool? isLoading}) {
    return StaffListState(
      staff: staff ?? this.staff,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StaffListNotifier extends Notifier<StaffListState> {
  // Using a list that can be modified
  late List<Staff> _sourceStaff;

  @override
  StaffListState build() {
    // Initialize with mock data
    _sourceStaff = [
       Staff(
        name: "Dr. Sharma",
        role: "Veterinarian",
        status: "On Duty",
        phone: "+91 98765 43210",
        designation: "Head Veterinarian",
      ),
      Staff(
        name: "Raj Kumar",
        role: "Supervisor",
        status: "On Duty",
        phone: "+91 91234 56789",
        designation: "Shift Supervisor (Morning)",
      ),
      Staff(
        name: "Anita Singh",
        role: "Admin",
        status: "Leave",
        phone: "+91 99887 76655",
        designation: "Administrative Officer",
      ),
      Staff(
        name: "Suresh Verma",
        role: "Assistant",
        status: "On Duty",
        phone: "+91 90000 11111",
        designation: "Veterinary Assistant",
      ),
    ];
    return StaffListState(staff: _sourceStaff);
  }

  // 2. Method to add a new staff member to the list
  void addStaff(Staff newStaff) {
    // In a real app, this would involve an API call.
    // For now, we just update the local list.
    _sourceStaff.add(newStaff);
    state = state.copyWith(staff: List.from(_sourceStaff));
  }
}

final staffListProvider = NotifierProvider<StaffListNotifier, StaffListState>(
  StaffListNotifier.new,
);
