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
}
