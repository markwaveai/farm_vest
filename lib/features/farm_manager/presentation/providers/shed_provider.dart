import 'package:farm_vest/features/farm_manager/data/models/shed_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final availableShedsProvider = FutureProvider<List<Shed>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  if (token == null) {
    throw Exception('No token found');
  }
  // return ApiServices.getAvailableSheds(token);
  return [];
});
