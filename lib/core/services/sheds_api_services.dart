import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ShedsApiServices {
  static VoidCallback? onUnauthorized;

  static Future<List<Map<String, dynamic>>> getSheds({
    required String token,
    int? farmId,
  }) async {
    try {
      final uri = Uri.parse("${AppConstants.appLiveUrl}/shed/list").replace(
        queryParameters: {if (farmId != null) 'farm_id': farmId.toString()},
      );
      print("Fetching sheds from: $uri");
      final response = await http.get(
        uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      print("Shed List Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("Shed List Body: ${response.body}");
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
      print("Failed to fetch sheds: ${response.body}");
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getShedList({
    required String token,
    int? farmId,
  }) async {
    return getSheds(token: token, farmId: farmId);
  }

  static Future<bool> createShed({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/shed/create_shed"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      throw ServerException(
        'Failed to create shed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateShed({
    required String token,
    required int shedId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("${AppConstants.appLiveUrl}/shed/update_shed/$shedId"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint("Update Shed Failed: ${response.statusCode} ${response.body}");
      return false;
    } catch (e) {
      debugPrint("Update Shed Error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> getAvailablePositions({
    required String token,
    required int shedId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConstants.appLiveUrl}/shed/available_positions?shed_id=$shedId",
        ),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw ServerException(
        'Failed to get positions',
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  // Alias for getAvailablePositions if consumers use getShedPositions
  static Future<Map<String, dynamic>> getShedPositions({
    required String token,
    required int shedId,
  }) async {
    return getAvailablePositions(token: token, shedId: shedId);
  }

  static Future<bool> allocateAnimals({
    required String token,
    required String shedId,
    required List<Map<String, dynamic>> allocations,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/animal/shed_allocation/$shedId"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode({"allocations": allocations}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      final errorBody = jsonDecode(response.body);
      throw ServerException(
        errorBody['detail'] is Map
            ? errorBody['detail']['message']
            : errorBody['detail'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint("Allocation Error: $e");
      throw AppException(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getUnallocatedAnimals({
    required String token,
    int? farmId,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/animal/unallocated_animals";
      if (farmId != null) {
        url += "?farm_id=$farmId";
      }
      debugPrint("Fetching unallocated animals from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
          data['data']['unallocated_animals'],
        );
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Map<String, dynamic>?> onboardAnimal(
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final uri = Uri.parse("${AppConstants.appLiveUrl}/animal/onboard_animal");
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }
}
