import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupervisorStatsScreen extends ConsumerWidget {
  const SupervisorStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(supervisorDashboardProvider);
    final stats = dashboardState.stats;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Farm Statistics')),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCard(
                    context,
                    'Total Animals',
                    stats.totalAnimals,
                    Icons.pets,
                    AppTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    'Daily Milk Content',
                    stats.milkToday,
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    'Active Health Issues',
                    stats.activeIssues,
                    Icons.warning,
                    AppTheme.errorRed,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    context,
                    'Pending Transfers',
                    stats.transfers,
                    Icons.move_down,
                    AppTheme.slate,
                  ),
                  const SizedBox(height: 100), // Spacing for bottom nav
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
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
              const SizedBox(height: 4),
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
