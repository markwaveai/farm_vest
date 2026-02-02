import 'dart:convert';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/farm_manager/presentation/models/staff_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//class StaffApiService {
class FarmManagerApiServices {
  static String get url => "${AppConstants.appLiveUrl}/farm/staff";

  static Future<List<Staff>> fetchStaff({
    String query = '',
    String? role,
    bool? isActive,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    print("Access token:$token");

    if (token == null) {
      throw Exception("Access token not found. Please login again.");
    }

    // Construct URL with query parameters
    var url =
        "${AppConstants.appLiveUrl}/employee/search_employee?query_str=$query&size=100";
    if (role != null && role.isNotEmpty && role.toUpperCase() != 'ALL') {
      String r = role.toUpperCase().replaceAll(' ', '_');
      url += "&role=$r";
    }
    if (isActive != null) {
      url += "&is_active=$isActive";
    }

    final uri = Uri.parse(url);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Staff API Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load staff. Status code: ${response.statusCode}",
      );
    }

    final decoded = json.decode(response.body);

    if (decoded['data'] == null) {
      return [];
    }

    final data = decoded['data'] as List;
    List<Staff> staffList = [];

    // To prevent "mixing", we'll determine the display role based on context
    String? currentFilterRole =
        (role != null && role.isNotEmpty && role.toUpperCase() != 'ALL')
        ? role
        : null;

    for (final item in data) {
      final roles = (item['roles'] as List?)?.cast<String>() ?? [];
      String displayRole = "Staff";

      // If we filtered for a specific role and this person has it, show that role
      if (currentFilterRole != null &&
          roles.contains(
            currentFilterRole.toUpperCase().replaceAll(' ', '_'),
          )) {
        displayRole = currentFilterRole;
      } else {
        // Fallback to priority logic
        if (roles.contains("ASSISTANT_DOCTOR")) {
          displayRole = "Assistant Doctor";
        } else if (roles.contains("DOCTOR")) {
          displayRole = "Doctor";
        } else if (roles.contains("SUPERVISOR")) {
          displayRole = "Supervisor";
        } else if (roles.contains("FARM_MANAGER")) {
          displayRole = "Farm Manager";
        }
      }

      // Add strict client-side filtering if a role is selected
      // This ensures that even if the API returns people with other roles,
      // we only show the ones intended for this specific view.
      if (currentFilterRole != null &&
          !roles.contains(
            currentFilterRole.toUpperCase().replaceAll(' ', '_'),
          )) {
        continue;
      }

      staffList.add(
        Staff.fromJson({
          ...item,
          'name': "${item['first_name']} ${item['last_name']}".trim(),
          'mobile': item['mobile'],
          'email': item['email'],
          'status': (item['is_active'] ?? false) ? 'On Duty' : 'Inactive',
        }, displayRole),
      );
    }

    return staffList;
  }

  //Api for milk report....
  static Future<dynamic> fetchMilkReport({
    required String reportDate,
    required String entryFrequency,
    String? timing,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception("Access token not found. Please LOgin");
    }
    final queryParams = {
      'report_date': reportDate,
      'entry_frequency': entryFrequency.toUpperCase(),
      if (timing != null) 'timing': timing.toUpperCase(),
    };
    final uri = Uri.parse(
      "${AppConstants.appLiveUrl}/milk/reports",
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      },
    );
    print("Milk Report API Response:${response.body} ");

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to load milk.Status code: ${response.statusCode}",
      );
    }
    return json.decode(response.body);
  }
}
