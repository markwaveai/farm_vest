import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:farm_vest/features/farm_manager/data/models/shed_model.dart';

class ShedsApiServices {
  static VoidCallback? onUnauthorized;

  static Future<ShedListResponse> getSheds({
    required String token,
    int? farmId,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      final uri = Uri.parse("${AppConstants.appLiveUrl}/shed/list").replace(
        queryParameters: {
          if (farmId != null) 'farm_id': farmId.toString(),
          'page': page.toString(),
          'limit': limit.toString(),
        },
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShedListResponse.fromJson(data);
      }
      return ShedListResponse(
        message: 'Failed to fetch',
        data: [],
        pagination: Pagination(
          currentPage: page,
          itemsPerPage: limit,
          totalPages: 1,
          totalItems: 0,
        ),
      );
    } catch (e) {
      debugPrint("Error fetching sheds: $e");
      throw AppException(e.toString());
    }
  }

  static Future<ShedListResponse> getShedList({
    required String token,
    int? farmId,
    int page = 1,
    int limit = 15,
  }) async {
    return getSheds(token: token, farmId: farmId, page: page, limit: limit);
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
    required String rowNumber,
    required String animalId,
    required String parkingId,
  }) async {
    try {
      final body = {
        "animal_id": int.tryParse(animalId) ?? animalId,
        "row_number": rowNumber.toString(),
        "parking_id": parkingId,
      };
      debugPrint("Allocation Payload: ${jsonEncode(body)}");
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/animal/shed_allocation/$shedId"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint("Allocation Failed: ${response.statusCode} ${response.body}");
      final errorBody = jsonDecode(response.body);
      String errorMessage = 'Failed to allocate animals';

      if (errorBody['detail'] != null) {
        if (errorBody['detail'] is String) {
          errorMessage = errorBody['detail'];
        } else if (errorBody['detail'] is Map) {
          errorMessage =
              errorBody['detail']['message'] ?? errorBody['detail'].toString();
        } else if (errorBody['detail'] is List) {
          final List details = errorBody['detail'];
          if (details.isNotEmpty && details[0] is Map) {
            errorMessage = "${details[0]['msg']}: ${details[0]['loc']}";
          } else {
            errorMessage = details.toString();
          }
        }
      }

      throw ServerException(errorMessage, statusCode: response.statusCode);
    } catch (e) {
      debugPrint("Allocation Error Catch: $e");
      rethrow;
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
      debugPrint("Onboard Request Body: ${jsonEncode(body)}");

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      debugPrint("Onboard Failed: ${response.statusCode} ${response.body}");
      final errorBody = jsonDecode(response.body);
      String errorMessage = 'Failed to onboard animal';

      if (errorBody['detail'] != null) {
        if (errorBody['detail'] is String) {
          errorMessage = errorBody['detail'];
        } else if (errorBody['detail'] is Map) {
          errorMessage =
              errorBody['detail']['message'] ?? errorBody['detail'].toString();
        } else if (errorBody['detail'] is List) {
          final List details = errorBody['detail'];
          if (details.isNotEmpty && details[0] is Map) {
            errorMessage = "${details[0]['msg']}: ${details[0]['loc']}";
          }
        }
      }

      throw ServerException(errorMessage, statusCode: response.statusCode);
    } catch (e) {
      debugPrint("Exception: $e");
      rethrow;
    }
  }
}
