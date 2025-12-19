import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../features/auth/models/whatsapp_otp_response.dart';
import '../../features/auth/models/user_model.dart';
import 'package:farm_vest/features/customer/models/unit_response.dart';
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
        Uri.parse("${AppConstants.apiUrl}/purchases/units/$userId"),
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
}
