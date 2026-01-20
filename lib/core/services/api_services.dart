import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/features/auth/data/models/login_response.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/data/models/whatsapp_otp_response.dart';
import '../../features/auth/data/models/user_model.dart';
import 'package:farm_vest/features/investor/data/models/unit_response.dart';
import 'package:flutter/foundation.dart';
import '../../features/investor/data/models/visit_model.dart';
import '../theme/app_constants.dart';

class ApiServices {
  static Future<Map<String, dynamic>> getMilkEntries(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://farmvest-live-apis-jn6cma3vvq-el.a.run.app/api/supervisor/milk_entries"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ServerException('Failed to load milk entries', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }
  static Future<int> getTotalAnimals(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://farmvest-live-apis-jn6cma3vvq-el.a.run.app/api/supervisor/get_total_animals"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['animals_count'] ?? 0;
      } else {
        throw ServerException('Failed to load total animals', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<LoginResponse> loginWithOtp(
      String mobileNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.authApiUrl}/auth/token"),
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.authorizationHeader: AppConstants.authApiKey,
        },
        body: jsonEncode({
          "mobile_number": mobileNumber,
          "otp": otp,
        }),
      );
      print('this is the response===========> ${response.statusCode}');
      print('this is the responsebody===========> ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromMap(data);
      } else {
        throw ServerException('Failed to login', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<WhatsappOtpResponse> sendWhatsappOtp(String phone) async {
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
      throw ServerException('Failed to send OTP', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<UserModel> getUserData(String mobile) async {
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
      throw ServerException('Failed to get user data', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<UnitResponse> getUnits(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            "${AppConstants.apiUrl}/purchases/units/$userId?paymentStatus=PAID"),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return UnitResponse.fromJson(data);
      }
      throw ServerException('Failed to get units', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<UserModel> updateUserProfile({
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
      throw ServerException('Failed to update user profile', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<VisitAvailability> getVisitAvailability({
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
      throw ServerException('Failed to get visit availability', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Visit> bookVisit(VisitBookingRequest request) async {
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
      throw ServerException('Failed to book visit', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
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
      throw ServerException('Failed to get visits', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
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
      throw ServerException('Failed to get visit schedule', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Visit> getVisitById(String visitId) async {
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
      throw ServerException('Failed to get visit by id', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
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
