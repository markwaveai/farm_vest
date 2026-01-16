import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/alert_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/check_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewSupervisorDashboard extends ConsumerWidget {
  const NewSupervisorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dashboardState = ref.watch(supervisorDashboardProvider);
    final dashboardNotifier = ref.read(supervisorDashboardProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        toolbarHeight: screenWidth * 0.18,
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
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CustomCard(
                        color: AppTheme.primary,
                        type: DashboardCardType.priority,
                        onTap: () {},
                        child: _buildStatContent(context, Icons.pets, dashboardState.stats.totalAnimals, 'Total Animals', AppTheme.primary),
                      ),
                      CustomCard(
                        color: AppTheme.errorRed,
                        type: DashboardCardType.priority,
                        onTap: () {},
                        child: _buildStatContent(context, Icons.water_drop, dashboardState.stats.milkToday, 'Milk Today', AppTheme.lightSecondary),
                      ),
                      CustomCard(
                        color: AppTheme.errorRed,
                        type: DashboardCardType.priority,
                        onTap: () {},
                        child: _buildStatContent(context, Icons.warning, dashboardState.stats.activeIssues, 'Active Issues', AppTheme.warningOrange),
                      ),
                      CustomCard(
                        color: AppTheme.successGreen,
                        type: DashboardCardType.priority,
                        onTap: () {},
                        child: _buildStatContent(context, Icons.move_down, dashboardState.stats.transfers, 'Transfers', AppTheme.darkGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
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
                        onTap: () => showQuickActionDialog(context: context, type: QuickActionType.onboardAnimal),
                        child: _buildQuickActionContent(context, Icons.add, 'Onboard Animal', AppTheme.darkPrimary),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(context: context, type: QuickActionType.milkEntry),
                        child: _buildQuickActionContent(context, Icons.water_drop, 'Milk Entry', AppTheme.darkSecondary),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(context: context, type: QuickActionType.healthTicket),
                        child: _buildQuickActionContent(context, Icons.medical_services, 'Health ticket', AppTheme.darkSecondary),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(context: context, type: QuickActionType.transferRequest),
                        child: _buildQuickActionContent(context, Icons.compare_arrows, 'Transfer Tickets', AppTheme.slate),
                      ),
                      CustomCard(
                        type: DashboardCardType.stats,
                        onTap: () => showQuickActionDialog(context: context, type: QuickActionType.locateAnimal),
                        child: _buildQuickActionContent(context, Icons.search, 'Locate Animal', AppTheme.darkSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        const SizedBox(height: 12),
                        CustomCheckboxTile(
                          title: 'Morning Feed Check',
                          value: dashboardState.morningFeed,
                          onChanged: (val) => dashboardNotifier.toggleMorningFeed(val!),
                        ),
                        CustomCheckboxTile(
                          title: 'Water Troughs Cleaning',
                          value: dashboardState.waterCleaning,
                          onChanged: (val) => dashboardNotifier.toggleWaterCleaning(val!),
                        ),
                        CustomCheckboxTile(
                          title: 'Afternoon Shed Wash',
                          value: dashboardState.shedWash,
                          onChanged: (val) => dashboardNotifier.toggleShedWash(val!),
                        ),
                        CustomCheckboxTile(
                          title: 'Evening Milking Count',
                          value: dashboardState.eveningMilking,
                          onChanged: (val) => dashboardNotifier.toggleEveningMilking(val!),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildStatContent(BuildContext context, IconData icon, String subtitle, String title, Color iconColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.08;
    final subtitleFontSize = screenWidth * 0.040;
    final titleFontSize = screenWidth * 0.035;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionContent(BuildContext context, IconData icon, String label, Color iconColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.08;
    final textSize = screenWidth * 0.035;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
