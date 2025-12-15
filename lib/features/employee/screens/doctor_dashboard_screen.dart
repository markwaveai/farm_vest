import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/employee_dashboard_card.dart';

class HighPriorityCase {
  final String caseId;
  final String buffaloId;
  final String issueType;
  final String severity;
  final DateTime reportedAt;
  final String reportedBy;

  HighPriorityCase({
    required this.caseId,
    required this.buffaloId,
    required this.issueType,
    required this.severity,
    required this.reportedAt,
    required this.reportedBy,
  });
}

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<HighPriorityCase> _highPriorityCases = [];

  @override
  void initState() {
    super.initState();
    _generateHighPriorityCases();
  }

  void _generateHighPriorityCases() {
    _highPriorityCases = [
      HighPriorityCase(
        caseId: 'CASE-001',
        buffaloId: 'BUF-003',
        issueType: 'Severe Fever',
        severity: 'Critical',
        reportedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        reportedBy: 'Supervisor Kumar',
      ),
      HighPriorityCase(
        caseId: 'CASE-002',
        buffaloId: 'BUF-007',
        issueType: 'Infection',
        severity: 'High',
        reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        reportedBy: 'Assistant Sharma',
      ),
      HighPriorityCase(
        caseId: 'CASE-003',
        buffaloId: 'BUF-012',
        issueType: 'Breathing Issues',
        severity: 'High',
        reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
        reportedBy: 'Supervisor Kumar',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.go('/notifications'),
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
                    'Welcome, Dr. Patel!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  const Text(
                    'Providing quality healthcare for farm animals',
                    style: TextStyle(fontSize: 16, color: AppTheme.white),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Row(
                    children: [
                      _buildQuickStat('Active Cases', '12'),
                      const SizedBox(width: AppConstants.spacingL),
                      _buildQuickStat('Critical', '3'),
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
                  title: 'High Priority',
                  subtitle: 'Critical cases',
                  icon: Icons.priority_high,
                  color: AppTheme.errorRed,
                  onTap: () => _showHighPriorityCases(),
                ),
                EmployeeDashboardCard(
                  title: 'Assign Tasks',
                  subtitle: 'Delegate to assistants',
                  icon: Icons.assignment,
                  color: AppTheme.primary,
                  onTap: () => _showAssignTasksDialog(),
                ),
                EmployeeDashboardCard(
                  title: 'Treatment Plans',
                  subtitle: 'Medical instructions',
                  icon: Icons.medication,
                  color: AppTheme.secondary,
                  onTap: () => _showTreatmentPlans(),
                ),
                EmployeeDashboardCard(
                  title: 'Health Analytics',
                  subtitle: 'View reports',
                  icon: Icons.analytics,
                  color: AppTheme.darkSecondary,
                  onTap: () => _showHealthAnalytics(),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // High Priority Cases
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'High Priority Cases',
                  style: AppTheme.headingMedium,
                ),
                TextButton(
                  onPressed: () => _showHighPriorityCases(),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _highPriorityCases.take(3).length,
              itemBuilder: (context, index) {
                final priorityCase = _highPriorityCases[index];
                return _buildPriorityCaseCard(priorityCase);
              },
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Today's Schedule
            const Text('Today\'s Schedule', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                child: Column(
                  children: [
                    _buildScheduleItem(
                      '09:00 AM',
                      'Health Checkup',
                      'BUF-001, BUF-002, BUF-003',
                      Icons.medical_services,
                      AppTheme.primary,
                    ),
                    const Divider(),
                    _buildScheduleItem(
                      '11:30 AM',
                      'Vaccination Round',
                      'Section A - 5 animals',
                      Icons.vaccines,
                      AppTheme.secondary,
                    ),
                    const Divider(),
                    _buildScheduleItem(
                      '02:00 PM',
                      'Treatment Follow-up',
                      'BUF-007 - Infection treatment',
                      Icons.healing,
                      AppTheme.warningOrange,
                    ),
                    const Divider(),
                    _buildScheduleItem(
                      '04:30 PM',
                      'Emergency Consultation',
                      'Available for urgent cases',
                      Icons.emergency,
                      AppTheme.errorRed,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                  child: Icon(
                    Icons.medical_services,
                    size: 30,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                const Text(
                  'Dr. Priya Patel',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Veterinary Doctor',
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
            leading: const Icon(Icons.priority_high),
            title: const Text('High Priority Cases'),
            onTap: () {
              Navigator.pop(context);
              _showHighPriorityCases();
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Assign Tasks'),
            onTap: () {
              Navigator.pop(context);
              _showAssignTasksDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.medication),
            title: const Text('Treatment Plans'),
            onTap: () {
              Navigator.pop(context);
              _showTreatmentPlans();
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Health Analytics'),
            onTap: () {
              Navigator.pop(context);
              _showHealthAnalytics();
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

  Widget _buildPriorityCaseCard(HighPriorityCase priorityCase) {
    Color severityColor;
    switch (priorityCase.severity.toLowerCase()) {
      case 'critical':
        severityColor = AppTheme.errorRed;
        break;
      case 'high':
        severityColor = AppTheme.warningOrange;
        break;
      default:
        severityColor = AppTheme.mediumGrey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    priorityCase.severity,
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  priorityCase.caseId,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            Text(
              '${priorityCase.buffaloId} - ${priorityCase.issueType}',
              style: AppTheme.headingSmall.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppConstants.spacingS),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: AppConstants.iconS,
                  color: AppTheme.mediumGrey,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  DateFormat('hh:mm a').format(priorityCase.reportedAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Icon(
                  Icons.person,
                  size: AppConstants.iconS,
                  color: AppTheme.mediumGrey,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  priorityCase.reportedBy,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _acceptCase(priorityCase),
                    child: const Text('Accept Case'),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _assignToAssistant(priorityCase),
                    child: const Text('Assign'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    String time,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
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
                Row(
                  children: [
                    Text(
                      time,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.mediumGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Text(
                      title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXS),
                Text(description, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHighPriorityCases() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            children: [
              const Text('High Priority Cases', style: AppTheme.headingMedium),
              const SizedBox(height: AppConstants.spacingL),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _highPriorityCases.length,
                  itemBuilder: (context, index) {
                    final priorityCase = _highPriorityCases[index];
                    return _buildPriorityCaseCard(priorityCase);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignTasksDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Tasks'),
        content: const Text(
          'Task assignment functionality will be implemented here.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTreatmentPlans() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Treatment Plans'),
        content: const Text(
          'Treatment plan management functionality will be implemented here.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHealthAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Analytics'),
        content: const Text(
          'Health analytics and reporting functionality will be implemented here.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _acceptCase(HighPriorityCase priorityCase) {
    ToastUtils.showSuccess(
      context,
      'Case ${priorityCase.caseId} accepted successfully!',
    );
  }

  void _assignToAssistant(HighPriorityCase priorityCase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign to Assistant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Case: ${priorityCase.caseId}'),
            Text('Buffalo: ${priorityCase.buffaloId}'),
            const SizedBox(height: AppConstants.spacingM),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Assistant'),
              items: ['Assistant Kumar', 'Assistant Sharma', 'Assistant Patel']
                  .map(
                    (assistant) => DropdownMenuItem(
                      value: assistant,
                      child: Text(assistant),
                    ),
                  )
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtils.showSuccess(
                context,
                'Case assigned to assistant successfully!',
              );
            },
            child: const Text('Assign'),
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
