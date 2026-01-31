import 'dart:convert';
import 'dart:io';

import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FarmsApiServices {
  static Future<List<Farm>> getFarms({
    required String token,
    String? query,
    int? page,
    int? size,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/farm/get_all_farms";
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) {
        queryParams['name'] = query;
      }
      if (page != null) queryParams['page'] = page.toString();
      if (size != null) queryParams['size'] = size.toString();

      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List<dynamic>)
            .map((e) => Farm.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(
        'Failed to load farms',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<bool> createFarm({
    required String token,
    required String farmName,
    required String location,
    bool isTest = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/farm/farm"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode({"farm_name": farmName, "location": location}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      throw ServerException(
        'Failed to create farm',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint("createFarm error: $e");
      return false;
    }
  }

  static Future<List<String>> getFarmLocations() async {
    try {
      final uri = Uri.parse("${AppConstants.appLiveUrl}/farm/locations");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final locations = decoded['data']['locations'];
          if (locations is List) {
            return List<String>.from(locations);
          }
        }
        return [];
      } else {
        throw ServerException(
          'Failed to fetch locations',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
