import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/features/investor/data/models/investor_coins_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../theme/app_constants.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_model.dart';
// Removed unused import

class ApiServices {
  // Global callback for handling unauthorized access
  static VoidCallback? onUnauthorized;
  // getting orders intransit orders

  static Future<Map<String, dynamic>> getMilkEntries(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.appLiveUrl}/milk/milk_entries"),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ensure we always return a Map
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is List) {
          return {'data': data, 'status': 'success'};
        }
        return {
          'data': [],
          'status': 'success',
          'message': 'Unexpected format',
        };
      } else {
        throw ServerException(
          'Failed to load milk entries: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> createMilkEntry({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/milk/create_milk_entry",
      );

      print('Sending request to: $uri');
      print('Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        final errorBody = jsonDecode(response.body);
        throw ServerException(
          errorBody['detail'] ?? 'An unknown conflict occurred.',
          statusCode: response.statusCode,
        );
      } else {
        throw ServerException(
          'Failed to create milk entry',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> createDistributedMilkEntry({
    required String token,
    required String startDate,
    required String endDate,
    required String timing,
    required double totalQuantity,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/milk/create_milk_entry",
      );

      final body = {
        "start_date": startDate,
        "end_date": endDate,
        "timing": timing,
        "quantity": totalQuantity,
      };

      debugPrint("[MilkEntry] URL: $uri");
      debugPrint("[MilkEntry] Body: ${jsonEncode(body)}");

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint("[MilkEntry] Status: ${response.statusCode}");
      debugPrint("[MilkEntry] Response: ${response.body}");

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        // Normalise to always return a map with 'status' so callers can check it
        if (decoded is Map<String, dynamic>) {
          return {'status': 'success', ...decoded};
        }
        return {'status': 'success', 'message': 'Milk entry created'};
      } else {
        final errorBody = jsonDecode(response.body);
        throw ServerException(
          errorBody['detail'] ?? 'Failed to create milk entry',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> createLeaveRequest({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/leave_requests/create_leave_request",
      );

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw ServerException(
          errorBody['detail'] ?? 'Failed to create leave request.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getLeaveRequests(String token) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/leave_requests/leave-requests",
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );
      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw ServerException(
          errorBody['detail'] ?? 'Failed to get leave requests.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<void> cancelLeaveRequest(String token, int id) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/leave_requests/leave-requests/$id",
      );

      final response = await http.put(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw ServerException(
          errorBody['detail'] ?? 'Failed to cancel leave request.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> getAnimalLocation(
    String token,
    int id,
  ) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/animal/animals/$id/location",
      );

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode == 401) {
        onUnauthorized?.call();
        throw ServerException('Unauthorized', statusCode: 401);
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw ServerException(
          errorBody['detail'] ?? 'Failed to get animal location.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<void> updateOnboardingStatus({
    required String orderId,
    required String status,
    required List<dynamic> buffaloIds,
    // required String adminMobile,
  }) async {
    try {
      final adminMobile = await fetchAdminMobile();
      if (adminMobile == null) {
        debugPrint("Admin mobile not found.");
        return;
      }
      final uri = Uri.parse(
        "${AppConstants.animalKartApiUrl}/order-tracking/update-status",
      );

      final body = {
        "orderId": orderId,
        "status": status,
        "buffaloIds": buffaloIds,
      };

      debugPrint('Updating AnimalKart status: $uri');
      debugPrint('Status Body: ${jsonEncode(body)}');
      debugPrint(" URL: $uri");
      debugPrint(" Headers:");
      debugPrint("   Content-Type: ${AppConstants.applicationJson}");
      debugPrint("   x-admin-mobile: $adminMobile");

      debugPrint("🔹 Body: ${jsonEncode(body)}");

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': AppConstants.applicationJson,
          'x-admin-mobile': adminMobile,
        },
        body: jsonEncode(body),
      );
      debugPrint(" Status Code: ${response.statusCode}");

      debugPrint('Response: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Successfully updated AnimalKart status');
      } else {
        debugPrint(
          'Failed to update AnimalKart status: ${response.statusCode}',
        );
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating AnimalKart status: $e');
    }
  }

  static Future<InvestorCoinsResponse?> getInvestorCoins(
    String investorNumber,
  ) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.animalKartStagingApiUrl}/users/coinTransaction/$investorNumber",
      );

      debugPrint("Fetching investor coins: $uri");

      final response = await http.get(
        uri,
        headers: {'Content-Type': AppConstants.applicationJson},
      );

      debugPrint("Investor coins response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InvestorCoinsResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint("Error fetching investor coins: $e");
    }

    return null;
  }

  static Future<String?> fetchAdminMobile() async {
    try {
      final uri = Uri.parse(
        "${AppConstants.animalKartApiUrl}/users/admins/list",
      );

      debugPrint("Fetching admin list: $uri");

      final response = await http.get(
        uri,
        headers: {'Content-Type': AppConstants.applicationJson},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          final firstAdmin = data.first;
          return firstAdmin['mobile'];
        }
      } else {
        debugPrint("Failed to fetch admin list: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching admin list: $e");
    }

    return null;
  }
}
