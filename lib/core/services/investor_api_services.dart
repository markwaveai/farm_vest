import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/investor/data/models/investor_summary_model.dart';
import 'package:farm_vest/features/investor/data/models/investor_model.dart';

/// Service class for investor-related API calls.
///
/// This class handles all HTTP requests for investor data including:
/// - Animal lists
/// - Summary and statistics
/// - Profile information
///
/// All methods require authentication via bearer token.
class InvestorApiServices {
  /// Fetches all investors (admin/farm manager only).
  ///
  /// This endpoint returns a list of all investors in the system.
  ///
  /// Parameters:
  /// - [token]: Authentication bearer token
  ///
  /// Returns a list of investor data maps.
  ///
  /// Throws:
  /// - [ServerException] if the server returns an error
  /// - [NetworkException] if there's no internet connection
  /// - [AuthException] if authentication fails
  static Future<List<Investor>> getInvestors({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse("${AppConstants.appLiveUrl}/investors/get_all_investors"),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List<dynamic>)
            .map((e) => Investor.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication failed. Please login again.');
      } else {
        throw ServerException(
          'Failed to fetch investors',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException(
        'No internet connection. Please check your network.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  /// Alias for [getInvestors].
  ///
  /// Provided for backward compatibility.
  static Future<List<Investor>> getAllInvestors({required String token}) async {
    return getInvestors(token: token);
  }

  /// Fetches the list of animals for an investor.
  ///
  /// **NEW API**: `/api/investors/animals`
  ///
  /// This endpoint returns a simplified list of animals owned by the investor,
  /// including images, farm location, and health status.
  ///
  /// Parameters:
  /// - [token]: Authentication bearer token
  /// - [investorId]: Optional investor ID (for admin/farm manager queries)
  ///
  /// Returns [InvestorAnimalsResponse] containing the list of animals.
  ///
  /// Example response:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "count": 2,
  ///   "data": [
  ///     {
  ///       "animal_id": "97c5bbd5-3ee7-4f0e-88ac-f82942b4a07e",
  ///       "images": ["https://..."],
  ///       "farm_name": "test uma",
  ///       "farm_location": "KURNOOL",
  ///       "health_status": "Healthy"
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Throws:
  /// - [ServerException] if the server returns an error
  /// - [NetworkException] if there's no internet connection
  /// - [AuthException] if authentication fails
  static Future<InvestorAnimalsResponse> getInvestorAnimals({
    required String token,
    int? investorId,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/investors/animals";
      if (investorId != null) {
        url += "?investor_id=$investorId";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InvestorAnimalsResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication failed. Please login again.');
      } else {
        debugPrint(
          "getInvestorAnimals error: ${response.statusCode} - ${response.body}",
        );
        throw ServerException(
          'Failed to fetch investor animals',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException(
        'No internet connection. Please check your network.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  /// Fetches investor summary including profile and statistics.
  ///
  /// **NEW API**: `/api/investors/summary`
  ///
  /// This endpoint returns comprehensive summary data for the investor including:
  /// - Profile details (name, phone, email, address, member since)
  /// - Total buffaloes count
  /// - Total calves count
  /// - Asset value
  /// - Revenue
  ///
  /// Parameters:
  /// - [token]: Authentication bearer token
  /// - [investorId]: Optional investor ID (for admin/farm manager queries)
  ///
  /// Returns [InvestorSummaryResponse] containing all summary data.
  ///
  /// Example response:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "data": {
  ///     "profile_details": {
  ///       "first_name": "shenkhar",
  ///       "last_name": "uma",
  ///       "phone_number": "6305447441",
  ///       "email": null,
  ///       "address": null,
  ///       "member_since": "2026-01-28T14:43:52.289001+05:30"
  ///     },
  ///     "total_buffaloes": 1,
  ///     "total_calves": 1,
  ///     "asset_value": 160000.0,
  ///     "revenue": 0
  ///   }
  /// }
  /// ```
  ///
  /// Throws:
  /// - [ServerException] if the server returns an error
  /// - [NetworkException] if there's no internet connection
  /// - [AuthException] if authentication fails
  static Future<InvestorSummaryResponse> getInvestorSummary({
    required String token,
    int? investorId,
  }) async {
    try {
      var url = "${AppConstants.appLiveUrl}/investors/summary";
      if (investorId != null) {
        url += "?investor_id=$investorId";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InvestorSummaryResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication failed. Please login again.');
      } else {
        debugPrint(
          "getInvestorSummary error: ${response.statusCode} - ${response.body}",
        );
        throw ServerException(
          'Failed to fetch investor summary',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException(
        'No internet connection. Please check your network.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }
}
