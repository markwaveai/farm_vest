import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
enum TicketPriority { low, medium, high, critical }

enum TicketStatus { open, inProgress, resolved, closed }

class Ticket {
  final String id;
  final String buffaloId;
  final String issueType;
  final TicketPriority priority;
  final String description;
  final DateTime createdAt;
  final TicketStatus status;
  final String? assignedTo;

  Ticket({
    required this.id,
    required this.buffaloId,
    required this.issueType,
    required this.priority,
    required this.description,
    required this.createdAt,
    required this.status,
    this.assignedTo,
  });
}

class RaiseTicketScreen extends ConsumerStatefulWidget {
  final bool hideAppBar;

  RaiseTicketScreen({super.key, this.hideAppBar = false});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends ConsumerState<RaiseTicketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedBuffalo = 'BUF-001';
  String _selectedIssueType = 'Health Issue';
  TicketPriority _selectedPriority = TicketPriority.medium;

  List<Ticket> _tickets = [];

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

  final List<String> _issueTypes = [
    'Health Issue',
    'Feed Problem',
    'Equipment Failure',
    'Infrastructure',
    'Safety Concern',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateTickets() {
    _tickets = [
      Ticket(
        id: 'TKT-001',
        buffaloId: 'BUF-003',
        issueType: 'Health Issue',
        priority: TicketPriority.high,
        description:
            'Buffalo showing signs of illness, needs immediate attention',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        status: TicketStatus.inProgress,
        assignedTo: 'Dr. Sharma',
      ),
      Ticket(
        id: 'TKT-002',
        buffaloId: 'BUF-007',
        issueType: 'Feed Problem',
        priority: TicketPriority.medium,
        description: 'Feed quality seems poor, animals not eating properly',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        status: TicketStatus.open,
      ),
      Ticket(
        id: 'TKT-003',
        buffaloId: 'BUF-012',
        issueType: 'Equipment Failure',
        priority: TicketPriority.low,
        description: 'Water pump in section B needs maintenance',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        status: TicketStatus.resolved,
        assignedTo: 'Maintenance Team',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar
          ? AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              bottom: TabBar(
                labelStyle: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
                controller: _tabController,
                tabs: [
                  Tab(text: 'Raise Ticket'),
                  Tab(text: 'My Tickets'),
                ],
              ),
            )
          : AppBar(
              title: Text('Support Tickets'.tr(ref)),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => NavigationHelper.safePopOrNavigate(
                  context,
                  fallbackRoute: '/supervisor-dashboard',
                ),
              ),
              bottom: TabBar(
                labelStyle: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
                controller: _tabController,
                tabs: [
                  Tab(text: 'Raise Ticket'),
                  Tab(text: 'My Tickets'),
                ],
              ),
            ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildRaiseTicketTab(), _buildMyTicketsTab()],
      ),
    );
  }

  Widget _buildRaiseTicketTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.spacingM),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create New Ticket'.tr(ref), style: AppTheme.headingMedium),
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
            DropdownButtonFormField<String>(
              // ignore: deprecated_member_use
              value: _selectedIssueType,
              decoration: InputDecoration(
                labelText: 'Issue Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: _issueTypes.map((issueType) {
                return DropdownMenuItem(
                  // ignore: deprecated_member_use
                  value: issueType,
                  child: Text(issueType),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIssueType = value!;
                });
              },
            ),
            SizedBox(height: AppConstants.spacingM),

            // Priority Selection
            DropdownButtonFormField<TicketPriority>(
              // ignore: deprecated_member_use
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: TicketPriority.values.map((priority) {
                return DropdownMenuItem(
                  // ignore: deprecated_member_use
                  value: priority,
                  child: Text(_getPriorityName(priority)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
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
                hintText: 'Describe the issue in detail...',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a description';
                }
                return null;
              },
            ),
            SizedBox(height: AppConstants.spacingM),

            // Upload Image Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.mediumGrey),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: AppConstants.iconXL,
                    color: AppTheme.mediumGrey,
                  ),
                  SizedBox(height: AppConstants.spacingS),
                  Text(
                    'Upload Image (Optional)'.tr(ref),
                    style: AppTheme.bodyMedium,
                  ),
                  SizedBox(height: AppConstants.spacingS),
                  OutlinedButton(
                    onPressed: () {
                      // Handle image upload
                      ToastUtils.showInfo(
                        context,
                        'Image upload functionality',
                      );
                    },
                    child: Text('Choose Image'.tr(ref)),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppConstants.spacingL),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitTicket,
                child: Text('Submit Ticket'.tr(ref)),
              ),
            ),
            SizedBox(height: AppConstants.spacingM),

            // Note
            Container(
              padding: EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: AppTheme.primary,
                    size: AppConstants.iconS,
                  ),
                  SizedBox(width: AppConstants.spacingS),
                  Expanded(
                    child: Text(
                      'Customer will be automatically notified about this ticket.'.tr(ref),
                      style: TextStyle(color: AppTheme.primary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTicketsTab() {
    return Column(
      children: [
        // Filter Chips
        Container(
          padding: EdgeInsets.all(AppConstants.spacingM),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Open', false),
                _buildFilterChip('In Progress', false),
                _buildFilterChip('Resolved', false),
              ],
            ),
          ),
        ),

        // Tickets List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
            ),
            itemCount: _tickets.length,
            itemBuilder: (context, index) {
              final ticket = _tickets[index];
              return _buildTicketCard(ticket);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: AppConstants.spacingS),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Handle filter selection
        },
        selectedColor: AppTheme.secondary.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final priorityInfo = _getPriorityInfo(ticket.priority);
    final statusInfo = _getStatusInfo(ticket.status);

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
                    color: priorityInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    ticket.id,
                    style: TextStyle(
                      color: priorityInfo.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spacingS),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: priorityInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        priorityInfo.icon,
                        size: 12,
                        color: priorityInfo.color,
                      ),
                      SizedBox(width: AppConstants.spacingXS),
                      Text(
                        _getPriorityName(ticket.priority),
                        style: TextStyle(
                          color: priorityInfo.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    _getStatusName(ticket.status),
                    style: TextStyle(
                      color: statusInfo.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Text(
                  '${ticket.buffaloId} • ${ticket.issueType}',
                  style: AppTheme.headingSmall.copyWith(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingS),

            Text(
              ticket.description,
              style: AppTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: AppConstants.iconS,
                  color: AppTheme.mediumGrey,
                ),
                SizedBox(width: AppConstants.spacingXS),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(ticket.createdAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
                if (ticket.assignedTo != null) ...[
                  SizedBox(width: AppConstants.spacingM),
                  Icon(
                    Icons.person,
                    size: AppConstants.iconS,
                    color: AppTheme.mediumGrey,
                  ),
                  SizedBox(width: AppConstants.spacingXS),
                  Text(
                    ticket.assignedTo!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityName(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.critical:
        return 'Critical';
    }
  }

  String _getStatusName(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  PriorityInfo _getPriorityInfo(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return PriorityInfo(
          icon: Icons.low_priority,
          color: AppTheme.successGreen,
        );
      case TicketPriority.medium:
        return PriorityInfo(icon: Icons.remove, color: AppTheme.warningOrange);
      case TicketPriority.high:
        return PriorityInfo(
          icon: Icons.priority_high,
          color: AppTheme.errorRed,
        );
      case TicketPriority.critical:
        return PriorityInfo(icon: Icons.warning, color: Colors.red[900]!);
    }
  }

  StatusInfo _getStatusInfo(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return StatusInfo(color: AppTheme.primary);
      case TicketStatus.inProgress:
        return StatusInfo(color: AppTheme.warningOrange);
      case TicketStatus.resolved:
        return StatusInfo(color: AppTheme.successGreen);
      case TicketStatus.closed:
        return StatusInfo(color: AppTheme.mediumGrey);
    }
  }

  void _submitTicket() {
    if (_formKey.currentState!.validate()) {
      final newTicket = Ticket(
        id: 'TKT-${_tickets.length + 1}'.padLeft(7, '0'),
        buffaloId: _selectedBuffalo,
        issueType: _selectedIssueType,
        priority: _selectedPriority,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        status: TicketStatus.open,
      );

      setState(() {
        _tickets.insert(0, newTicket);
        _descriptionController.clear();
        _tabController.animateTo(1); // Switch to My Tickets tab
      });

      ToastUtils.showSuccess(
        context,
        'Ticket submitted successfully! Customer has been notified.',
      );
    }
  }
}

class PriorityInfo {
  final IconData icon;
  final Color color;

  PriorityInfo({required this.icon, required this.color});
}

class StatusInfo {
  final Color color;

  StatusInfo({required this.color});
}
