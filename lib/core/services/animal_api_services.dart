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
      if (mobile != null && mobile.isNotEmpty) {
        url += "?mobile=$mobile";
      }
      final body = <String, dynamic>{"filter_status": "intransit"};

      debugPrint("getIntransitOrders Request URL: $url");
      debugPrint("getIntransitOrders Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'x-admin-mobile': managerMobile,
          'Content-Type': AppConstants.applicationJson,
          'filter_status': 'intransit',
        },
        body: jsonEncode(body),
      );

      debugPrint("getIntransitOrders Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final root = jsonDecode(response.body);
        final List<AnimalkartOrder> allOrders = [];

        if (root['data'] != null && root['data'] is List) {
          final list = root['data'] as List;
          for (var entry in list) {
            if (entry is Map<String, dynamic>) {
              final Map<String, dynamic> userJson = entry['user'] ?? {};
              final List<dynamic> ordersData = (entry['orders'] is List)
                  ? entry['orders']
                  : [];

              allOrders.addAll(
                ordersData.map((e) {
                  return AnimalkartOrder.fromOrderAndUser(e, userJson);
                }),
              );
            }
          }
        } else {
          // Handle the singular user and orders structure if fallback is needed
          final Map<String, dynamic> userJson = root['user'] ?? {};
          final List<dynamic> ordersData = (root['orders'] is List)
              ? root['orders']
              : [];

          allOrders.addAll(
            ordersData.map((e) {
              return AnimalkartOrder.fromOrderAndUser(e, userJson);
            }),
          );
        }

        return allOrders;
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

  static Future<InvestorAnimalsResponse> getPagedAnimals({
    required String token,
    String? healthStatus,
    int? shedId,
    int page = 1,
    int size = 15,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'size': size.toString()};
      if (healthStatus != null && healthStatus.isNotEmpty) {
        queryParams['health_status'] = healthStatus;
      }
      if (shedId != null) {
        queryParams['shed_id'] = shedId.toString();
      }

      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/animal/get_total_animals",
      ).replace(queryParameters: queryParams);

      debugPrint("getPagedAnimals URI: $uri");

      final response = await http.get(
        uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      debugPrint("getPagedAnimals StatusCode: ${response.statusCode}");
debugPrint("getPagedAnimals Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return InvestorAnimalsResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }
      return const InvestorAnimalsResponse(status: 'error', count: 0, data: []);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<int> getTotalAnimals(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.appLiveUrl}/animal/get_total_animals"),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['animals_count'] ?? 0;
      } else {
        throw ServerException(
          'Failed to load total animals',
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
