import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/features/employee/new_supervisor/data/models/buffalo_telemetry_model.dart';

class BuffaloFitApiServices {
  static const String baseUrl = 'https://api.cowfit.in/api/v1';

  static Future<String?> generateToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'group': '104'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
      return null;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  static Future<BuffaloTelemetry> getCattleDetails(String beltId) async {
    try {
      final token = await generateToken();
      if (token == null) {
        throw ServerException('Failed to generate BuffaloFit token');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/cattle-details/$beltId'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BuffaloTelemetry.fromJson(data);
      } else {
        throw ServerException(
          'Failed to load cattle details',
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
