import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class ValuationFactor {
  final String name;
  final double weight;
  final double score;
  final String description;

  ValuationFactor({
    required this.name,
    required this.weight,
    required this.score,
    required this.description,
  });
}

class AssetValuationScreen extends StatefulWidget {
  const AssetValuationScreen({super.key});

  @override
  State<AssetValuationScreen> createState() => _AssetValuationScreenState();
}

class _AssetValuationScreenState extends State<AssetValuationScreen> {
  final double _currentValuation = 185000;
  final double _lastMonthValuation = 178000;
  final List<ValuationFactor> _factors = [
    ValuationFactor(
      name: 'Age',
      weight: 0.25,
      score: 0.85,
      description: '4 years 2 months - Prime productive age',
    ),
    ValuationFactor(
      name: 'Milk Production',
      weight: 0.35,
      score: 0.92,
      description: '12L/day - Above average production',
    ),
    ValuationFactor(
      name: 'Health Score',
      weight: 0.25,
      score: 0.95,
      description: 'Excellent health with no major issues',
    ),
    ValuationFactor(
      name: 'Market Price',
      weight: 0.15,
      score: 0.88,
      description: 'Current market conditions favorable',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final valuationChange = _currentValuation - _lastMonthValuation;
    final changePercentage = (valuationChange / _lastMonthValuation) * 100;
    final overallScore = _factors.fold(
      0.0,
      (sum, factor) => sum + (factor.score * factor.weight),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Valuation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/customer-dashboard',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Valuation Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Valuation',
                      style: TextStyle(color: AppTheme.white, fontSize: 16),
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      '₹${NumberFormat('#,##,###').format(_currentValuation)}',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Row(
                      children: [
                        Icon(
                          changePercentage >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: AppTheme.white,
                          size: AppConstants.iconS,
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          '₹${NumberFormat('#,###').format(valuationChange.abs())} (${changePercentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingS),
                        const Text(
                          'vs last month',
                          style: TextStyle(color: AppTheme.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Valuation Growth Chart
            const Text('Valuation Trend', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec',
                              ];
                              if (value.toInt() < months.length) {
                                return Text(
                                  months[value.toInt()],
                                  style: AppTheme.bodySmall,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toInt()}K',
                                style: AppTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 165000),
                            FlSpot(1, 168000),
                            FlSpot(2, 172000),
                            FlSpot(3, 175000),
                            FlSpot(4, 178000),
                            FlSpot(5, 185000),
                          ],
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.secondary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Valuation Factors
            const Text('Valuation Factors', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Column(
                  children: [
                    // Overall Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Overall Score',
                          style: AppTheme.headingSmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusS,
                            ),
                          ),
                          child: Text(
                            '${(overallScore * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // Factor breakdown
                    ...(_factors.map((factor) => _buildFactorRow(factor))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Comparison with Market
            const Text('Market Comparison', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Expanded(
                  child: _buildComparisonCard(
                    'Market Average',
                    '₹165,000',
                    'Similar age & breed',
                    Icons.trending_flat,
                    AppTheme.mediumGrey,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildComparisonCard(
                    'Your Asset',
                    '₹185,000',
                    '12% above market',
                    Icons.trending_up,
                    AppTheme.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Recommendations
            const Text('Recommendations', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            _buildRecommendationCard(
              'Maintain Health Standards',
              'Continue regular health checkups to maintain the excellent health score',
              Icons.health_and_safety,
              AppTheme.successGreen,
            ),
            const SizedBox(height: AppConstants.spacingM),

            _buildRecommendationCard(
              'Optimize Milk Production',
              'Consider nutrition supplements to potentially increase daily milk yield',
              Icons.water_drop,
              AppTheme.primary,
            ),
            const SizedBox(height: AppConstants.spacingM),

            _buildRecommendationCard(
              'Monitor Market Trends',
              'Keep track of market prices for better valuation timing',
              Icons.analytics,
              AppTheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(ValuationFactor factor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                factor.name,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(factor.score * 100).toStringAsFixed(0)}%',
                style: AppTheme.bodyMedium.copyWith(
                  color: _getScoreColor(factor.score),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          LinearProgressIndicator(
            value: factor.score,
            backgroundColor: AppTheme.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(factor.score),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            factor.description,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppConstants.iconL),
            const SizedBox(height: AppConstants.spacingS),
            Text(title, style: AppTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              value,
              style: AppTheme.headingSmall.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: AppConstants.iconM),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return AppTheme.successGreen;
    if (score >= 0.7) return AppTheme.primary;
    if (score >= 0.5) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }
}
