import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/alert_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/check_list.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/left_strip_alert_card.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/quick_actions_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Converted to ConsumerWidget for Riverpod integration
class NewSupervisorDashboard extends ConsumerWidget {
  const NewSupervisorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 2. State is now managed by the provider
    final dashboardState = ref.watch(supervisorDashboardProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.width * 0.18,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, Supervisor",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              "Farm: Kurnool Main",
              style: TextStyle(
                fontSize: screenWidth * 0.022,
                color: AppTheme.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      // 3. Handle loading state from the provider
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 4. All stat cards now use data from the provider
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CustomCard(
                        color: AppTheme.lightPrimary,
                        type: DashboardCardType.priority,
                        onTap: () {},
                        child: LeftStripAlertCard(
                            icon: Icons.pets,
                            stripColor: AppTheme.primary,
                            subtitle: dashboardState.stats.totalAnimals,
                            title: 'Total Animals'),
                      ),
                      CustomCard(
                          color: AppTheme.errorRed,
                          type: DashboardCardType.priority,
                          onTap: () {},
                          child: LeftStripAlertCard(
                              icon: Icons.water_drop,
                              stripColor: AppTheme.errorRed,
                              subtitle: dashboardState.stats.milkToday,
                              title: 'Milk Today')),
                      CustomCard(
                          color: AppTheme.errorRed,
                          type: DashboardCardType.priority,
                          onTap: () {},
                          child: LeftStripAlertCard(
                              icon: Icons.warning,
                              stripColor: AppTheme.errorRed,
                              subtitle: dashboardState.stats.activeIssues,
                              title: 'Active Issues')),
                      CustomCard(
                          color: AppTheme.successGreen,
                          type: DashboardCardType.priority,
                          onTap: () {},
                          child: LeftStripAlertCard(
                              icon: Icons.move_down,
                              stripColor: AppTheme.successGreen,
                              subtitle: dashboardState.stats.transfers,
                              title: 'Transfers')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(
                            context: context, type: QuickActionType.onboardAnimal),
                        child: const QuickActionCard(
                            icon: Icons.add, label: 'Onboard Animal'),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(
                            context: context, type: QuickActionType.milkEntry),
                        child: const QuickActionCard(
                            label: 'Milk Entry', icon: Icons.water_drop),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(
                            context: context, type: QuickActionType.healthTicket),
                        child: const QuickActionCard(
                            label: 'Health ticket', icon: Icons.medical_services),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(
                            context: context, type: QuickActionType.transferRequest),
                        child: const QuickActionCard(
                            icon: Icons.compare_arrows, label: 'Transfer Tickets'),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(
                            context: context, type: QuickActionType.locateAnimal),
                        child: const QuickActionCard(
                            label: 'Locate Animal', icon: Icons.search),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 5. Checklist is now cleaner, but could also be moved to the provider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Checklist",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.045, // 4.5% of width
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                        const SizedBox(height: 12),
                        const CustomCheckboxTile(
                          title: 'Morning Feed Check',
                          value: true,
                          onChanged: null, // This would be handled by the provider
                        ),
                        const CustomCheckboxTile(
                          title: 'Water Troughs Cleaning',
                          value: true,
                          onChanged: null,
                        ),
                        const CustomCheckboxTile(
                          title: 'Afternoon Shed Wash',
                          value: false,
                          onChanged: null,
                        ),
                        const CustomCheckboxTile(
                          title: 'Evening Milking Count',
                          value: false,
                          onChanged: null,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
