import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/services/api_services.dart';
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
    return await ApiServices.createMilkEntry(
      token: token,
      body: body,
    );
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
    final formattedStartDate = "${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')}";
    final formattedEndDate = "${endDateTime.year}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.day.toString().padLeft(2, '0')}";

    final body = {
      'start_date': formattedStartDate,
      'end_date': formattedEndDate,
      'leave_type': leaveType,
      'reason': reason,
    };

    return await ApiServices.createLeaveRequest(
      token: token,
      body: body,
    );
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
}
