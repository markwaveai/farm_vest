import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../features/auth/models/whatsapp_otp_response.dart';
import '../../features/customer/models/unit_response.dart';
import '../theme/app_constants.dart';

class ApiServices {
  static Future<WhatsappOtpResponse?> sendWhatsappOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(
          "https://markwave-live-apis-couipk45fa-el.a.run.app/otp/send-whatsapp",
        ),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: jsonEncode({"mobile": phone, "appName": "FarmVest"}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return WhatsappOtpResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UnitResponse?> getUnits(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://markwave-live-apis-couipk45fa-el.a.run.app/purchases/units/$userId",
        ),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return UnitResponse.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
