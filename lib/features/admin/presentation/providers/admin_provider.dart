import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/services/employee_api_services.dart';
import 'package:farm_vest/core/services/farms_api_services.dart';
import 'package:farm_vest/core/services/investor_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/services/tickets_api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/error/exceptions.dart';
import '../../../../core/services/api_services.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_model.dart';
import 'package:farm_vest/features/admin/data/models/ticket_model.dart';
import 'package:farm_vest/features/investor/data/models/investor_model.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';

class AdminState {
  final bool isLoading;
  final String? error;
  final List<Farm> farms;
  final List<UserModel> staffList;
  final List<Investor> investorList;
  final List<InvestorAnimal> investorAnimals;
  final List<Ticket> tickets;
  final bool staffActiveFilter;

  AdminState({
    this.isLoading = false,
    this.error,
    this.farms = const [],
    this.staffList = const [],
    this.investorList = const [],
    this.investorAnimals = const [],
    this.tickets = const [],
    this.staffActiveFilter = true,
  });

  AdminState copyWith({
    bool? isLoading,
    String? error,
    List<Farm>? farms,
    List<UserModel>? staffList,
    List<Investor>? investorList,
    List<InvestorAnimal>? investorAnimals,
    List<Ticket>? tickets,
    bool? staffActiveFilter,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      farms: farms ?? this.farms,
      staffList: staffList ?? this.staffList,
      investorList: investorList ?? this.investorList,
      investorAnimals: investorAnimals ?? this.investorAnimals,
      tickets: tickets ?? this.tickets,
      staffActiveFilter: staffActiveFilter ?? this.staffActiveFilter,
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
      final newFarms = await FarmsApiServices.getFarms(
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

  Future<void> fetchStaff({
    String? name,
    String? role,
    int? farmId,
    bool? isActive,
  }) async {
    state = state.copyWith(
      isLoading: true,
      staffActiveFilter: isActive ?? state.staffActiveFilter,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return;
      }
      List<Map<String, dynamic>> staffData;

      // Handle "All" role check
      final String? apiRole = (role != null && role.isNotEmpty && role != 'All')
          ? role
          : null;
      final bool filterActive = isActive ?? state.staffActiveFilter;

      if (name != null && name.trim().isNotEmpty) {
        // Use search endpoint when specific name query provided
        staffData = await AnimalApiServices.getStaff(
          token: token,
          name: name,
          role: role,
          farmId: farmId,
          isActive: filterActive,
        );
      } else {
        // Use get_all_employees endpoint for list filtering (supports farmId)
        // Default page to 1, size to 100 to show more data for now
        staffData = await EmployeeApiServices.getEmployees(
          token: token,
          role: apiRole,
          farmId: farmId,
          isActive: filterActive,
          page: 1,
          size: 100, // Fetch more items since pagination UI is basic
        );
      }
      final staffModels = staffData.map((e) => UserModel.fromJson(e)).toList();
      state = state.copyWith(isLoading: false, staffList: staffModels);
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

      final success = await FarmsApiServices.createFarm(
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Authentication token not found. Please login again.',
        );
        return false;
      }

      final body = <String, dynamic>{
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile": mobile,
        "roles": roles,
        "farm_id": farmId,
        "is_test": isTest,
      };

      // Only add optional fields if they're not null
      if (shedId != null) {
        body["shed_id"] = shedId;
      }
      if (seniorDoctorId != null) {
        body["senior_doctor_id"] = seniorDoctorId;
      }

      debugPrint("=== ADMIN PROVIDER: Adding Staff ===");
      debugPrint("Request Body: $body");

      final success = await EmployeeApiServices.createEmployee(
        token: token,
        body: body,
      );

      debugPrint("Add Staff Success: $success");
      state = state.copyWith(isLoading: false, error: null);
      if (success) fetchStaff(); // Refresh staff list on success
      return success;
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> reassignEmployeeFarm({
    required int staffId,
    required int newFarmId,
    required String role,
    int? shedId,
  }) async {
    state = state.copyWith(isLoading: true);
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
    required String mobile,
    required bool isActive,
  }) async {
    // Optimistic update could happen here, but simpler to wait
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
      state = state.copyWith(isLoading: false, investorAnimals: response.data);
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
      final tickets = await TicketsApiServices.getTickets(
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

  Future<bool> createTransferTicket({
    required String rfidTag,
    required String description,
    required int destinationShedId,
    String transferDirection = 'OUT',
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return false;
      }

      final body = {
        "rfid_tag": rfidTag,
        "ticket_type": "TRANSFER",
        "description": description,
        "transfer_direction": transferDirection,
        "destination_shed_id": destinationShedId,
      };

      final success = await TicketsApiServices.createTicket(
        token: token,
        body: body,
      );

      state = state.copyWith(isLoading: false);
      if (success) {
        fetchTickets();
      }
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final adminProvider = NotifierProvider<AdminNotifier, AdminState>(() {
  return AdminNotifier();
});
