import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'buffalo_provider.dart';

// Specific provider for dashboard stats to ensure fresh logic
final dashboardStatsProvider = Provider<AsyncValue<Map<String, dynamic>>>((
  ref,
) {
  final responseAsync = ref.watch(unitResponseProvider);

  return responseAsync.whenData((response) {
    // defaults
    String initialInvestment = '₹0';
    String calves = '0';
    String revenue = '₹0';
    String buffaloes = '0';
    String assetValue = '₹0';

    if (response != null) {
      // 1. Counts from OverallStats
      if (response.overallStats != null) {
        calves = (response.overallStats!.calvesCount ?? 0).toString();
        buffaloes = (response.overallStats!.buffaloesCount ?? 0).toString();
        assetValue = (response.overallStats!.totalAssetValue ?? 0).toString();
      }

      // 2. Financials
      if (response.financials != null) {
        revenue =
            '₹${(response.financials!.totalRevenueEarned ?? 0).toStringAsFixed(0)}';
        // Mapping initial investment from what we'll populate in ApiServices
        initialInvestment =
            '₹${(response.financials!.investmentWithCPF ?? 0).toStringAsFixed(0)}';
      }
    }

    return {
      'initialInvestment': initialInvestment,
      'buffaloes': buffaloes,
      'calves': calves,
      'revenue': revenue,
      'assetValue': assetValue,
    };
  });
});
