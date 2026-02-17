import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
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

class HealthIssuesScreen extends ConsumerStatefulWidget {
  final bool hideAppBar;

  HealthIssuesScreen({super.key, this.hideAppBar = false});

  @override
  State<HealthIssuesScreen> createState() => _HealthIssuesScreenState();
}

class _HealthIssuesScreenState extends ConsumerState<HealthIssuesScreen> {
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
        reportedAt: DateTime.now().subtract(Duration(hours: 2)),
        status: 'Under Treatment',
      ),
      HealthIssue(
        buffaloId: 'BUF-007',
        type: IssueType.infection,
        description: 'Minor wound infection on left leg',
        reportedAt: DateTime.now().subtract(Duration(days: 1)),
        status: 'Pending Doctor Review',
      ),
      HealthIssue(
        buffaloId: 'BUF-012',
        type: IssueType.quarantine,
        description: 'Precautionary quarantine after contact with sick animal',
        reportedAt: DateTime.now().subtract(Duration(days: 2)),
        status: 'In Quarantine',
        requiresTransfer: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              title: Text('Health Issues'.tr(ref)),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => NavigationHelper.safePopOrNavigate(
                  context,
                  fallbackRoute: '/supervisor-dashboard',
                ),
              ),
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report New Issue Form
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Health Issue'.tr(ref),
                        style: AppTheme.headingMedium,
                      ),
                      SizedBox(height: AppConstants.spacingL),

                      // Buffalo Selection
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedBuffalo,
                        decoration: InputDecoration(
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
                      SizedBox(height: AppConstants.spacingM),

                      // Issue Type Selection
                      DropdownButtonFormField<IssueType>(
                        // ignore: deprecated_member_use
                        value: _selectedIssueType,
                        decoration: InputDecoration(
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
                      SizedBox(height: AppConstants.spacingM),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
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
                      SizedBox(height: AppConstants.spacingM),

                      // Transfer Required Checkbox
                      CheckboxListTile(
                        title: Text('Requires Transfer'.tr(ref)),
                        subtitle: Text(
                          'Check if animal needs to be moved to isolation'.tr(ref),
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
                      SizedBox(height: AppConstants.spacingL),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitHealthIssue,
                          child: Text('Submit Report'.tr(ref)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConstants.spacingL),

            // Recent Issues
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Health Issues'.tr(ref),
                  style: AppTheme.headingMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to full timeline
                  },
                  icon: Icon(Icons.timeline),
                  label: Text('View Timeline'.tr(ref)),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingM),

            // Health Issues List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
      margin: EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacingM),
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
                SizedBox(width: AppConstants.spacingM),
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
                          SizedBox(width: AppConstants.spacingS),
                          Container(
                            padding: EdgeInsets.symmetric(
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
                      SizedBox(height: AppConstants.spacingXS),
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
                  padding: EdgeInsets.symmetric(
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
            SizedBox(height: AppConstants.spacingM),

            // Description
            Text(issue.description, style: AppTheme.bodyMedium),

            // Transfer Required
            if (issue.requiresTransfer) ...[
              SizedBox(height: AppConstants.spacingM),
              Container(
                padding: EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: AppTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.warningOrange,
                      size: AppConstants.iconS,
                    ),
                    SizedBox(width: AppConstants.spacingS),
                    Text(
                      'Transfer Required - Pending Farm Manager Approval'.tr(ref),
                      style: TextStyle(
                        color: AppTheme.warningOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () => _showTransferApprovalDialog(issue),
                      child: Text('View Status'.tr(ref)),
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
        title: Text('Transfer Approval Required'.tr(ref)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buffalo: ${issue.buffaloId}'),
            Text('Issue: ${_getIssueTypeName(issue.type)}'),
            SizedBox(height: AppConstants.spacingM),
            Text(
              'This case requires animal transfer to isolation. Farm Manager approval is needed.'.tr(ref),
              style: AppTheme.bodyMedium,
            ),
            SizedBox(height: AppConstants.spacingM),
            Container(
              padding: EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Approval Status: Pending'.tr(ref),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingS),
                  Text(
                    'You will be notified once the Farm Manager reviews and approves the transfer request.'.tr(ref),
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
            child: Text('Understood'.tr(ref)),
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
