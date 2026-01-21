import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/features/supervisor/data/model/ticket_model.dart';
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

  Future<void> createTicket(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw AuthException('Authentication token not found');
    }
    return await ApiServices.createTicket(body, token);
  }
}
