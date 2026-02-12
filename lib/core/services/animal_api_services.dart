import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/farm_manager/data/models/animalkart_order_model.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:http/http.dart' as http;

class AnimalApiServices {
  static VoidCallback? onUnauthorized;

  static Future<List<InvestorAnimal>> searchAnimals({
    required String token,
    required String query,
    String? healthStatus,
    int? farmId,
  }) async {
    try {
      final queryParams = {'query_str': query};
      if (healthStatus != null && healthStatus.isNotEmpty) {
        queryParams['health_status'] = healthStatus;
      }
      if (farmId != null) {
        queryParams['farm_id'] = farmId.toString();
      }

      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/animal/search_animal",
      ).replace(queryParameters: queryParams);

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
        final list = data['data'] as List;
        return list.map((e) => InvestorAnimal.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<InvestorAnimalsResponse> getCalves({
    required String token,
    required String animalId,
  }) async {
    try {
      final queryParams = {'animal_id': animalId};

      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/animal/get_calves",
      ).replace(queryParameters: queryParams);

      debugPrint("getCalves URI: $uri");

      final response = await http.get(
        uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      debugPrint("getCalves Response: ${response.body}");

      if (response.statusCode == 200) {
        return InvestorAnimalsResponse.fromJson(jsonDecode(response.body));
      }
      return const InvestorAnimalsResponse(status: 'error', count: 0, data: []);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<List<AnimalkartOrder>> getIntransitOrders({
    String? mobile,
    required String managerMobile,
  }) async {
    try {
      String url =
          "${AppConstants.animalKartStagingApiUrl}/order-tracking/intransit";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'x-admin-mobile': managerMobile,
          'Content-Type': AppConstants.applicationJson,
        },
        body: jsonEncode({"mobile": mobile ?? ""}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Handle the user and orders structure
        final Map<String, dynamic> userJson = data['user'] ?? {};
        final List<dynamic> ordersData = (data['orders'] is List)
            ? data['orders']
            : [];

        return ordersData.map((e) {
          return AnimalkartOrder.fromOrderAndUser(e, userJson);
        }).toList();
      } else {
        throw ServerException(
          'Failed to load paid orders',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Map<String, dynamic>?> getAnimalByPosition({
    required String token,
    required int farmId,
    required int shedId,
    required String rowNumber,
    required String parkingId,
  }) async {
    try {
      final queryParams = {
        'farm_id': farmId.toString(),
        'shed_id': shedId.toString(),
        'row_number': rowNumber,
        'parking_id': parkingId,
      };

      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/animal/get-position",
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          print("Animal Details Response: ${data['data']}");
          return Map<String, dynamic>.from(data['data']);
        }
      }
      return null;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<List<Map<String, dynamic>>> getStaff({
    required String token,
    String? name,
    String? role,
    bool? isActive,
    int? farmId,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, String>{
        'query_str': name ?? '',
        if (role != null && role.isNotEmpty && role != 'All') 'role': role,
        if (isActive != null) 'is_active': isActive.toString(),
        if (farmId != null) 'farm_id': farmId.toString(),
        if (page != null) 'page': page.toString(),
        if (size != null) 'size': size.toString(),
      };

      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/employee/search_employee",
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      }
      throw ServerException(
        'Failed to load staff',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
