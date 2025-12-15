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
    String netProfit = '₹0';

    String buffaloes = '0';

    if (response != null) {
      // 1. Counts from OverallStats
      if (response.overallStats != null) {
        count = (response.overallStats!.totalUnits ?? 0).toString();
        calves = (response.overallStats!.totalCalves ?? 0).toString();
      }

      // Calculate Buffalo Count manually as it's not in overallStats
      if (response.units != null) {
        int buffaloSum = 0;
        for (var unit in response.units!) {
          if (unit.paymentStatus == 'PAID') {
            buffaloSum += unit.buffaloCount ?? 0;
          }
        }
        buffaloes = buffaloSum.toString();
      }

      // 2. Financials
      if (response.financials != null) {
        revenue =
            '₹${(response.financials!.totalRevenueEarned ?? 0).toStringAsFixed(0)}';
        netProfit =
            '₹${(response.financials!.netProfit ?? 0).toStringAsFixed(0)}';
      }
    }

    return {
      'count': count,
      'buffaloes': buffaloes,
      'calves': calves,
      'revenue': revenue,
      'netProfit': netProfit,
    };
  });
});
