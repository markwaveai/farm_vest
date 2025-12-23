import 'package:buffalo_visualizer/providers/simulation_provider.dart';
import 'package:buffalo_visualizer/widgets/asset_market_value.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/investor/models/unit_response.dart';
import 'package:farm_vest/features/investor/providers/buffalo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class AssetValuationScreen extends ConsumerStatefulWidget {
  const AssetValuationScreen({super.key});

  @override
  ConsumerState<AssetValuationScreen> createState() =>
      _AssetValuationScreenState();
}

class _AssetValuationScreenState extends ConsumerState<AssetValuationScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  @override
  void initState() {
    super.initState();
    // Sync simulation with user's actual unit count if available
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
        // Update simulation to match local units
        Future.microtask(() {
          ref
              .read(simulationProvider.notifier)
              .updateSettings(units: userUnits);
        });
      }
    }
  }

  // Reproduces logic from buffer_visualizer's CostEstimationTable to prepare data
  Map<String, dynamic> _processBuffaloDetails(Map<String, dynamic> treeData) {
    final buffaloList = treeData['buffaloes'] as List<dynamic>? ?? [];
    Map<String, dynamic> buffaloDetails = {};
    int counter = 1;

    // STEP 1: Parents (Gen 0)
    for (var buffalo in buffaloList) {
      if (buffalo['generation'] == 0) {
        // A, B, C...
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

  int _getBuffaloValueByAge(int ageInMonths) {
    if (ageInMonths >= 60) return 175000;
    if (ageInMonths >= 48) return 150000;
    if (ageInMonths >= 40) return 100000;
    if (ageInMonths >= 36) return 50000;
    if (ageInMonths >= 30) return 50000;
    if (ageInMonths >= 24) return 35000;
    if (ageInMonths >= 18) return 25000;
    if (ageInMonths >= 12) return 12000;
    if (ageInMonths >= 6) return 6000;
    return 3000;
  }

  Widget _buildTopStats(
    Map<String, dynamic> treeData,
    Map<String, dynamic>? revenueData,
  ) {
    // 1. Calculate Initial Investment
    final double units = (treeData['units'] as num?)?.toDouble() ?? 1.0;
    final double initialInvestment = units * 363000;

    // 2. Calculate Final Asset Value (at end of simulation)
    final startYear = treeData['startYear'] ?? DateTime.now().year;
    final int durationYears = (treeData['years'] as int?) ?? 10;
    final int lastYear = startYear + durationYears - 1;

    final buffaloDetails = _processBuffaloDetails(treeData);

    double finalAssetValue = 0;
    int totalAnimals = (treeData['totalBuffaloes'] as num?)?.toInt() ?? 0;

    if (totalAnimals == 0) {
      totalAnimals = buffaloDetails.values
          .where((b) => (b['birthYear'] as int) <= lastYear)
          .length;
    }

    buffaloDetails.forEach((k, buffalo) {
      final bYear = buffalo['birthYear'] as int;
      if (bYear <= lastYear) {
        final age = _calculateAgeInMonths(buffalo, lastYear, 11);
        finalAssetValue += _getBuffaloValueByAge(age);
      }
    });

    // 3. Total Revenue
    final double totalRevenue =
        (revenueData?['totalRevenue'] as num?)?.toDouble() ?? 0.0;

    // 4. ROI (Multiple)
    final double totalReturn = finalAssetValue + totalRevenue;
    final multiple = initialInvestment > 0
        ? (totalReturn / initialInvestment)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Initial Investment',
                  _currencyFormat.format(initialInvestment),
                  Icons.account_balance_wallet,
                  AppTheme.slate,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  _currencyFormat.format(totalRevenue),
                  Icons.monetization_on,
                  AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Projected Value',
                  _currencyFormat.format(finalAssetValue),
                  Icons.trending_up,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: _buildStatCard(
                  'Herd Growth',
                  '${multiple.toStringAsFixed(1)}x Returns\n$totalAnimals Buffaloes',
                  Icons.pets,
                  AppTheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simState = ref.watch(simulationProvider);

    // Listen for data loading to sync units
    ref.listen(unitResponseProvider, (prev, next) {
      next.whenData((response) => _syncUnits(response));
    });

    return Scaffold(
      body: simState.isLoading || simState.treeData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Column(
                children: [
                  _buildTopStats(simState.treeData!, simState.revenueData),
                  AssetMarketValueWidget(
                    treeData: simState.treeData!,
                    yearlyData:
                        (simState.revenueData?['yearlyData'] as List<dynamic>?)
                            ?.cast<Map<String, dynamic>>() ??
                        [],
                    formatCurrency: (d) => _currencyFormat.format(d),
                    formatNumber: (n) => _numberFormat.format(n),
                    calculateAgeInMonths: _calculateAgeInMonths,
                    buffaloDetails: _processBuffaloDetails(simState.treeData!),
                  ),
                ],
              ),
            ),
    );
  }
}
