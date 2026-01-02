import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/presentation/widgets/employee_dashboard_card.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Supervisor Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.go(
                '/notifications',
                extra: {'fallbackRoute': '/supervisor-dashboard'},
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
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
                      'Welcome, Supervisor!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    const Text(
                      'Manage farm operations efficiently',
                      style: TextStyle(fontSize: 16, color: AppTheme.white),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Row(
                      children: [
                        _buildQuickStat('Units', '15'),
                        const SizedBox(width: AppConstants.spacingL),
                        _buildQuickStat('Today\'s Milk', '180L'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Quick Actions
              const Text('Quick Actions', style: AppTheme.headingMedium),
              const SizedBox(height: AppConstants.spacingM),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.spacingM,
                mainAxisSpacing: AppConstants.spacingM,
                childAspectRatio: 1.1,
                children: [
                  EmployeeDashboardCard(
                    title: 'Milk Production',
                    subtitle: 'Enter daily records',
                    icon: Icons.water_drop,
                    color: AppTheme.primary,
                    onTap: () => context.go('/milk-production'),
                  ),
                  EmployeeDashboardCard(
                    title: 'Health Updates',
                    subtitle: 'Report health issues',
                    icon: Icons.medical_services,
                    color: AppTheme.secondary,
                    onTap: () => context.go('/health-issues'),
                  ),
                  EmployeeDashboardCard(
                    title: 'Raise Ticket',
                    subtitle: 'Report problems',
                    icon: Icons.report_problem,
                    color: AppTheme.warningOrange,
                    onTap: () => context.go('/raise-ticket'),
                  ),
                  EmployeeDashboardCard(
                    title: 'Profile',
                    subtitle: 'View your info',
                    icon: Icons.person,
                    color: AppTheme.darkSecondary,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Recent Activities
              const Text('Recent Activities', style: AppTheme.headingMedium),
              const SizedBox(height: AppConstants.spacingM),

              _buildActivityCard(
                'Milk Production Entry',
                'Morning: 85L, Evening: 78L',
                'Today, 9:30 AM',
                Icons.water_drop,
                AppTheme.primary,
              ),
              _buildActivityCard(
                'Health Issue Reported',
                'BUF-003: Minor fever detected',
                'Yesterday, 3:45 PM',
                Icons.medical_services,
                AppTheme.warningOrange,
              ),
              _buildActivityCard(
                'Ticket Raised',
                'Feed shortage in Section A',
                '2 days ago, 11:20 AM',
                Icons.report_problem,
                AppTheme.errorRed,
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Pending Approvals
              const Text('Pending Approvals', style: AppTheme.headingMedium),
              const SizedBox(height: AppConstants.spacingM),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  child: Column(
                    children: [
                      _buildApprovalItem(
                        'Transfer Request',
                        'BUF-007 to Section B',
                        'Dr. Patel',
                        () => _showApprovalDialog('Transfer Request'),
                      ),
                      const Divider(),
                      _buildApprovalItem(
                        'Treatment Plan',
                        'Antibiotic course for BUF-012',
                        'Dr. Sharma',
                        () => _showApprovalDialog('Treatment Plan'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.white,
                  child: Icon(Icons.person, size: 30, color: AppTheme.primary),
                ),
                const SizedBox(height: AppConstants.spacingM),
                const Text(
                  'Rajesh Kumar',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Supervisor',
                  style: TextStyle(color: AppTheme.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text('Milk Production'),
            onTap: () {
              Navigator.pop(context);
              context.go('/milk-production');
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Health Issues'),
            onTap: () {
              Navigator.pop(context);
              context.go('/health-issues');
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Tickets'),
            onTap: () {
              Navigator.pop(context);
              context.go('/raise-ticket');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to reports
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _showLogoutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.white),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: AppConstants.iconM),
        ),
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              time,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildApprovalItem(
    String title,
    String description,
    String requester,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        children: [
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
                Text(description, style: AppTheme.bodySmall),
                const SizedBox(height: AppConstants.spacingXS),
                Text(
                  'Requested by: $requester',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
                vertical: AppConstants.spacingS,
              ),
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Do you want to approve this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtils.showSuccess(context, 'Request approved successfully!');
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/user-type-selection');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
