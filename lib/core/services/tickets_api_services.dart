import 'dart:convert';
import 'dart:io';

import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:farm_vest/core/models/ticket_model.dart';

class TicketsApiServices {
  static VoidCallback? onUnauthorized;

  static Future<List<Ticket>> getTickets({
    required String token,
    String? status,
    String? ticketType,
    String? transferDirection,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/ticket/get_health_tickets";
      final queryParams = <String, String>{'size': '1000'};
      if (status != null) queryParams['status_filter'] = status;
      if (ticketType != null) queryParams['ticket_type'] = ticketType;

      if (transferDirection != null) {
        queryParams['transfer_direction'] = transferDirection;
      }

      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await http.get(
        Uri.parse(url),
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
        final data = jsonDecode(response.body);
        return (data['data'] as List<dynamic>)
            .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<List<Ticket>> getTransferTickets({
    required String token,
    String status = 'PENDING',
  }) async {
    try {
      final url =
          "${AppConstants.appLiveUrl}/ticket/get_health_tickets?ticket_type=TRANSFER&status_filter=$status&size=1000";
      final response = await http.get(
        Uri.parse(url),
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
        final data = jsonDecode(response.body);
        return (data['data'] as List<dynamic>)
            .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<bool> createTicket({
    required String token,
    required Map<String, dynamic> body,
    required String ticketType,
  }) async {
    try {
      final url = "${AppConstants.appLiveUrl}/ticket/?ticket_type=$ticketType";
      final encodedBody = jsonEncode(body);
      debugPrint("[CreateTicket] URL: $url");
      debugPrint("[CreateTicket] Body: $encodedBody");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
        body: encodedBody,
      );

      debugPrint("[CreateTicket] Status: ${response.statusCode}");
      debugPrint("[CreateTicket] Response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("[CreateTicket] Exception: $e");
      return false;
    }
  }

  static Future<bool> createTransferTicket({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    return createTicket(token: token, body: body, ticketType: 'TRANSFER');
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

  static Future<List<Ticket>> getHealthTickets({
    required String token,
    String? ticketType,
  }) async {
    try {
      final queryParams = <String, String>{'size': '1000'};
      if (ticketType != null) {
        queryParams['ticket_type'] = ticketType;
      }

      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/ticket/get_health_tickets",
      ).replace(queryParameters: queryParams);

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
        final data = jsonDecode(response.body);
        return (data['data'] as List<dynamic>)
            .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<int> getTicketsCount({
    required String token,
    String? status,
    String? ticketType,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/ticket/get_health_tickets";
      final queryParams = <String, String>{'size': '1000'};
      if (status != null) queryParams['status_filter'] = status;
      if (ticketType != null) queryParams['ticket_type'] = ticketType;

      if (queryParams.isNotEmpty) {
        url += "?${Uri(queryParameters: queryParams).query}";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List<dynamic>?;
        return list?.length ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getAssistants({
    required String token,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/doctor/get_my_assistants",
      ).replace(queryParameters: {'role': 'ASSISTANT_DOCTOR'});

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
