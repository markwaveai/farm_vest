import 'dart:convert';
import 'package:farm_vest/features/farm_manager/presentation/models/staff_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StaffApiService {
  static const String url =
      "https://farmvest-live-apis-jn6cma3vvq-el.a.run.app/api/farm_manager/get_total_staff";


  static Future<List<Staff>> fetchStaff() async {
   
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception("Access token not found. Please login again.");
    }

    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token', 
        'Content-Type': 'application/json',
      },
    );

    print('Staff API Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          "Failed to load staff. Status code: ${response.statusCode}");
    }

    final decoded = json.decode(response.body);

    if (decoded['data'] == null) {
      throw Exception("No data found in API response");
    }

    final data = decoded['data'];

    List<Staff> staff = [];

    
    if (data['supervisors'] != null) {
      for (final s in data['supervisors']) {
        staff.add(Staff.fromJson(s, "Supervisor"));
      }
    }

    if (data['doctors'] != null) {
      for (final d in data['doctors']) {
        staff.add(Staff.fromJson(d, "Doctor"));
      }
    }

    
    if (data['assistant_doctors'] != null) {
      for (final a in data['assistant_doctors']) {
        staff.add(Staff.fromJson(a, "Assistant Doctor"));
      }
    }

    return staff;
  }
}

