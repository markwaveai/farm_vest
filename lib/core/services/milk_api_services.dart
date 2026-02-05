import 'dart:convert';
import 'dart:io';

import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MilkApiServices {
  static VoidCallback? onUnauthorized;

  static Future<List<dynamic>> getMilkReport({
    required String token,
    required DateTime reportDate,
    String? timing,
  }) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(reportDate);
      var url =
          "${AppConstants.appLiveUrl}/milk/get_milk_report?report_date=$dateStr";
      if (timing != null) {
        url += "&timing=$timing";
      }

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
        return data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<bool> createMilkEntry({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
    required String timing, // MORNING or EVENING
    required double quantity,
    String? animalId, // Optional, if buffalo-specific
  }) async {
    try {
      final body = {
        "start_date": DateFormat('yyyy-MM-dd').format(startDate),
        "end_date": DateFormat('yyyy-MM-dd').format(endDate),
        "timing": timing,
        "quantity": quantity,
        if (animalId != null) "animal_id": animalId,
      };

      final response = await http.post(
        Uri.parse("${AppConstants.appLiveUrl}/milk/create_milk_entry"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        return true;
      }
      debugPrint(
        "Create Milk Entry Failed (${response.statusCode}): ${response.body}",
      );
      return false;
    } catch (e) {
      debugPrint("Create Milk Entry Exception: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getMilkEntries({required String token}) async {
    try {
      final url = "${AppConstants.appLiveUrl}/milk/milk_entries";
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
        return data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
