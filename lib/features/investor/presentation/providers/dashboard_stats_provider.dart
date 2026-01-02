import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'buffalo_provider.dart';

// Specific provider for dashboard stats to ensure fresh logic
final dashboardStatsProvider = Provider<AsyncValue<Map<String, dynamic>>>((
  ref,
) {
  final responseAsync = ref.watch(unitResponseProvider);

  return responseAsync.whenData((response) {
    // defaults
    String count = '0';
    String calves = '0';
    String revenue = '₹0';
    String buffaloes = '0';

    String assetValue = '₹0';
    if (response != null) {
      // 1. Counts from OverallStats
      if (response.overallStats != null) {
        count = (response.overallStats!.totalUnits ?? 0).toString();
        calves = (response.overallStats!.calvesCount ?? 0).toString();
        buffaloes = (response.overallStats!.buffaloesCount ?? 0).toString();
        assetValue =
            '₹${(response.overallStats!.totalAssetValue ?? 0).toStringAsFixed(0)}';
      }

      // 2. Financials
      if (response.financials != null) {
        revenue =
            '₹${(response.financials!.totalRevenueEarned ?? 0).toStringAsFixed(0)}';
      }
    }

    return {
      'count': count,
      'buffaloes': buffaloes,
      'calves': calves,
      'revenue': revenue,
      'assetValue': assetValue,
    };
  });
});
