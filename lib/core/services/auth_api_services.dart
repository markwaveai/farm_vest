import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/auth/data/models/login_response.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:farm_vest/features/auth/data/models/whatsapp_otp_response.dart';
import 'package:http/http.dart' as http;

class AuthApiServices {
  static VoidCallback? onUnauthorized;

  static Future<WhatsappOtpResponse> sendWhatsappOtp(String phone) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/auth/send-whatsapp-otp",
      ).replace(queryParameters: {"mobile": phone});

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          "Authorization": AppConstants.authApiKey,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        // The API returns { "data": { "status": "success", ... } }
        // We need to pass the inner map to formJson if 'data' key exists
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return WhatsappOtpResponse.fromJson(data['data']);
        }
        return WhatsappOtpResponse.fromJson(data);
      }

      String errorMessage = 'Failed to send OTP';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['detail'] ?? errorMessage;
      } catch (_) {}

      throw ServerException(errorMessage, statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<LoginResponse> loginWithOtp(
    String mobileNumber,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/auth/token"),
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.authorizationHeader: AppConstants.authApiKey,
        },
        body: jsonEncode({"mobile_number": mobileNumber, "otp": otp}),
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromMap(data);
      } else {
        throw ServerException(
          'Failed to login',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<UserModel> getUserData(String mobile, {String? token}) async {
    try {
      final headers = {
        HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
      };

      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      } else {
        headers["Authorization"] = AppConstants.authApiKey;
      }

      final response = await http.get(
        Uri.parse("${AppConstants.appLiveUrl}/users/$mobile"),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['user'] != null) {
          return UserModel.fromJson(data['user']);
        }
      }
      throw ServerException(
        'Failed to get user data',
        statusCode: response.statusCode,
      );
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
      final url = "${AppConstants.appLiveUrl}/users/$mobile";

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
      throw ServerException(
        'Failed to update user profile',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
