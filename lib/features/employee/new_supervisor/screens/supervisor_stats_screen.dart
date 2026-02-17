import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class SupervisorStatsScreen extends ConsumerWidget {
  SupervisorStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(supervisorDashboardProvider);
    final stats = dashboardState.stats;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Farm Statistics'.tr(ref))),
      body: dashboardState.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCard(
                    context,
                    'Total Animals'.tr(ref),
                    stats.totalAnimals,
                    Icons.pets,
                    AppTheme.primary,
                  ),
                  SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    'Daily Milk Content'.tr(ref),
                    stats.milkToday,
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    'Active Health Issues'.tr(ref),
                    stats.activeIssues,
                    Icons.warning,
                    AppTheme.errorRed,
                  ),
                  SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    'Pending Transfers'.tr(ref),
                    stats.transfers,
                    Icons.move_down,
                    AppTheme.slate,
                  ),
                  SizedBox(height: 100), // Spacing for bottom nav
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
