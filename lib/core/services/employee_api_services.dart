import 'dart:convert';
import 'dart:io';

import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmployeeApiServices {
  static VoidCallback? onUnauthorized;

  static Future<bool> createEmployee({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      debugPrint("=== CREATE EMPLOYEE REQUEST ===");
      debugPrint("URL: ${AppConstants.appLiveUrl}/employee/create_employee");
      debugPrint("Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/employee/create_employee"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("Employee created successfully!");
        return true;
      }

      try {
        final decoded = jsonDecode(response.body);
        String errorMessage;
        if (decoded is Map<String, dynamic>) {
          errorMessage =
              decoded['detail'] ??
              decoded['message'] ??
              decoded['error'] ??
              'Failed to create employee';
        } else {
          errorMessage = decoded.toString();
        }
        debugPrint("Server Error: $errorMessage");
        throw ServerException(errorMessage, statusCode: response.statusCode);
      } catch (jsonError) {
        debugPrint("Error parsing response body: $jsonError");
        // If JSON parsing fails, use the raw body if available, otherwise generic message
        final msg = response.body.isNotEmpty
            ? response.body
            : 'Failed to create employee (Status: ${response.statusCode})';
        throw ServerException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      debugPrint("Network error: $e");
      throw NetworkException('No Internet connection');
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      debugPrint("createEmployee unexpected error: $e");
      throw AppException(e.toString());
    }
  }
  // Alias for getSheds if consumers use getShedList

  static Future<List<Map<String, dynamic>>> getEmployees({
    required String token,
    String? role,
    int? farmId,
    bool? isActive,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, String>{
        if (role != null) 'role': role,
        if (farmId != null) 'farm_id': farmId.toString(),
        if (isActive != null) 'is_active': isActive.toString(),
        if (page != null) 'page': page.toString(),
        if (size != null) 'size': size.toString(),
      };

      final baseUrl = farmId != null
          ? "${AppConstants.appLiveUrl}/farm/staff"
          : "${AppConstants.appLiveUrl}/employee/get_all_employees";

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<bool> toggleEmployeeStatus({
    required String token,
    required String mobile,
    required bool isActive,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/users/activate_deactivate_user/$mobile?is_active=$isActive",
      );
      final response = await http.put(
        uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> reassignEmployeeFarm({
    required String token,
    required int staffId,
    required int newFarmId,
    required String role,
    int? shedId,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/employee/update_employee",
      );
      final body = {
        "user_id": staffId,
        "farm_id": newFarmId,
        "role": role,
        "sheds.id": shedId,
      };

      debugPrint("Reassigning: $body");

      final response = await http.put(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint("Reassign failed: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("Reassign Exception: $e");
      return false;
    }
  }
}
