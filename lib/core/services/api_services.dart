import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../theme/app_constants.dart';
import '../../features/investor/data/models/visit_model.dart';

class ApiServices {
  // Global callback for handling unauthorized access
  static VoidCallback? onUnauthorized;
  // getting orders intransit orders

  static Future<Map<String, dynamic>> getMilkEntries(String token) async {
    try {
      // final response = await http.get(
      //   Uri.parse("${AppConstants.appLiveUrl}/milk/milk_entries"),
      //   headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      // );
      // if (response.statusCode == 401) {
      //   onUnauthorized?.call();
      //   throw ServerException('Unauthorized', statusCode: 401);
      // }
      // if (response.statusCode == 200) {
      //   return jsonDecode(response.body);
      // } else {
      //   throw ServerException(
      //     'Failed to load milk entries',
      //     statusCode: response.statusCode,
      //   );
      // }
      return {};
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

  //keep this apis as it is

  static Future<List<Map<String, dynamic>>> getStaff({
    required String token,
    String? name,
    String? role,
    int? farmId,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, String>{
        'query_str': name ?? '',
        if (role != null && role.isNotEmpty && role != 'All') 'role': role,
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
  /* -------------------------------------------------------------------------- */
  /*                                Farm & Shed APIs                              */
  /* -------------------------------------------------------------------------- */

  /* -------------------------------------------------------------------------- */
  /*                                Farm & Shed APIs                              */
  /* -------------------------------------------------------------------------- */

  static Future<List<Map<String, dynamic>>> getFarms({
    required String token,
    String? query,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/farm/get_all_farms";
      if (query != null && query.isNotEmpty) {
        url += "?name=$query";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
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

  //* -------------------------------------------------------------------------- */
  /*                               Employee APIs                                */
  /* -------------------------------------------------------------------------- */

  static Future<bool> createEmployee({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/employee/create_employee"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      final errorBody = jsonDecode(response.body);
      throw ServerException(
        errorBody['detail'] ?? 'Failed to create employee',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint("Error creating employee: $e");
      return false;
    }
  }
  // Alias for getSheds if consumers use getShedList

  static Future<List<Map<String, dynamic>>> getEmployees({
    required String token,
    String? role,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/employee/get_all_employees";
      if (role != null) {
        url += "?role=$role";
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

  static Future<bool> toggleEmployeeStatus({
    required String token,
    required int employeeId,
    required bool isActive,
  }) async {
    try {
      // Stub for now or use /users/deactivate if appropriate
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> reassignEmployeeFarm({
    required String token,
    required int staffId,
    required int newFarmId,
    int? shedId,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/employee/reassign_employee",
      );
      final body = {
        "staff_id": staffId,
        "new_farm_id": newFarmId,
        "shed_id": shedId,
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

  /* -------------------------------------------------------------------------- */
  /*                               Ticket & Transfer APIs                       */
  /* -------------------------------------------------------------------------- */

  static Future<List<Map<String, dynamic>>> getTickets({
    required String token,
    String? status,
    String? ticketType,
    String? transferDirection,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/ticket/";
      final queryParams = <String, String>{};
      if (status != null) queryParams['status_filter'] = status;
      if (ticketType != null) queryParams['type'] = ticketType;
      if (transferDirection != null) {
        queryParams['transfer_direction'] = transferDirection;
      }

      if (queryParams.isNotEmpty) {
        url += "?" + Uri(queryParameters: queryParams).query;
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

  static Future<bool> createTicket({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/ticket/"),
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
        'Failed to create ticket',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getTransferSummary({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.appLiveUrl}/ticket/transfer-summary"),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      throw ServerException(
        'Failed to get summary',
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<bool> approveTransfer({
    required String token,
    required int ticketId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("${AppConstants.appLiveUrl}/ticket/$ticketId/approve"),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw ServerException(
        'Failed to approve transfer',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return false;
    }
  }

  static Future<bool> rejectTransfer({
    required String token,
    required int ticketId,
    String? reason,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/ticket/$ticketId/reject";
      if (reason != null) {
        url += "?reason=$reason";
      }
      final response = await http.put(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw ServerException(
        'Failed to reject transfer',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return false;
    }
  }
}
