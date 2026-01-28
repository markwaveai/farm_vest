import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/farm_manager/data/models/allocated_animal_details.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ShedsApiServices {
  static Future<List<Map<String, dynamic>>> getSheds({
    required String token,
    int? farmId,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/shed/list";
      if (farmId != null) {
        url += "?farm_id=$farmId";
      }

      final response = await http.get(
        Uri.parse(url),
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
    debugPrint("updateShed: Endpoint stub.");
    return false;
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

  static Future<AllocatedAnimalDetails> getAnimalDetails({
    required String token,
    required String farmId,
    required String shedId,
    required String rowNumber,
    required String parkingId,
  }) async {
    try {
      final query = parkingId;

      final url =
          "${AppConstants.appLiveUrl}/animal/search_animal?query_str=$query";

      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> animals = data['data'];

        if (animals.isNotEmpty) {
          return AllocatedAnimalDetails.fromJson(animals.first);
        }

        throw ServerException(
          'No animal found at this position',
          statusCode: 404,
        );
      }

      throw ServerException(
        'Failed to fetch animal details',
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
