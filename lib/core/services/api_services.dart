import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../theme/app_constants.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_model.dart';
import 'package:farm_vest/features/admin/data/models/ticket_model.dart';
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
    required List<String> dates,
    required String timing,
    required double totalQuantity,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/milk/create_distributed_entry",
      );

      final body = {
        "dates": dates,
        "timing": timing,
        "total_quantity": totalQuantity,
        "entry_frequency": "DAILY",
      };

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
          errorBody['detail'] ?? 'Failed to create distributed entries',
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
}
