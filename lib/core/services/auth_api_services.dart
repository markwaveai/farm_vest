import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/auth/data/models/login_response.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:farm_vest/features/auth/data/models/whatsapp_otp_response.dart';
import 'package:http/http.dart' as http;

enum OtpType { whatsapp, email }

class AuthApiServices {
  static VoidCallback? onUnauthorized;

  static Future<WhatsappOtpResponse> sendWhatsappOtp({
    String? phone,
    String? email,
    OtpType? otpType,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/auth/send-whatsapp-otp",
      ).replace(queryParameters: {"method": otpType?.name ?? "whatsapp"});

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          //  "Authorization": AppConstants.authApiKey,
        },
        body: jsonEncode({
          if (otpType == OtpType.email)
            "email": email ?? ""
          else
            "mobile": phone ?? "",
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if response body is a valid JSON string
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            // The API returns { "data": { "status": "success", ... } }
            // We need to pass the inner map to formJson if 'data' key exists
            if (data is Map<String, dynamic> && data.containsKey('data')) {
              return WhatsappOtpResponse.fromJson(data['data']);
            }
            return WhatsappOtpResponse.fromJson(data);
          } catch (e) {
            final responseString = response.body;
            final otpMatch = RegExp(r'\b\d{4,6}\b').firstMatch(responseString);
            final extractedOtp = otpMatch?.group(0);
            return WhatsappOtpResponse(
              otp: extractedOtp,
              user: null,
              message: responseString,
              status: true,
            );
          }
        } else {
          throw ServerException('Empty response from server');
        }
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

  static Future<LoginResponse> loginWithOtp({
    String? mobile,
    String? email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/auth/token"),
        headers: {
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          //  HttpHeaders.authorizationHeader: AppConstants.authApiKey,
        },
        body: jsonEncode({
          "mobile_number": mobile ?? "",
          "email": email ?? "",
          "otp": otp,
        }),
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
      }
      // else {
      //   headers["Authorization"] = AppConstants.authApiKey;
      // }

      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/users/get_user_data",
      ).replace(queryParameters: {'mobile': mobile});

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

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
    String? token,
  }) async {
    try {
      final url = "${AppConstants.appLiveUrl}/users/update_user_details/";

      final headers = {
        HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
      };

      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
      // else {
      //   headers["Authorization"] = AppConstants.authApiKey;
      // }

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["status"] == "success" && data["user"] != null) {
          return UserModel.fromJson(data["user"]);
        }
      }
      final data = jsonDecode(response.body);
      String message = 'Failed to update user profile';
      if (data is Map) {
        message = data['message'] ?? data['detail'] ?? message;
      }
      throw ServerException(message, statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<void> registerFcmToken(String token, {String? jwt}) async {
    try {
      final headers = {
        HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
      };

      if (jwt != null && jwt.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $jwt';
      }

      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/fcm/register_token"),
        headers: headers,
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        // Log but don't throw to avoid blocking app flow
        print(
          'Failed to register FCM token: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print("Error registering FCM token: $e");
    }
  }
}
