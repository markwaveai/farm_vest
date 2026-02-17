import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/widgets/employee_bottom_navigation.dart';
import 'package:farm_vest/core/widgets/notification_bell_button.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import '../widgets/employee_dashboard_card.dart';

import 'health_issues_screen.dart';
import 'milk_production_screen.dart';
import 'raise_ticket_screen.dart';
import 'package:farm_vest/features/doctors/widgets/buffalo_profile_view.dart';

import 'package:farm_vest/core/localization/translation_helpers.dart';
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

class AssistantDashboardScreen extends ConsumerStatefulWidget {
  AssistantDashboardScreen({super.key});

  @override
  ConsumerState<AssistantDashboardScreen> createState() =>
      _AssistantDashboardScreenState();
}

class _AssistantDashboardScreenState
    extends ConsumerState<AssistantDashboardScreen> {
  int _currentIndex = 4;
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
        assignedAt: DateTime.now().subtract(Duration(hours: 2)),
        deadline: DateTime.now().add(Duration(hours: 4)),
        status: 'In Progress',
        instructions:
            'Monitor temperature every 2 hours and report if above 102°F',
      ),
      AssignedTask(
        taskId: 'TASK-002',
        buffaloId: 'BUF-007',
        taskType: 'Medicine Administration',
        assignedBy: 'Dr. Sharma',
        assignedAt: DateTime.now().subtract(Duration(hours: 6)),
        deadline: DateTime.now().add(Duration(hours: 2)),
        status: 'Pending',
        instructions: 'Administer antibiotic injection twice daily',
      ),
      AssignedTask(
        taskId: 'TASK-003',
        buffaloId: 'BUF-012',
        taskType: 'Recovery Monitoring',
        assignedBy: 'Dr. Patel',
        assignedAt: DateTime.now().subtract(Duration(days: 1)),
        deadline: DateTime.now().add(Duration(hours: 8)),
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
        recordedAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
      MonitoringRecord(
        buffaloId: 'BUF-007',
        temperature: 100.8,
        eatingStatus: 'Fair',
        medicineGiven: true,
        recordedAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
      MonitoringRecord(
        buffaloId: 'BUF-012',
        temperature: 100.2,
        eatingStatus: 'Excellent',
        medicineGiven: false,
        recordedAt: DateTime.now().subtract(Duration(hours: 5)),
      ),
    ];
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Health Issues'.tr(ref);
      case 1:
        return 'Milk Production'.tr(ref);
      case 2:
        return 'Raise Ticket'.tr(ref);
      case 3:
        return 'Buffalo Profile'.tr(ref);
      case 4:
        return 'Assistant Dashboard'.tr(ref);
      default:
        return 'Assistant Dashboard'.tr(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 4) {
          setState(() {
            _currentIndex = 4;
          });
        } else {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_currentIndex)),
          automaticallyImplyLeading: false,
          actions: [
            if (ref.watch(authProvider).availableRoles.length > 1)
              IconButton(
                icon: Icon(Icons.swap_horiz),
                onPressed: _showSwitchRoleBottomSheet,
                tooltip: 'Switch Role'.tr(ref),
              ),
            NotificationBellButton(fallbackRoute: '/assistant-dashboard'),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child:
                    ref.watch(authProvider).userData?.imageUrl != null &&
                        ref.watch(authProvider).userData!.imageUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          ref.watch(authProvider).userData!.imageUrl!,
                          fit: BoxFit.cover,
                          width: 36,
                          height: 36,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                                Icons.person,
                                size: 20,
                                color: AppTheme.primary,
                              ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 20,
                        color: AppTheme.primary,
                      ),
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HealthIssuesScreen(hideAppBar: true),
            MilkProductionScreen(hideAppBar: true),
            RaiseTicketScreen(hideAppBar: true),
            BuffaloProfileView(),
            _buildDashboardHome(),
          ],
        ),
        bottomNavigationBar: EmployeeBottomNavigation(
          role: UserType.assistant,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
          onTap: () {
            setState(() => _currentIndex = 4);
          },
          child: Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardColor
                  : AppTheme.darkPrimary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkPrimary
                    : AppTheme.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Image.asset(
                'assets/icons/home.png',
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primary
                    : AppTheme.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  AppTheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, @name!'.trParams({
                    'name':
                        ref.watch(authProvider).userData?.name ??
                        'Assistant Kumar',
                  }),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                SizedBox(height: AppConstants.spacingS),
                Text(
                  'Supporting healthcare operations'.tr(ref),
                  style: TextStyle(fontSize: 16, color: AppTheme.white),
                ),
                SizedBox(height: AppConstants.spacingM),
                Row(
                  children: [
                    _buildQuickStat('Active Tasks'.tr(ref), '8'),
                    SizedBox(width: AppConstants.spacingL),
                    _buildQuickStat('Completed'.tr(ref), '15'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.spacingL),

          // Quick Actions
          Text(
            'Quick Actions'.tr(ref),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppConstants.spacingM),

          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.spacingM,
            mainAxisSpacing: AppConstants.spacingM,
            childAspectRatio: 1.1,
            children: [
              EmployeeDashboardCard(
                title: 'Assigned Tasks'.tr(ref),
                subtitle: 'View your tasks'.tr(ref),
                icon: Icons.assignment,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => _showAssignedTasks(),
              ),
              EmployeeDashboardCard(
                title: 'Daily Monitoring'.tr(ref),
                subtitle: 'Record observations'.tr(ref),
                icon: Icons.monitor_heart,
                color: AppTheme.secondary,
                onTap: () => _showDailyMonitoring(),
              ),
              EmployeeDashboardCard(
                title: 'Treatment Execution'.tr(ref),
                subtitle: 'Follow instructions'.tr(ref),
                icon: Icons.medication,
                color: AppTheme.darkSecondary,
                onTap: () => _showTreatmentExecution(),
              ),
              EmployeeDashboardCard(
                title: 'Completed Updates'.tr(ref),
                subtitle: 'Update progress'.tr(ref),
                icon: Icons.check_circle,
                color: AppTheme.successGreen,
                onTap: () => _showCompletedUpdates(),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacingL),

          // Assigned Tasks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Assigned Tasks'.tr(ref),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => _showAssignedTasks(),
                child: Text('View All'.tr(ref)),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacingM),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _assignedTasks.take(3).length,
            itemBuilder: (context, index) {
              final task = _assignedTasks[index];
              return _buildTaskCard(task);
            },
          ),
          SizedBox(height: AppConstants.spacingL),

          // Recent Monitoring Records
          Text(
            'Recent Monitoring Records'.tr(ref),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppConstants.spacingM),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _monitoringRecords.take(3).length,
            itemBuilder: (context, index) {
              final record = _monitoringRecords[index];
              return _buildMonitoringCard(record);
            },
          ),
        ],
      ),
    );
  }

  void _showSwitchRoleBottomSheet() {
    final authState = ref.read(authProvider);
    final availableRoles = authState.availableRoles;
    final currentRole = authState.role;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Active Role'.tr(ref),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Choose which portal you want to access'.tr(ref),
                style: TextStyle(color: AppTheme.mediumGrey),
              ),
              SizedBox(height: 24),
              ...availableRoles.map((role) {
                final isSelected = role == currentRole;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: isSelected
                        ? null
                        : () async {
                            Navigator.pop(context);
                            await ref
                                .read(authProvider.notifier)
                                .selectRole(role);

                            if (!mounted) return;
                            switch (role) {
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
                            ? role.color
                            : Colors
                                  .grey[200]!, // Fixed: Use valid color access
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected ? role.color.withOpacity(0.05) : null,
                    leading: CircleAvatar(
                      backgroundColor: role.color.withOpacity(0.1),
                      child: Icon(role.icon, color: role.color),
                    ),
                    title: Text(
                      role.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: role.color)
                        : Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppTheme.white),
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
        statusColor = Theme.of(context).colorScheme.primary;
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
      margin: EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
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
                  SizedBox(width: AppConstants.spacingS),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingS,
                      vertical: AppConstants.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(
                        0.1,
                      ), // Fixed: Use withOpacity
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Text(
                      'OVERDUE'.tr(ref),
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                Spacer(),
                Text(
                  task.taskId,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGrey),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingM),

            Text(
              '${task.buffaloId} - ${task.taskType}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
            SizedBox(height: AppConstants.spacingS),

            if (task.instructions != null) ...[
              Text(
                task.instructions!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppConstants.spacingS),
            ],

            Row(
              children: [
                Icon(
                  Icons.person,
                  size: AppConstants.iconS,
                  color: AppTheme.mediumGrey,
                ),
                SizedBox(width: AppConstants.spacingXS),
                Text(
                  task.assignedBy,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGrey),
                ),
                SizedBox(width: AppConstants.spacingM),
                Icon(
                  Icons.schedule,
                  size: AppConstants.iconS,
                  color: isOverdue ? AppTheme.errorRed : AppTheme.mediumGrey,
                ),
                SizedBox(width: AppConstants.spacingXS),
                Text(
                  '${'Due'.tr(ref)}: ${DateFormat('MMM dd, hh:mm a').format(task.deadline)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOverdue ? AppTheme.errorRed : AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),

            if (task.status != 'Completed') ...[
              SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _viewTaskDetails(task),
                      child: Text('View Details'.tr(ref)),
                    ),
                  ),
                  SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateTaskStatus(task),
                      child: Text('Update'.tr(ref)),
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
      margin: EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  record.buffaloId,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                Spacer(),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(record.recordedAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGrey),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Expanded(
                  child: _buildMonitoringItem(
                    'Temperature'.tr(ref),
                    '${record.temperature}°F',
                    Icons.thermostat,
                    record.temperature > 102
                        ? AppTheme.errorRed
                        : AppTheme.successGreen,
                  ),
                ),
                Expanded(
                  child: _buildMonitoringItem(
                    'Eating'.tr(ref),
                    record.eatingStatus,
                    Icons.restaurant,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildMonitoringItem(
                    'Medicine'.tr(ref),
                    record.medicineGiven ? 'Given'.tr(ref) : 'Not Given'.tr(ref),
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
        SizedBox(height: AppConstants.spacingS),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showAssignedTasks() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            Text(
              'Assigned Tasks'.tr(ref),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppConstants.spacingL),
            Expanded(
              child: ListView.builder(
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
    );
  }

  void _showDailyMonitoring() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Daily Monitoring'.tr(ref)),
        content: Text(
          'Daily monitoring functionality will be implemented here.'.tr(ref),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'.tr(ref)),
          ),
        ],
      ),
    );
  }

  void _showTreatmentExecution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Treatment Execution'.tr(ref)),
        content: Text(
          'Treatment execution functionality will be implemented here.'.tr(ref),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'.tr(ref)),
          ),
        ],
      ),
    );
  }

  void _showCompletedUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recovery Update'.tr(ref)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark buffalo as fully recovered?'.tr(ref)),
            SizedBox(height: AppConstants.spacingM),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ToastUtils.showSuccess(
                  context,
                  'Recovery update sent to customer!',
                );
              },
              child: Text('Recovery Done'.tr(ref)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(ref)),
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
            SizedBox(height: AppConstants.spacingM),
            if (task.instructions != null) ...[
              Text(
                'Instructions:'.tr(ref),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: AppConstants.spacingS),
              Text(task.instructions!),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'.tr(ref)),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(AssignedTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Task Status'.tr(ref)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Task: ${task.taskId}'),
            SizedBox(height: AppConstants.spacingM),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Status'),
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
            child: Text('Cancel'.tr(ref)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtils.showSuccess(
                context,
                'Task status updated successfully!',
              );
            },
            child: Text('Update'.tr(ref)),
          ),
        ],
      ),
    );
  }
}
