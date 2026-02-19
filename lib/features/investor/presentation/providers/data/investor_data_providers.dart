import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:farm_vest/core/services/investor_api_services.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/investor/data/models/investor_summary_model.dart';
import 'package:farm_vest/features/investor/data/models/investor_coins_model.dart';
import 'package:flutter/foundation.dart';

/* -------------------------------------------------------------------------- */
/*                          DATA FETCH PROVIDERS                              */
/* -------------------------------------------------------------------------- */

/// Provider for investor animals list.
///
/// Fetches the list of animals from the `/api/investors/animals` endpoint.
/// This provider automatically fetches data when the access token is available.
///
/// Returns [InvestorAnimalsResponse] containing the list of animals,
/// or null if the token is not available or an error occurs.
///
/// Example:
/// ```dart
/// final animalsAsync = ref.watch(investorAnimalsProvider);
/// animalsAsync.when(
///   data: (response) => Text('Animals: ${response?.count}'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final investorAnimalsProvider = FutureProvider<InvestorAnimalsResponse?>((
  ref,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) return null;

    return await InvestorApiServices.getInvestorAnimals(token: token);
  } catch (e) {
    // Log error for debugging
    print('Error fetching investor animals: $e');
    return null;
  }
});

/// Provider for investor summary data.
///
/// Fetches summary and profile data from the `/api/investors/summary` endpoint.
/// This includes:
/// - Profile details (name, phone, email, etc.)
/// - Total buffaloes and calves count
/// - Asset value and revenue
///
/// Returns [InvestorSummaryResponse] or null if unavailable.
///
/// Example:
/// ```dart
/// final summaryAsync = ref.watch(investorSummaryProvider);
/// summaryAsync.when(
///   data: (response) {
///     final summary = response?.data;
///     return Text('Buffaloes: ${summary?.totalBuffaloes}');
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final investorSummaryProvider = FutureProvider<InvestorSummaryResponse?>((
  ref,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) return null;

    return await InvestorApiServices.getInvestorSummary(token: token);
  } catch (e) {
    // Log error for debugging
    print('Error fetching investor summary: $e');
    return null;
  }
});

/// Provider for investor coins (wallet balance).
///
/// Fetches the coin balance from the AnimalKart staging API.
final investorCoinsProvider = FutureProvider<InvestorCoinsResponse?>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final mobile = authState.userData?.mobile;

  if (mobile == null || mobile.isEmpty) return null;

  try {
    return await ApiServices.getInvestorCoins(mobile);
  } catch (e) {
    debugPrint('Error in investorCoinsProvider: $e');
    return null;
  }
});
