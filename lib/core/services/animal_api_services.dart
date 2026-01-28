import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/farm_manager/data/models/animalkart_order_model.dart';
import 'package:http/http.dart' as http;

class AnimalApiServices {
  static Future<List<Map<String, dynamic>>> searchAnimals({
    required String token,
    required String query,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConstants.appLiveUrl}/animal/search_animal?query_str=$query",
        ),
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

  static Future<List<AnimalkartOrder>> getIntransitOrders({
    String? mobile,
    required String adminMobile,
  }) async {
    try {
      String url =
          "${AppConstants.animalKartStagingApiUrl}/order-tracking/intransit";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'x-admin-mobile': adminMobile,
          'Content-Type': AppConstants.applicationJson,
        },
        body: jsonEncode({"mobile": mobile ?? ""}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Handle the user and orders structure
        final Map<String, dynamic> userJson = data['user'] ?? {};
        final List<dynamic> ordersData = (data['orders'] is List)
            ? data['orders']
            : [];

        return ordersData.map((e) {
          return AnimalkartOrder.fromOrderAndUser(e, userJson);
        }).toList();
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
}
