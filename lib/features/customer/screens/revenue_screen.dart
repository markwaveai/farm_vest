import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class MonthlyRevenue {
  final String month;
  final double amount;
  final int milkQuantity;

  MonthlyRevenue({
    required this.month,
    required this.amount,
    required this.milkQuantity,
  });
}

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  bool _showChart = true;
  List<MonthlyRevenue> _revenueData = [];

  @override
  void initState() {
    super.initState();
    _generateRevenueData();
  }

  void _generateRevenueData() {
    _revenueData = [
      MonthlyRevenue(month: 'Jan', amount: 45000, milkQuantity: 900),
      MonthlyRevenue(month: 'Feb', amount: 48000, milkQuantity: 960),
      MonthlyRevenue(month: 'Mar', amount: 52000, milkQuantity: 1040),
      MonthlyRevenue(month: 'Apr', amount: 49000, milkQuantity: 980),
      MonthlyRevenue(month: 'May', amount: 55000, milkQuantity: 1100),
      MonthlyRevenue(month: 'Jun', amount: 58000, milkQuantity: 1160),
      MonthlyRevenue(month: 'Jul', amount: 61000, milkQuantity: 1220),
      MonthlyRevenue(month: 'Aug', amount: 59000, milkQuantity: 1180),
      MonthlyRevenue(month: 'Sep', amount: 62000, milkQuantity: 1240),
      MonthlyRevenue(month: 'Oct', amount: 65000, milkQuantity: 1300),
      MonthlyRevenue(month: 'Nov', amount: 68000, milkQuantity: 1360),
      MonthlyRevenue(month: 'Dec', amount: 72000, milkQuantity: 1440),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final totalRevenue = _revenueData.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final averageRevenue = totalRevenue / _revenueData.length;
    final currentMonth = _revenueData.last;
    final previousMonth = _revenueData[_revenueData.length - 2];
    final growth =
        ((currentMonth.amount - previousMonth.amount) / previousMonth.amount) *
        100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Till Date'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/customer-dashboard',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showChart ? Icons.table_chart : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _showChart = !_showChart;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Revenue',
                    '₹${NumberFormat('#,##,###').format(totalRevenue)}',
                    Icons.account_balance_wallet,
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildSummaryCard(
                    'Monthly Average',
                    '₹${NumberFormat('#,##,###').format(averageRevenue)}',
                    Icons.trending_up,
                    AppTheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'This Month',
                    '₹${NumberFormat('#,##,###').format(currentMonth.amount)}',
                    Icons.calendar_today,
                    AppTheme.darkSecondary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildSummaryCard(
                    'Growth',
                    '${growth.toStringAsFixed(1)}%',
                    growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    growth >= 0 ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Chart or Table Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Revenue Analysis', style: AppTheme.headingMedium),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Chart'),
                      icon: Icon(Icons.bar_chart),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Table'),
                      icon: Icon(Icons.table_chart),
                    ),
                  ],
                  selected: {_showChart},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _showChart = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Chart or Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: _showChart ? _buildChart() : _buildTable(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Insights
            const Text('Insights', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            _buildInsightCard(
              'Best Performing Month',
              'December 2024',
              '₹72,000 revenue with 1,440L milk production',
              Icons.star,
              AppTheme.successGreen,
            ),
            const SizedBox(height: AppConstants.spacingM),

            _buildInsightCard(
              'Average Daily Production',
              '40 Liters',
              'Consistent milk production throughout the year',
              Icons.water_drop,
              AppTheme.primary,
            ),
            const SizedBox(height: AppConstants.spacingM),

            _buildInsightCard(
              'Revenue Trend',
              'Positive Growth',
              'Steady increase in revenue over the past 6 months',
              Icons.trending_up,
              AppTheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
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
            Text(value, style: AppTheme.headingSmall.copyWith(color: color)),
            Text(title, style: AppTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 80000,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppTheme.darkGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = _revenueData[group.x.toInt()];
                return BarTooltipItem(
                  '${month.month}\n₹${NumberFormat('#,##,###').format(month.amount)}',
                  const TextStyle(color: AppTheme.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < _revenueData.length) {
                    return Text(
                      _revenueData[value.toInt()].month,
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
                getTitlesWidget: (double value, TitleMeta meta) {
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
          barGroups: _revenueData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.amount,
                  color: AppTheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusM),
              topRight: Radius.circular(AppConstants.radiusM),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Month', style: AppTheme.bodyMedium),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Revenue',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Milk (L)',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Table rows
        ...(_revenueData.reversed
            .take(6)
            .map(
              (revenue) => Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.lightGrey)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        revenue.month,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₹${NumberFormat('#,##,###').format(revenue.amount)}',
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${revenue.milkQuantity}',
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
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
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    value,
                    style: AppTheme.headingSmall.copyWith(color: color),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(description, style: AppTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
