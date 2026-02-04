import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/services/employee_api_services.dart';
import 'package:farm_vest/core/services/farms_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/services/farm_manager_api_services.dart';
import '../models/staff_model.dart';

class StaffListState {
  final bool isLoading;
  final List<Staff> staff;
  final String? error;
  final String searchQuery;
  final String roleFilter;
  final bool isActiveFilter;

  StaffListState({
    this.isLoading = false,
    this.staff = const [],
    this.error,
    this.searchQuery = '',
    this.roleFilter = 'All',
    this.isActiveFilter = true,
  });

  StaffListState copyWith({
    bool? isLoading,
    List<Staff>? staff,
    String? error,
    String? searchQuery,
    String? roleFilter,
    bool? isActiveFilter,
  }) {
    return StaffListState(
      isLoading: isLoading ?? this.isLoading,
      staff: staff ?? this.staff,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      isActiveFilter: isActiveFilter ?? this.isActiveFilter,
    );
  }
}

class StaffListNotifier extends StateNotifier<StaffListState> {
  StaffListNotifier() : super(StaffListState()) {
    loadStaff();
  }

  Future<void> loadStaff() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final staff = await FarmManagerApiServices.fetchStaff(
        query: state.searchQuery,
        role: state.roleFilter,
        isActive: state.isActiveFilter,
      );

      state = state.copyWith(isLoading: false, staff: staff);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setIsActiveFilter(bool isActive) {
    state = state.copyWith(isActiveFilter: isActive);
    loadStaff();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadStaff();
  }

  void setRoleFilter(String role) {
    state = state.copyWith(roleFilter: role);
    loadStaff();
  }

  // Fetch the farm ID associated with the current Farm Manager
  Future<int?> fetchMyFarmId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return null;

      final farms = await FarmsApiServices.getFarms(token: token);
      if (farms.isNotEmpty) {
        return farms.first.id;
      }
      return null;
    } catch (e) {
      print("Error fetching farm ID: $e");
      return null;
    }
  }

  // Fetch sheds for the farm manager's farm
  Future<List<Map<String, dynamic>>> fetchMySheds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return [];

      return await ShedsApiServices.getShedList(token: token);
    } catch (e) {
      return [];
    }
  }

  // Fetch doctors for senior doctor selection
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return [];

      return await AnimalApiServices.getStaff(token: token, role: 'DOCTOR');
    } catch (e) {
      return [];
    }
  }

  Future<bool> addStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String role, // "Supervisor"
    required int farmId,
    int? shedId,
    int? seniorDoctorId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      // Map role to Enum string
      String roleEnum = role.toUpperCase().replaceAll(' ', '_');
      if (roleEnum == 'ASSISTANT') roleEnum = 'ASSISTANT_DOCTOR';

      final body = {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile": mobile,
        "roles": [roleEnum],
        "farm_id": farmId,
        "sheds.id": shedId,
        "senior_doctor_id": seniorDoctorId,
        "is_test": false,
      };

      final success = await EmployeeApiServices.createEmployee(
        token: token,
        body: body,
      );

      if (success) {
        loadStaff(); // Refresh list
      }
      return success;
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Exception: ')) msg = msg.split('Exception: ').last;
      state = state.copyWith(error: msg);
      return false;
    }
  }

  Future<bool> toggleEmployeeStatus({
    required String mobile,
    required bool isActive,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final success = await EmployeeApiServices.toggleEmployeeStatus(
        token: token,
        mobile: mobile,
        isActive: isActive,
      );

      if (success) {
        loadStaff();
      }
      return success;
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Exception: ')) msg = msg.split('Exception: ').last;
      state = state.copyWith(error: msg);
      return false;
    }
  }

  Future<bool> reassignEmployeeFarm({
    required int staffId,
    required int newFarmId,
    required String role,
    int? shedId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final success = await EmployeeApiServices.reassignEmployeeFarm(
        token: token,
        staffId: staffId,
        newFarmId: newFarmId,
        role: role,
        shedId: shedId,
      );

      if (success) {
        loadStaff();
      }
      return success;
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Exception: ')) msg = msg.split('Exception: ').last;
      state = state.copyWith(error: msg);
      return false;
    }
  }
}

final staffListProvider =
    StateNotifierProvider<StaffListNotifier, StaffListState>(
      (ref) => StaffListNotifier(),
    );

class MilkReportState {
  final bool isLoading;
  final dynamic data;
  final String? error;

  MilkReportState({this.isLoading = false, this.data, this.error});
  factory MilkReportState.initial() {
    return MilkReportState(isLoading: false, data: null, error: null);
  }

  MilkReportState copyWith({bool? isLoading, dynamic data, String? error}) {
    return MilkReportState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class MilkReportNotifier extends StateNotifier<MilkReportState> {
  MilkReportNotifier() : super(MilkReportState.initial());
  void clear() {
    state = MilkReportState.initial();
  }

  Future<void> getDailyReport({
    required String date,
    required String timing,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await FarmManagerApiServices.fetchMilkReport(
        reportDate: date,
        timing: timing,
        entryFrequency: "DAILY",
      );

      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getWeeklyReport({required String date}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await FarmManagerApiServices.fetchMilkReport(
        reportDate: date,
        entryFrequency: "WEEKLY",
      );

      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final milkReportProvider =
    StateNotifierProvider<MilkReportNotifier, MilkReportState>(
      (ref) => MilkReportNotifier(),
    );
