import 'package:farm_vest/core/services/investor_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_services.dart';

class AdminState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> farms;
  final List<Map<String, dynamic>> staffList;
  final List<Map<String, dynamic>> investorList;
  final List<Map<String, dynamic>> investorAnimals;
  final List<Map<String, dynamic>> tickets;

  AdminState({
    this.isLoading = false,
    this.error,
    this.farms = const [],
    this.staffList = const [],
    this.investorList = const [],
    this.investorAnimals = const [],
    this.tickets = const [],
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? farms,
    List<Map<String, dynamic>>? staffList,
    List<Map<String, dynamic>>? investorList,
    List<Map<String, dynamic>>? investorAnimals,
    List<Map<String, dynamic>>? tickets,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      farms: farms ?? this.farms,
      staffList: staffList ?? this.staffList,
      investorList: investorList ?? this.investorList,
      investorAnimals: investorAnimals ?? this.investorAnimals,
      tickets: tickets ?? this.tickets,
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  @override
  AdminState build() {
    return AdminState();
  }

  Future<void> fetchFarms({String? query, int page = 1, int size = 20}) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return;
      }
      final newFarms = await ApiServices.getFarms(
        token: token,
        query: query,
        page: page,
        size: size,
      );

      if (page == 1) {
        state = state.copyWith(isLoading: false, farms: newFarms);
      } else {
        state = state.copyWith(
          isLoading: false,
          farms: [...state.farms, ...newFarms],
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchStaff({String? name, String? role, int? farmId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return;
      }
      final staff = await ApiServices.getStaff(
        token: token,
        name: name,
        role: role,
        farmId: farmId,
      );
      state = state.copyWith(isLoading: false, staffList: staff);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createFarm({
    required String name,
    required String location,
    bool isTest = false,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final success = await ApiServices.createFarm(
        token: token,
        farmName: name,
        location: location,
        isTest: isTest,
      );
      state = state.copyWith(isLoading: false);
      if (success) fetchFarms();
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> createShed({
    required int farmId,
    required String shedId,
    required String shedName,
    required int capacity,
    String? cctvUrl,
    String? cctvUrl2,
    String? cctvUrl3,
    String? cctvUrl4,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final body = {
        "farm_id": farmId,
        "shed_id": shedId,
        "shed_name": shedName,
        "capacity": capacity,
        "cctv_url": cctvUrl,
        "cctv_url_2": cctvUrl2,
        "cctv_url_3": cctvUrl3,
        "cctv_url_4": cctvUrl4,
      };

      final success = await ShedsApiServices.createShed(
        token: token,
        body: body,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateShed({
    required int shedId,
    required Map<String, dynamic> body,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final success = await ShedsApiServices.updateShed(
        token: token,
        shedId: shedId,
        body: body,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> addStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required List<String> roles,
    required int farmId,
    int? shedId,
    int? seniorDoctorId,
    bool isTest = false,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final body = {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile": mobile,
        "roles": roles,
        "farm_id": farmId,
        "shed_id": shedId,
        "senior_doctor_id": seniorDoctorId,
        "is_test": isTest,
      };

      final success = await ApiServices.createEmployee(
        token: token,
        body: body,
      );
      state = state.copyWith(isLoading: false);
      if (success) fetchStaff(); // Refresh staff list on success
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> reassignEmployeeFarm({
    required int staffId,
    required int newFarmId,
    int? shedId,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final success = await ApiServices.reassignEmployeeFarm(
        token: token,
        staffId: staffId,
        newFarmId: newFarmId,
        shedId: shedId,
      );

      state = state.copyWith(isLoading: false);
      if (success) {
        fetchStaff();
        fetchFarms();
      }
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> toggleEmployeeStatus({
    required int employeeId,
    required bool isActive,
  }) async {
    // Optimistic update could happen here, but simpler to wait
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return false;

      final success = await ApiServices.toggleEmployeeStatus(
        token: token,
        employeeId: employeeId,
        isActive: isActive,
      );

      if (success) {
        // Refresh the list to reflect changes
        fetchStaff();
      }
      return success;
    } catch (e) {
      // Handle error if needed
      return false;
    }
  }

  Future<void> fetchInvestors() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return;
      }
      final investors = await InvestorApiServices.getInvestors(token: token);
      state = state.copyWith(isLoading: false, investorList: investors);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchInvestorAnimals(int investorId) async {
    state = state.copyWith(isLoading: true, investorAnimals: []);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return;
      }
      final response = await InvestorApiServices.getInvestorAnimals(
        token: token,
        investorId: investorId,
      );
      final animals = response.data.map((e) => e.toJson()).toList();
      state = state.copyWith(isLoading: false, investorAnimals: animals);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchTickets({
    String? ticketType,
    String? status,
    String? transferDirection,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return;
      }
      final tickets = await ApiServices.getTickets(
        token: token,
        ticketType: ticketType,
        status: status,
        transferDirection: transferDirection,
      );
      state = state.copyWith(isLoading: false, tickets: tickets);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final adminProvider = NotifierProvider<AdminNotifier, AdminState>(() {
  return AdminNotifier();
});
