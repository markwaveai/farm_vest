import 'package:buffalo_visualizer/providers/simulation_provider.dart';
import 'package:buffalo_visualizer/widgets/monthly_revenue_break.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/investor/data/models/unit_response.dart';
import 'package:farm_vest/features/investor/presentation/providers/buffalo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});

  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unitAsync = ref.read(unitResponseProvider);
      if (unitAsync.hasValue) {
        _syncUnits(unitAsync.value);
      }
    });
  }

  void _syncUnits(UnitResponse? response) {
    if (response?.overallStats?.totalUnits != null) {
      final userUnits = response!.overallStats!.totalUnits!.toDouble();
      final currentSimUnits = ref.read(simulationProvider).units;

      if (userUnits > 0 && userUnits != currentSimUnits) {
        Future.microtask(() {
          ref
              .read(simulationProvider.notifier)
              .updateSettings(units: userUnits);
        });
      }
    }
  }

  // --- Logic from CostEstimationTable to prepare data for Visualizer ---

  Map<String, dynamic> _processBuffaloDetails(Map<String, dynamic> treeData) {
    final buffaloList = treeData['buffaloes'] as List<dynamic>? ?? [];
    Map<String, dynamic> buffaloDetails = {};
    int counter = 1;

    // STEP 1: Parents (Gen 0)
    for (var buffalo in buffaloList) {
      if (buffalo['generation'] == 0) {
        final prefix = String.fromCharCode(65 + (counter - 1) % 26);
        final id = '$prefix${(counter - 1) ~/ 26 + 1}';
        counter++;

        buffaloDetails[buffalo['id'].toString()] = {
          'id': id,
          'originalId': buffalo['id'],
          'generation': 0,
          'unit': buffalo['unit'] ?? 1,
          'acquisitionMonth': buffalo['acquisitionMonth'] ?? 0,
          'birthYear':
              buffalo['birthYear'] ??
              ((treeData['startYear'] ?? DateTime.now().year) - 5),
          'birthMonth': buffalo['birthMonth'] ?? 0,
          'children': <dynamic>[],
        };
      }
    }

    // STEP 2: Children
    final sortedBuffaloes = [...buffaloList];
    sortedBuffaloes.sort(
      (a, b) => (a['generation'] as int).compareTo(b['generation'] as int),
    );

    for (var buffalo in sortedBuffaloes) {
      if (buffalo['generation'] > 0) {
        final parentEntry = buffaloDetails.entries.firstWhere(
          (entry) => entry.value['originalId'] == buffalo['parentId'],
          orElse: () => const MapEntry('null', {}),
        );

        if (parentEntry.key != 'null') {
          final parent = parentEntry.value;
          final int childIndex = (parent['children'] as List).length + 1;
          final childId = "${parent['id']}-$childIndex";

          final newBuffalo = {
            'id': childId,
            'originalId': buffalo['id'],
            'generation': buffalo['generation'],
            'unit': parent['unit'],
            'acquisitionMonth': parent['acquisitionMonth'],
            'birthYear': buffalo['birthYear'],
            'birthMonth':
                buffalo['birthMonth'] ?? buffalo['acquisitionMonth'] ?? 0,
            'children': <dynamic>[],
            'parentId': parent['originalId'],
          };

          buffaloDetails[buffalo['id'].toString()] = newBuffalo;
          (parent['children'] as List).add(newBuffalo);
        }
      }
    }

    return buffaloDetails;
  }

  int _calculateAgeInMonths(
    Map<String, dynamic> buffalo,
    int targetYear, [
    int targetMonth = 0,
  ]) {
    final birthYear = buffalo['birthYear'] as int;
    final birthMonth = buffalo['birthMonth'] as int;
    final totalMonths =
        (targetYear - birthYear) * 12 + (targetMonth - birthMonth);
    return totalMonths < 0 ? 0 : totalMonths;
  }

  int _calculateMonthlyRevenueForBuffalo(
    int acquisitionMonth,
    int currentMonth,
    int currentYear,
    int startYear,
    Map<String, dynamic> buffalo,
  ) {
    final generation = buffalo['generation'] as int? ?? 0;

    if (generation == 0) {
      final monthsSinceAcquisition =
          (currentYear - startYear) * 12 + (currentMonth - acquisitionMonth);

      if (monthsSinceAcquisition < 2) {
        return 0;
      }

      final productionMonth = monthsSinceAcquisition - 2;
      final cycleMonth = productionMonth % 12;

      if (cycleMonth < 5) return 9000;
      if (cycleMonth < 8) return 6000;
      return 0;
    } else {
      final ageInMonths = _calculateAgeInMonths(
        buffalo,
        currentYear,
        currentMonth,
      );

      if (ageInMonths < 38) {
        return 0;
      }

      final productionMonth = ageInMonths - 38;
      final cycleMonth = productionMonth % 12;

      if (cycleMonth < 5) return 9000;
      if (cycleMonth < 8) return 6000;
      return 0;
    }
  }

  Map<String, Map<String, Map<String, dynamic>>>
  _calculateDetailedMonthlyRevenue(
    Map<String, dynamic> treeData,
    Map<String, dynamic> buffaloDetails,
  ) {
    final startYear = treeData['startYear'] ?? DateTime.now().year;
    final years = treeData['years'] ?? 10;
    Map<String, Map<String, Map<String, dynamic>>> monthlyRevenue = {};

    for (int year = startYear; year < startYear + years; year++) {
      monthlyRevenue[year.toString()] = {};
      for (int month = 0; month < 12; month++) {
        monthlyRevenue[year.toString()]![month.toString()] = {
          'total': 0,
          'buffaloes': <String, dynamic>{},
        };
      }
    }

    buffaloDetails.forEach((buffaloMapKey, buffalo) {
      final birthYear = buffalo['birthYear'] as int;
      final acquisitionMonth = buffalo['acquisitionMonth'] as int;
      final displayId = buffalo['id'] as String;

      for (int year = startYear; year < startYear + years; year++) {
        if (year >= birthYear + 3) {
          for (int month = 0; month < 12; month++) {
            final revenue = _calculateMonthlyRevenueForBuffalo(
              acquisitionMonth,
              month,
              year,
              startYear,
              buffalo,
            );

            if (revenue > 0) {
              final yearStr = year.toString();
              final monthStr = month.toString();

              if (monthlyRevenue.containsKey(yearStr) &&
                  monthlyRevenue[yearStr]!.containsKey(monthStr)) {
                var entry = monthlyRevenue[yearStr]![monthStr]!;
                entry['total'] = (entry['total'] as int) + revenue;
                (entry['buffaloes'] as Map)[displayId] = revenue;
              }
            }
          }
        }
      }
    });

    return monthlyRevenue;
  }

  Widget _buildTopStats(Map<String, dynamic> treeData, double totalRevenue,bool isDark) {
    final duration = (treeData['years'] as int?) ?? 10;
    final avgMonthly = totalRevenue > 0 ? totalRevenue / (duration * 12) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              isDark,
              'Total Projected\nRevenue',
              _currencyFormat.format(totalRevenue),
              Icons.account_balance_wallet,
              AppTheme.secondary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _buildStatCard(
              isDark,
              'Monthly\nAverage',
              _currencyFormat.format(avgMonthly),
              Icons.calendar_today,
              AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    
    bool isDark,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
       // color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        //border: Border.all(color: Colors.grey.shade200),
        color: isDark ? const Color(0xFF1E1E1E) : AppTheme.white,
        border: Border.all(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
         ),

        boxShadow: [
          BoxShadow(
           // color: Colors.grey.withValues(alpha: 0.05),
           color: isDark
    ? AppTheme.black.withValues(alpha: 0.6)
    : AppTheme.grey.withValues(alpha: 0.05),

            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
           
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
               const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
             // color: Colors.grey.shade600,
              color:isDark?Colors.grey.shade400: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
            ],
          ),
         
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark? AppTheme.white : Colors.grey.shade900,
              //color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simState = ref.watch(simulationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen for data loading to sync units
    ref.listen(unitResponseProvider, (prev, next) {
      next.whenData((response) => _syncUnits(response));
    });

    Map<String, dynamic> buffaloDetails = {};
    Map<String, Map<String, Map<String, dynamic>>> monthlyRevenue = {};

    if (simState.treeData != null) {
      buffaloDetails = _processBuffaloDetails(simState.treeData!);
      monthlyRevenue = _calculateDetailedMonthlyRevenue(
        simState.treeData!,
        buffaloDetails,
      );
    }

    final totalRevenue =
        (simState.revenueData?['totalRevenue'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      body: simState.isLoading || simState.treeData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Column(
                children: [
                  _buildTopStats(simState.treeData!, totalRevenue,isDark),
                  MonthlyRevenueBreakWidget(
                    treeData: simState.treeData!,
                    buffaloDetails: buffaloDetails,
                    monthlyRevenue: monthlyRevenue,
                    calculateAgeInMonths: _calculateAgeInMonths,
                    formatCurrency: (amount) => _currencyFormat.format(amount),
                    monthNames: const [
                      "January",
                      "February",
                      "March",
                      "April",
                      "May",
                      "June",
                      "July",
                      "August",
                      "September",
                      "October",
                      "November",
                      "December",
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
