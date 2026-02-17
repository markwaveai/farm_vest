import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_vest/features/investor/data/models/investor_summary_model.dart';
import 'package:farm_vest/features/investor/presentation/providers/data/investor_data_providers.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
/* -------------------------------------------------------------------------- */
/*                          STATISTICS PROVIDERS                              */
/* -------------------------------------------------------------------------- */

/// Provider for buffalo statistics.
///
/// Provides dashboard statistics from the investor summary including:
/// - Total buffalo count
/// - Total calves count
/// - Total asset value (formatted)
/// - Total revenue (formatted)
///
/// Returns a Map with string keys and dynamic values for easy display.
///
/// Example:
/// ```dart
/// final statsAsync = ref.watch(buffaloStatsProvider);
/// statsAsync.when(
///   data: (stats) => Column(
///     children: [
///       Text('Buffaloes: ${stats['count']}'),
///       Text('Asset Value: ${stats['assetValue']}'),
///     ],
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
final buffaloStatsProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final summaryAsync = ref.watch(investorSummaryProvider);

  return summaryAsync.whenData((response) {
    if (response == null) {
      return {'count': '0', 'calves': '0', 'assetValue': '₹0', 'revenue': '₹0'};
    }

    final summary = response.data;
    return {
      'count': summary.totalBuffaloes.toString(),
      'calves': summary.totalCalves.toString(),
      'assetValue': summary.formattedAssetValue,
      'revenue': summary.formattedRevenue,
    };
  });
});

/// Provider for investor profile.
///
/// Extracts profile details from the summary response.
/// Returns [InvestorProfileDetails] containing:
/// - First and last name
/// - Phone number
/// - Email address
/// - Full address
/// - Member since date
///
/// Example:
/// ```dart
/// final profileAsync = ref.watch(investorProfileProvider);
/// profileAsync.when(
///   data: (profile) => profile != null
///       ? Text('Welcome, ${profile.fullName}')
///       : Text('No profile'.tr(ref)),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error loading profile'.tr(ref)),
/// );
/// ```
final investorProfileProvider = Provider<AsyncValue<InvestorProfileDetails?>>((
  ref,
) {
  final summaryAsync = ref.watch(investorSummaryProvider);

  return summaryAsync.whenData((response) {
    return response?.data.profileDetails;
  });
});
