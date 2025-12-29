import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/employee_dashboard_card.dart';

class AssignedTask {
  final String taskId;
  final String buffaloId;
  final String taskType;
  final String assignedBy;
  final DateTime assignedAt;
  final DateTime deadline;
  final String status;
  final String? instructions;

  AssignedTask({
    required this.taskId,
    required this.buffaloId,
    required this.taskType,
    required this.assignedBy,
    required this.assignedAt,
    required this.deadline,
    required this.status,
    this.instructions,
  });
}

class MonitoringRecord {
  final String buffaloId;
  final double temperature;
  final String eatingStatus;
  final bool medicineGiven;
  final DateTime recordedAt;

  MonitoringRecord({
    required this.buffaloId,
    required this.temperature,
    required this.eatingStatus,
    required this.medicineGiven,
    required this.recordedAt,
  });
}

class AssistantDashboardScreen extends StatefulWidget {
  const AssistantDashboardScreen({super.key});

  @override
  State<AssistantDashboardScreen> createState() =>
      _AssistantDashboardScreenState();
}

class _AssistantDashboardScreenState extends State<AssistantDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<AssignedTask> _assignedTasks = [];
  List<MonitoringRecord> _monitoringRecords = [];

  @override
  void initState() {
    super.initState();
    _generateAssignedTasks();
    _generateMonitoringRecords();
  }

  void _generateAssignedTasks() {
    _assignedTasks = [
      AssignedTask(
        taskId: 'TASK-001',
        buffaloId: 'BUF-003',
        taskType: 'Temperature Monitoring',
        assignedBy: 'Dr. Patel',
        assignedAt: DateTime.now().subtract(const Duration(hours: 2)),
        deadline: DateTime.now().add(const Duration(hours: 4)),
        status: 'In Progress',
        instructions:
            'Monitor temperature every 2 hours and report if above 102°F',
      ),
      AssignedTask(
        taskId: 'TASK-002',
        buffaloId: 'BUF-007',
        taskType: 'Medicine Administration',
        assignedBy: 'Dr. Sharma',
        assignedAt: DateTime.now().subtract(const Duration(hours: 6)),
        deadline: DateTime.now().add(const Duration(hours: 2)),
        status: 'Pending',
        instructions: 'Administer antibiotic injection twice daily',
      ),
      AssignedTask(
        taskId: 'TASK-003',
        buffaloId: 'BUF-012',
        taskType: 'Recovery Monitoring',
        assignedBy: 'Dr. Patel',
        assignedAt: DateTime.now().subtract(const Duration(days: 1)),
        deadline: DateTime.now().add(const Duration(hours: 8)),
        status: 'Completed',
        instructions: 'Monitor recovery progress and update status',
      ),
    ];
  }

  void _generateMonitoringRecords() {
    _monitoringRecords = [
      MonitoringRecord(
        buffaloId: 'BUF-003',
        temperature: 101.5,
        eatingStatus: 'Good',
        medicineGiven: true,
        recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      MonitoringRecord(
        buffaloId: 'BUF-007',
        temperature: 100.8,
        eatingStatus: 'Fair',
        medicineGiven: true,
        recordedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      MonitoringRecord(
        buffaloId: 'BUF-012',
        temperature: 100.2,
        eatingStatus: 'Excellent',
        medicineGiven: false,
        recordedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

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
          title: const Text('Assistant Dashboard'),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => context.push(
                '/notifications',
                extra: {'fallbackRoute': '/assistant-dashboard'},
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
                    'Welcome, Assistant Kumar!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  const Text(
                    'Supporting healthcare operations',
                    style: TextStyle(fontSize: 16, color: AppTheme.white),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  Row(
                    children: [
                      _buildQuickStat('Active Tasks', '8'),
                      const SizedBox(width: AppConstants.spacingL),
                      _buildQuickStat('Completed', '15'),
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
                  title: 'Assigned Tasks',
                  subtitle: 'View your tasks',
                  icon: Icons.assignment,
                  color: AppTheme.primary,
                  onTap: () => _showAssignedTasks(),
                ),
                EmployeeDashboardCard(
                  title: 'Daily Monitoring',
                  subtitle: 'Record observations',
                  icon: Icons.monitor_heart,
                  color: AppTheme.secondary,
                  onTap: () => _showDailyMonitoring(),
                ),
                EmployeeDashboardCard(
                  title: 'Treatment Execution',
                  subtitle: 'Follow instructions',
                  icon: Icons.medication,
                  color: AppTheme.darkSecondary,
                  onTap: () => _showTreatmentExecution(),
                ),
                EmployeeDashboardCard(
                  title: 'Completed Updates',
                  subtitle: 'Update progress',
                  icon: Icons.check_circle,
                  color: AppTheme.successGreen,
                  onTap: () => _showCompletedUpdates(),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Assigned Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Assigned Tasks',
                  style: AppTheme.headingMedium,
                ),
                TextButton(
                  onPressed: () => _showAssignedTasks(),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assignedTasks.take(3).length,
              itemBuilder: (context, index) {
                final task = _assignedTasks[index];
                return _buildTaskCard(task);
              },
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Recent Monitoring Records
            const Text(
              'Recent Monitoring Records',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppConstants.spacingM),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _monitoringRecords.take(3).length,
              itemBuilder: (context, index) {
                final record = _monitoringRecords[index];
                return _buildMonitoringCard(record);
              },
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
                  child: Icon(
                    Icons.support_agent,
                    size: 30,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingM),
                const Text(
                  'Ravi Kumar',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Assistant',
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
            leading: const Icon(Icons.assignment),
            title: const Text('Assigned Tasks'),
            onTap: () {
              Navigator.pop(context);
              _showAssignedTasks();
            },
          ),
          ListTile(
            leading: const Icon(Icons.monitor_heart),
            title: const Text('Daily Monitoring'),
            onTap: () {
              Navigator.pop(context);
              _showDailyMonitoring();
            },
          ),
          ListTile(
            leading: const Icon(Icons.medication),
            title: const Text('Treatment Execution'),
            onTap: () {
              Navigator.pop(context);
              _showTreatmentExecution();
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Completed Updates'),
            onTap: () {
              Navigator.pop(context);
              _showCompletedUpdates();
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

  Widget _buildTaskCard(AssignedTask task) {
    Color statusColor;
    switch (task.status.toLowerCase()) {
      case 'pending':
        statusColor = AppTheme.warningOrange;
        break;
      case 'in progress':
        statusColor = AppTheme.primary;
        break;
      case 'completed':
        statusColor = AppTheme.successGreen;
        break;
      default:
        statusColor = AppTheme.mediumGrey;
    }

    final isOverdue =
        DateTime.now().isAfter(task.deadline) && task.status != 'Completed';

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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: AppConstants.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: AppConstants.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  task.taskId,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            Text(
              '${task.buffaloId} - ${task.taskType}',
              style: AppTheme.headingSmall.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppConstants.spacingS),

            if (task.instructions != null) ...[
              Text(
                task.instructions!,
                style: AppTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.spacingS),
            ],

            Row(
              children: [
                Icon(
                  Icons.person,
                  size: AppConstants.iconS,
                  color: AppTheme.mediumGrey,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  task.assignedBy,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Icon(
                  Icons.schedule,
                  size: AppConstants.iconS,
                  color: isOverdue ? AppTheme.errorRed : AppTheme.mediumGrey,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  'Due: ${DateFormat('MMM dd, hh:mm a').format(task.deadline)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: isOverdue ? AppTheme.errorRed : AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),

            if (task.status != 'Completed') ...[
              const SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _viewTaskDetails(task),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateTaskStatus(task),
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringCard(MonitoringRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  record.buffaloId,
                  style: AppTheme.headingSmall.copyWith(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(record.recordedAt),
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
                  child: _buildMonitoringItem(
                    'Temperature',
                    '${record.temperature}°F',
                    Icons.thermostat,
                    record.temperature > 102
                        ? AppTheme.errorRed
                        : AppTheme.successGreen,
                  ),
                ),
                Expanded(
                  child: _buildMonitoringItem(
                    'Eating',
                    record.eatingStatus,
                    Icons.restaurant,
                    AppTheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildMonitoringItem(
                    'Medicine',
                    record.medicineGiven ? 'Given' : 'Not Given',
                    Icons.medication,
                    record.medicineGiven
                        ? AppTheme.successGreen
                        : AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppConstants.iconM),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  void _showAssignedTasks() {
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
              const Text('Assigned Tasks', style: AppTheme.headingMedium),
              const SizedBox(height: AppConstants.spacingL),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _assignedTasks.length,
                  itemBuilder: (context, index) {
                    final task = _assignedTasks[index];
                    return _buildTaskCard(task);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDailyMonitoring() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Monitoring'),
        content: const Text(
          'Daily monitoring functionality will be implemented here.',
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

  void _showTreatmentExecution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Treatment Execution'),
        content: const Text(
          'Treatment execution functionality will be implemented here.',
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

  void _showCompletedUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recovery Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mark buffalo as fully recovered?'),
            const SizedBox(height: AppConstants.spacingM),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ToastUtils.showSuccess(
                  context,
                  'Recovery update sent to customer!',
                );
              },
              child: const Text('Recovery Done'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewTaskDetails(AssignedTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Details - ${task.taskId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buffalo: ${task.buffaloId}'),
            Text('Type: ${task.taskType}'),
            Text('Assigned by: ${task.assignedBy}'),
            Text(
              'Deadline: ${DateFormat('MMM dd, yyyy hh:mm a').format(task.deadline)}',
            ),
            const SizedBox(height: AppConstants.spacingM),
            if (task.instructions != null) ...[
              const Text('Instructions:', style: AppTheme.bodyMedium),
              const SizedBox(height: AppConstants.spacingS),
              Text(task.instructions!),
            ],
          ],
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

  void _updateTaskStatus(AssignedTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Task Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Task: ${task.taskId}'),
            const SizedBox(height: AppConstants.spacingM),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['In Progress', 'Completed', 'Need Help']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
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
                'Task status updated successfully!',
              );
            },
            child: const Text('Update'),
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
