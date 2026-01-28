import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupervisorRepository {
  Future<Map<String, dynamic>> getMilkEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return await ApiServices.getMilkEntries(token);
  }

  Future<int> getTotalAnimals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return await ApiServices.getTotalAnimals(token);
  }

  Future<List<Map<String, dynamic>>> getUnallocatedAnimals(String token) async {
    return await ShedsApiServices.getUnallocatedAnimals(token: token);
  }

  Future<List<Map<String, dynamic>>> searchAnimals({
    String query = 'all',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return await ApiServices.searchAnimals(token: token, query: query);
  }

  Future<Map<String, dynamic>> createMilkEntry({
    required String timing,
    required String quantity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    final body = {
      'entry_frequency': 'DAILY',
      'quantity': double.tryParse(quantity) ?? 0.0,
      'timing': timing.toUpperCase(),
    };
    return await ApiServices.createMilkEntry(token: token, body: body);
  }

  Future<Map<String, dynamic>> createLeaveRequest({
    required String startDate,
    required String endDate,
    required String leaveType,
    required String reason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }

    // Parse and format the date strings
    final startDateTime = DateTime.parse(startDate);
    final endDateTime = DateTime.parse(endDate);
    final formattedStartDate =
        "${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')}";
    final formattedEndDate =
        "${endDateTime.year}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.day.toString().padLeft(2, '0')}";

    final body = {
      'start_date': formattedStartDate,
      'end_date': formattedEndDate,
      'leave_type': leaveType,
      'reason': reason,
    };

    return await ApiServices.createLeaveRequest(token: token, body: body);
  }

  Future<Map<String, dynamic>> getLeaveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return await ApiServices.getLeaveRequests(token);
  }

  Future<void> cancelLeaveRequest(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return await ApiServices.cancelLeaveRequest(token, id);
  }

  Future<Map<String, dynamic>> getAnimalLocation(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return await ApiServices.getAnimalLocation(token, id);
  }

  Future<Map<String, dynamic>> getTickets({String? status}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return {};

    // return await ApiServices.getTickets(token: token, status: status,type: '');
  }

  Future<Map<String, dynamic>> createTicket({
    required Map<String, dynamic> body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }

    final success = await ApiServices.createTicket(token: token, body: body);
    if (success) {
      return {'status': 'success', 'message': 'Ticket created successfully'};
    } else {
      throw AppException('Failed to create ticket');
    }
  }

  Future<Map<String, dynamic>> getTransferTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return {};

    // return await ApiServices.getTickets(token, ticketType: 'TRANSFER');
  }

  Future<Map<String, dynamic>> getTransferSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return {};
    // return await ApiServices.getTransferSummary(token);
  }
}
