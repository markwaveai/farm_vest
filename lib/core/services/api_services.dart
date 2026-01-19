import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../features/auth/data/models/whatsapp_otp_response.dart';
import '../../features/auth/data/models/user_model.dart';
import 'package:farm_vest/features/investor/data/models/unit_response.dart';
import 'package:flutter/foundation.dart';
import '../../features/investor/data/models/visit_model.dart';
import '../theme/app_constants.dart';

class ApiServices {
  static Future<WhatsappOtpResponse?> sendWhatsappOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.apiUrl}/otp/send-whatsapp"),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: jsonEncode({"mobile": phone, "appName": "FarmVest"}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return WhatsappOtpResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel?> getUserData(String mobile) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.apiUrl}/users/$mobile"),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['user'] != null) {
          return UserModel.fromJson(data['user']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UnitResponse?> getUnits(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.apiUrl}/purchases/units/$userId?paymentStatus=PAID"),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return UnitResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UserModel?> updateUserProfile({
    required String mobile,
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = "${AppConstants.apiUrl}/users/$mobile";

      final response = await http.put(
        Uri.parse(url),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success" && data["user"] != null) {
          return UserModel.fromJson(data["user"]);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<VisitAvailability?> getVisitAvailability({
    required String date,
    required String location,
  }) async {
    try {
      final queryParams = {'visit_date': date, 'farm_location': location};
      final uri = Uri.parse(
        "${AppConstants.visitApiUrl}/visits/availability",
      ).replace(queryParameters: queryParams);

      debugPrint("Calling: $uri");
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return VisitAvailability.fromJson(data);
      }
      debugPrint("Error: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  static Future<Visit?> bookVisit(VisitBookingRequest request) async {
    try {
      final uri = Uri.parse("${AppConstants.visitApiUrl}/visits/book");
      debugPrint("Calling POST: $uri");
      debugPrint("Body: ${jsonEncode(request.toJson())}");

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(request.toJson()),
      );

      debugPrint("Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return Visit.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  static Future<List<Visit>> getMyVisits(String mobile) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.visitApiUrl}/visits/my-visits",
      ).replace(queryParameters: {'mobile': mobile}); // Corrected query param

      debugPrint("Calling: $uri");
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Visit.fromJson(e)).toList();
      }
      debugPrint("Error: ${response.statusCode} - ${response.body}");
      return [];
    } catch (e) {
      debugPrint("Exception: $e");
      return [];
    }
  }

  static Future<List<Visit>> getVisitSchedule({
    required String date,
    String? farmLocation,
  }) async {
    try {
      final queryParams = {'visit_date': date};
      if (farmLocation != null) {
        queryParams['farm_location'] = farmLocation;
      }

      final uri = Uri.parse(
        "${AppConstants.visitApiUrl}/visits/schedule",
      ).replace(queryParameters: queryParams);

      debugPrint("Calling: $uri");
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Visit.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Visit?> getVisitById(String visitId) async {
    try {
      final uri = Uri.parse("${AppConstants.visitApiUrl}/visits/$visitId");
      debugPrint("Calling: $uri");
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return Visit.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> onboardAnimal(Map<String, dynamic> body) async {
    try {
     // final uri = Uri.parse("${AppConstants.apiUrl}/animals/onboard");
        final uri = Uri.parse("/animals/onboard");
      debugPrint("Calling POST: $uri");
      debugPrint("Body: ${jsonEncode(body)}");

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      debugPrint("Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Exception: $e");
      return false;
    }
  }
}
