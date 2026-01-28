import 'dart:convert';
import 'dart:io';

import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/investor/data/models/visit_model.dart';
import 'package:http/http.dart' as http;

class VisitsApiServices {
  static Future<List<InvestorFarm>> getInvestorFarms(String token) async {
    try {
      final uri = Uri.parse("${AppConstants.appLiveUrl}/farm/investor/farms");
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List<dynamic> farms = data['data'];
        return farms.map((e) => InvestorFarm.fromJson(e)).toList();
      }
      throw ServerException(
        'Failed to get investor farms',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<VisitAvailability> getVisitAvailability({
    required String date,
    required int farmId,
    required String token,
  }) async {
    try {
      final queryParams = {'visit_date': date, 'farm_id': farmId.toString()};
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/visits/available_visit_slots",
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return VisitAvailability.fromJson(data['data']);
      }
      throw ServerException(
        'Failed to get visit availability',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<Visit> bookVisit(
    VisitBookingRequest request,
    String token,
  ) async {
    try {
      final uri = Uri.parse(
        "${AppConstants.appLiveUrl}/visits/book_visit_slot",
      );
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return Visit.fromJson(data['data']);
      }
      throw ServerException(
        'Failed to book visit',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<List<Visit>> getMyVisits(String token) async {
    try {
      final uri = Uri.parse("${AppConstants.appLiveUrl}/visits/my-visits");
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
          HttpHeaders.acceptHeader: AppConstants.applicationJson,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List<dynamic> visits = data['data'];
        return visits.map((e) => Visit.fromJson(e)).toList();
      }
      throw ServerException(
        'Failed to get visits',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException('No Internet connection');
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
