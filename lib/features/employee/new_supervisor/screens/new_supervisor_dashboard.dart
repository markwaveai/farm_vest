import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/alert_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:shimmer/shimmer.dart';

class NewSupervisorDashboard extends ConsumerWidget {
  const NewSupervisorDashboard({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dashboardState = ref.watch(supervisorDashboardProvider);

    final authState = ref.watch(authProvider);
    final user = authState.userData;

    // Use dynamic data from user profile
    final farmName = user?.farmName ?? "Farm";
    final shedName = user?.shedName ?? "Shed";
    final farmLocation = user?.farmLocation ?? "Location";
    final displayName = user?.firstName ?? "Supervisor";

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        toolbarHeight: screenWidth * 0.22,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $displayName",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$farmName • $shedName",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: AppTheme.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Location: $farmLocation",
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: AppTheme.slate,
              ),
            ),
          ],
        ),
        actions: [
          if (ref.watch(authProvider).availableRoles.length > 1)
            IconButton(
              onPressed: () => _showSwitchRoleBottomSheet(context, ref),
              icon: const Icon(Icons.swap_horiz_rounded),
              tooltip: 'Switch Role',
            ),
          IconButton(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: dashboardState.isLoading
          ? _buildLoadingShimmer(context)
          : dashboardState.error != null
          ? Center(child: Text(dashboardState.error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CustomCard(
                        color: AppTheme.primary,
                        type: DashboardCardType.priority,
                        onTap: () => context.go('/new-supervisor/buffalo'),
                        child: _buildStatContent(
                          context,
                          Icons.pets,
                          dashboardState.stats.totalAnimals,
                          'Total Animals',
                          AppTheme.primary,
                        ),
                      ),
                      CustomCard(
                        color: AppTheme.errorRed,
                        type: DashboardCardType.priority,
                        onTap: () {},
                        child: _buildStatContent(
                          context,
                          Icons.water_drop,
                          dashboardState.stats.milkToday,
                          'Milk Today',
                          AppTheme.lightSecondary,
                        ),
                      ),
                      CustomCard(
                        color: AppTheme.warningOrange,
                        type: DashboardCardType.priority,
                        onTap: () {},
                        child: _buildStatContent(
                          context,
                          Icons.warning,
                          dashboardState.stats.activeIssues,
                          'Active Issues',
                          AppTheme.warningOrange,
                        ),
                      ),
                      CustomCard(
                        color: AppTheme.darkGrey,
                        type: DashboardCardType.priority,
                        onTap: () => context.go('/transfer-tickets'),
                        child: _buildStatContent(
                          context,
                          Icons.move_down,
                          dashboardState.stats.transfers,
                          'Transfers',
                          AppTheme.darkGrey,
                        ),
                      ),
                      CustomCard(
                        color: Colors.pink,
                        type: DashboardCardType.priority,
                        onTap: () {
                          final shedId = int.tryParse(user?.shedId ?? '');
                          if (shedId != null) {
                            context.go(
                              '/buffalo-allocation',
                              extra: {'shedId': shedId},
                            );
                          }
                        },
                        child: _buildStatContent(
                          context,
                          Icons.hourglass_empty_rounded,
                          dashboardState.stats.pendingAllocations,
                          'Pending Allocation',
                          Colors.pink,
                        ),
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
                    childAspectRatio: 1.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CustomCard(
                        type: DashboardCardType.quickAction,
                        onTap: () => showQuickActionDialog(
                          context: context,
                          type: QuickActionType.milkEntry,
                          ref: ref,
                        ),
                        child: _buildQuickActionContent(
                          context,
                          Icons.water_drop,
                          'Milk Entry',
                          Colors.orange,
                        ),
                      ),
                      CustomCard(
                        type: DashboardCardType.quickAction,
                        onTap: () => showQuickActionDialog(
                          context: context,
                          type: QuickActionType.healthTicket,
                          ref: ref,
                        ),
                        child: _buildQuickActionContent(
                          context,
                          Icons.medical_services,
                          'Health ticket',
                          AppTheme.errorRed,
                        ),
                      ),
                      CustomCard(
                        type: DashboardCardType.quickAction,
                        onTap: () => context.go('/transfer-tickets'),
                        child: _buildQuickActionContent(
                          context,
                          Icons.compare_arrows,
                          'Transfer Tickets',
                          AppTheme.slate,
                        ),
                      ),
                      CustomCard(
                        type: DashboardCardType.quickAction,
                        onTap: () => showQuickActionDialog(
                          context: context,
                          type: QuickActionType.locateAnimal,
                          ref: ref,
                        ),
                        child: _buildQuickActionContent(
                          context,
                          Icons.search,
                          'Locate Animal',
                          Colors.orange,
                        ),
                      ),
                      CustomCard(
                        type: DashboardCardType.quickAction,
                        onTap: () {
                          final shedId = int.tryParse(user?.shedId ?? '');
                          if (shedId != null) {
                            context.go(
                              '/buffalo-allocation',
                              extra: {'shedId': shedId},
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No shed assigned to your profile',
                                ),
                              ),
                            );
                          }
                        },
                        child: _buildQuickActionContent(
                          context,
                          Icons.grid_view,
                          'View Buffalo Shed',
                          AppTheme.primary,
                        ),
                      ),
                      CustomCard(
                        type: DashboardCardType.quickAction,
                        onTap: () => context.go('/onboard-animal'),
                        child: _buildQuickActionContent(
                          context,
                          Icons.add_business_rounded,
                          'Buffalo Onboarding',
                          AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: List.generate(4, (index) => const ShimmerCard()),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 10,
            width: MediaQuery.of(context).size.width - 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: List.generate(4, (index) => const ShimmerCard()),
        ),
      ],
    );
  }

  Widget _buildStatContent(
    BuildContext context,
    IconData icon,
    String subtitle,
    String title,
    Color iconColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.07;
    final subtitleFontSize = screenWidth * 0.040;
    final titleFontSize = screenWidth * 0.030;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(height: 4),
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
          style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildQuickActionContent(
    BuildContext context,
    IconData icon,
    String label,
    Color iconColor,
  ) {
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
          child: Icon(icon, color: iconColor, size: iconSize),
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

  Map<String, dynamic> _getRoleInfo(UserType role) {
    switch (role) {
      case UserType.admin:
        return {
          'label': 'Administrator',
          'icon': Icons.admin_panel_settings,
          'color': Colors.blue,
        };
      case UserType.farmManager:
        return {
          'label': 'Farm Manager',
          'icon': Icons.agriculture,
          'color': Colors.green,
        };
      case UserType.supervisor:
        return {
          'label': 'Supervisor',
          'icon': Icons.assignment_ind,
          'color': Colors.orange,
        };
      case UserType.doctor:
        return {
          'label': 'Doctor',
          'icon': Icons.medical_services,
          'color': Colors.red,
        };
      case UserType.assistant:
        return {
          'label': 'Assistant Doctor',
          'icon': Icons.health_and_safety,
          'color': Colors.teal,
        };
      case UserType.customer:
        return {
          'label': 'Investor',
          'icon': Icons.trending_up,
          'color': Colors.indigo,
        };
    }
  }

  void _showSwitchRoleBottomSheet(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final availableRoles = authState.availableRoles;
    final currentRole = authState.role;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Active Role',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose which portal you want to access',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ...availableRoles.map((role) {
                final info = _getRoleInfo(role);
                final isSelected = role == currentRole;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: isSelected
                        ? null
                        : () async {
                            Navigator.pop(context);
                            await ref
                                .read(authProvider.notifier)
                                .selectRole(role);

                            if (!context.mounted) return;
                            switch (role) {
                              case UserType.admin:
                                context.go('/admin-dashboard');
                                break;
                              case UserType.farmManager:
                                context.go('/farm-manager-dashboard');
                                break;
                              case UserType.supervisor:
                                context.go('/supervisor-dashboard');
                                break;
                              case UserType.doctor:
                                context.go('/doctor-dashboard');
                                break;
                              case UserType.assistant:
                                context.go('/assistant-dashboard');
                                break;
                              case UserType.customer:
                                context.go('/customer-dashboard');
                                break;
                            }
                          },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? info['color']
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected
                        ? (info['color'] as Color).withOpacity(0.05)
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: (info['color'] as Color).withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        info['icon'] as IconData,
                        color: info['color'] as Color,
                      ),
                    ),
                    title: Text(
                      info['label'] as String,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: info['color'] as Color,
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
