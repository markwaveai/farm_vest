import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

enum IssueType { death, fever, infection, quarantine, recovery }

class HealthIssue {
  final String buffaloId;
  final IssueType type;
  final String description;
  final DateTime reportedAt;
  final String status;
  final bool requiresTransfer;

  HealthIssue({
    required this.buffaloId,
    required this.type,
    required this.description,
    required this.reportedAt,
    required this.status,
    this.requiresTransfer = false,
  });
}

class HealthIssuesScreen extends StatefulWidget {
  const HealthIssuesScreen({super.key});

  @override
  State<HealthIssuesScreen> createState() => _HealthIssuesScreenState();
}

class _HealthIssuesScreenState extends State<HealthIssuesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedBuffalo = 'BUF-001';
  IssueType _selectedIssueType = IssueType.fever;
  bool _requiresTransfer = false;
  List<HealthIssue> _healthIssues = [];

  final List<String> _buffaloIds = [
    'BUF-001',
    'BUF-002',
    'BUF-003',
    'BUF-004',
    'BUF-005',
    'BUF-006',
    'BUF-007',
    'BUF-008',
    'BUF-009',
    'BUF-010',
  ];

  @override
  void initState() {
    super.initState();
    _generateHealthIssues();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateHealthIssues() {
    _healthIssues = [
      HealthIssue(
        buffaloId: 'BUF-003',
        type: IssueType.fever,
        description: 'High temperature detected during morning check',
        reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Under Treatment',
      ),
      HealthIssue(
        buffaloId: 'BUF-007',
        type: IssueType.infection,
        description: 'Minor wound infection on left leg',
        reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Pending Doctor Review',
      ),
      HealthIssue(
        buffaloId: 'BUF-012',
        type: IssueType.quarantine,
        description: 'Precautionary quarantine after contact with sick animal',
        reportedAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'In Quarantine',
        requiresTransfer: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Issues'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/supervisor-dashboard',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report New Issue Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report Health Issue',
                        style: AppTheme.headingMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Buffalo Selection
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedBuffalo,
                        decoration: const InputDecoration(
                          labelText: 'Select Buffalo',
                          prefixIcon: Icon(Icons.pets),
                        ),
                        items: _buffaloIds.map((buffaloId) {
                          return DropdownMenuItem(
                            // ignore: deprecated_member_use
                            value: buffaloId,
                            child: Text(buffaloId),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBuffalo = value!;
                          });
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Issue Type Selection
                      DropdownButtonFormField<IssueType>(
                        // ignore: deprecated_member_use
                        value: _selectedIssueType,
                        decoration: const InputDecoration(
                          labelText: 'Issue Type',
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        items: IssueType.values.map((type) {
                          return DropdownMenuItem(
                            // ignore: deprecated_member_use
                            value: type,
                            child: Text(_getIssueTypeName(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedIssueType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe the health issue in detail...',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Transfer Required Checkbox
                      CheckboxListTile(
                        title: const Text('Requires Transfer'),
                        subtitle: const Text(
                          'Check if animal needs to be moved to isolation',
                        ),
                        // ignore: deprecated_member_use
                        value: _requiresTransfer,
                        onChanged: (value) {
                          setState(() {
                            _requiresTransfer = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitHealthIssue,
                          child: const Text('Submit Report'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Recent Issues
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Health Issues',
                  style: AppTheme.headingMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to full timeline
                  },
                  icon: const Icon(Icons.timeline),
                  label: const Text('View Timeline'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Health Issues List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _healthIssues.length,
              itemBuilder: (context, index) {
                final issue = _healthIssues[index];
                return _buildHealthIssueCard(issue);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIssueCard(HealthIssue issue) {
    final issueInfo = _getIssueInfo(issue.type);

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: issueInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    issueInfo.icon,
                    color: issueInfo.color,
                    size: AppConstants.iconM,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            issue.buffaloId,
                            style: AppTheme.headingSmall.copyWith(fontSize: 16),
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingS,
                              vertical: AppConstants.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: issueInfo.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusS,
                              ),
                            ),
                            child: Text(
                              _getIssueTypeName(issue.type),
                              style: TextStyle(
                                color: issueInfo.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(issue.reportedAt),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(issue.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    issue.status,
                    style: TextStyle(
                      color: _getStatusColor(issue.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Description
            Text(issue.description, style: AppTheme.bodyMedium),

            // Transfer Required
            if (issue.requiresTransfer) ...[
              const SizedBox(height: AppConstants.spacingM),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: AppTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: AppTheme.warningOrange,
                      size: AppConstants.iconS,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    const Text(
                      'Transfer Required - Pending Admin Approval',
                      style: TextStyle(
                        color: AppTheme.warningOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showTransferApprovalDialog(issue),
                      child: const Text('View Status'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getIssueTypeName(IssueType type) {
    switch (type) {
      case IssueType.death:
        return 'Death';
      case IssueType.fever:
        return 'Fever';
      case IssueType.infection:
        return 'Infection';
      case IssueType.quarantine:
        return 'Quarantine';
      case IssueType.recovery:
        return 'Recovery';
    }
  }

  IssueInfo _getIssueInfo(IssueType type) {
    switch (type) {
      case IssueType.death:
        return IssueInfo(icon: Icons.dangerous, color: Colors.black);
      case IssueType.fever:
        return IssueInfo(icon: Icons.thermostat, color: AppTheme.errorRed);
      case IssueType.infection:
        return IssueInfo(icon: Icons.healing, color: AppTheme.warningOrange);
      case IssueType.quarantine:
        return IssueInfo(icon: Icons.warning, color: Colors.orange);
      case IssueType.recovery:
        return IssueInfo(
          icon: Icons.check_circle,
          color: AppTheme.successGreen,
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'under treatment':
        return AppTheme.primary;
      case 'pending doctor review':
        return AppTheme.warningOrange;
      case 'in quarantine':
        return Colors.orange;
      case 'resolved':
        return AppTheme.successGreen;
      default:
        return AppTheme.mediumGrey;
    }
  }

  void _submitHealthIssue() {
    if (_formKey.currentState!.validate()) {
      final newIssue = HealthIssue(
        buffaloId: _selectedBuffalo,
        type: _selectedIssueType,
        description: _descriptionController.text,
        reportedAt: DateTime.now(),
        status: 'Pending Doctor Review',
        requiresTransfer: _requiresTransfer,
      );

      setState(() {
        _healthIssues.insert(0, newIssue);
        _descriptionController.clear();
        _requiresTransfer = false;
      });

      if (_requiresTransfer) {
        _showTransferApprovalDialog(newIssue);
      } else {
        ToastUtils.showSuccess(context, 'Health issue reported successfully!');
      }
    }
  }

  void _showTransferApprovalDialog(HealthIssue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Approval Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buffalo: ${issue.buffaloId}'),
            Text('Issue: ${_getIssueTypeName(issue.type)}'),
            const SizedBox(height: AppConstants.spacingM),
            const Text(
              'This case requires animal transfer to isolation. Admin approval is needed.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Approval Status: Pending',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingS),
                  Text(
                    'You will be notified once the admin reviews and approves the transfer request.',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastUtils.showWarning(
                context,
                'Health issue reported. Transfer approval pending.',
              );
            },
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}

class IssueInfo {
  final IconData icon;
  final Color color;

  IssueInfo({required this.icon, required this.color});
}
