import 'dart:convert';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/notification_service.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';

class NotificationsScreen extends StatefulWidget {
  final String fallbackRoute;
  final String? initialFilter; // "ticket", "iot_alert", or alert subtype like "BH"
  const NotificationsScreen({
    super.key,
    required this.fallbackRoute,
    this.initialFilter,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  late TabController _tabController;
  String? _expandedNotificationId;
  bool _isLoading = true;

  // IoT alert subtype filter chips
  static const _iotAlertTypes = ['All', 'Heat', 'Health', 'BH', 'Missing Tag', 'System'];
  String _selectedIoTFilter = 'All';

  // AI Entry state (for Heat alerts)
  // Tracks which notification ID has the AI form open
  String? _aiFormNotificationId;
  String _selectedSemenType = 'NORMAL';
  bool _isSubmittingAI = false;

  @override
  void initState() {
    super.initState();

    // Determine initial main tab: 0 = Tickets, 1 = IoT Alerts
    int initialTab = 0;
    if (widget.initialFilter != null) {
      final normalized = _normalize(widget.initialFilter!);
      if (normalized == 'ticket') {
        initialTab = 0;
      } else if (normalized == 'iotalert') {
        initialTab = 1;
      } else {
        // Check if it's an IoT alert subtype
        final idx = _iotAlertTypes.indexWhere(
          (t) => _normalize(t) == normalized,
        );
        if (idx >= 0) {
          initialTab = 1;
          _selectedIoTFilter = _iotAlertTypes[idx];
        }
      }
    }

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _expandedNotificationId = null;
        });
      }
    });

    _loadNotifications();
    _notificationService.addListener(_onNotificationsChanged);
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    await _notificationService.fetchNotificationHistory();
    _updateNotifications();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _updateNotifications() {
    if (mounted) {
      setState(() {
        _notifications = _notificationService.notifications;
      });
    }
  }

  void _onNotificationsChanged(List<AppNotification> allNotifications) {
    if (mounted) {
      _updateNotifications();
    }
  }

  static String _normalize(String s) => s.toLowerCase().replaceAll(' ', '').replaceAll('_', '');

  List<AppNotification> get _ticketNotifications =>
      _notifications.where((n) => n.notificationCategory != 'iot_alert').toList();

  List<AppNotification> get _iotNotifications =>
      _notifications.where((n) => n.notificationCategory == 'iot_alert').toList();

  List<AppNotification> get _filteredIoTNotifications {
    final iot = _iotNotifications;
    if (_selectedIoTFilter == 'All') return iot;
    final norm = _normalize(_selectedIoTFilter);
    return iot.where((n) => n.alertType != null && _normalize(n.alertType!) == norm).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ticketCount = _ticketNotifications.length;
    final iotCount = _iotNotifications.length;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        NavigationHelper.safePopOrNavigate(
          context,
          fallbackRoute: widget.fallbackRoute,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'.tr),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => NavigationHelper.safePopOrNavigate(
              context,
              fallbackRoute: widget.fallbackRoute,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadNotifications,
              tooltip: 'Refresh'.tr,
            ),
            if (_notifications.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: () {
                  _notificationService.markAllAsRead();
                  ToastUtils.showInfo(
                    context,
                    'All notifications marked as read'.tr,
                  );
                },
                tooltip: 'Mark all as read'.tr,
              ),
            ],
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.mediumGrey,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment, size: 18),
                    const SizedBox(width: 6),
                    Text('Tickets'.tr),
                    if (ticketCount > 0) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(ticketCount, const Color(0xFF2563EB)),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sensors, size: 18),
                    const SizedBox(width: 6),
                    Text('IoT Alerts'.tr),
                    if (iotCount > 0) ...[
                      const SizedBox(width: 6),
                      _buildCountBadge(iotCount, const Color(0xFFEA580C)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Tickets
                  RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: _buildNotificationList(_ticketNotifications),
                  ),
                  // Tab 2: IoT Alerts (with sub-filter chips)
                  RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: _buildIoTAlertsTab(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCountBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  // ---------- IoT Alerts Tab with sub-filter chips ----------

  Widget _buildIoTAlertsTab() {
    final filtered = _filteredIoTNotifications;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      children: [
        // Alert type filter chips
        _buildIoTFilterChips(),
        const SizedBox(height: AppConstants.spacingM),

        // Summary
        _buildSummaryRow(filtered),
        const SizedBox(height: AppConstants.spacingM),

        if (filtered.isEmpty)
          _buildEmptyListMessage()
        else
          ...filtered.map(
            (n) => _buildExpandableNotificationCard(n, isUnread: !n.isRead),
          ),
      ],
    );
  }

  Widget _buildIoTFilterChips() {
    final iot = _iotNotifications;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _iotAlertTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _iotAlertTypes[index];
          final isSelected = _selectedIoTFilter == type;
          final count = type == 'All'
              ? iot.length
              : iot.where((n) => n.alertType != null && _normalize(n.alertType!) == _normalize(type)).length;

          return FilterChip(
            selected: isSelected,
            label: Text('$type ($count)'),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.darkGrey,
            ),
            selectedColor: const Color(0xFFEA580C),
            backgroundColor: Colors.grey.shade100,
            checkmarkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFFEA580C) : Colors.grey.shade300,
              ),
            ),
            onSelected: (_) {
              setState(() {
                _selectedIoTFilter = type;
                _expandedNotificationId = null;
              });
            },
          );
        },
      ),
    );
  }

  // ---------- Shared list builder ----------

  Widget _buildNotificationList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          _buildEmptyListMessage(),
        ],
      );
    }

    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      children: [
        _buildSummaryRow(notifications),
        const SizedBox(height: AppConstants.spacingL),

        if (unread.isNotEmpty) ...[
          Text('Unread'.tr, style: AppTheme.headingMedium),
          const SizedBox(height: AppConstants.spacingM),
          ...unread.map((n) => _buildExpandableNotificationCard(n, isUnread: true)),
          const SizedBox(height: AppConstants.spacingL),
        ],

        if (read.isNotEmpty) ...[
          Text('Read'.tr, style: AppTheme.headingMedium),
          const SizedBox(height: AppConstants.spacingM),
          ...read.map((n) => _buildExpandableNotificationCard(n, isUnread: false)),
        ],
      ],
    );
  }

  Widget _buildEmptyListMessage() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.notifications_none, size: 48, color: AppTheme.mediumGrey),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'No notifications in this category'.tr,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(List<AppNotification> notifications) {
    final total = notifications.length;
    final unread = notifications.where((n) => !n.isRead).length;
    final read = notifications.where((n) => n.isRead).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total'.tr,
                total.toString(),
                Icons.notifications,
                AppTheme.primary,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Unread'.tr,
                unread.toString(),
                Icons.mark_email_unread,
                AppTheme.warningOrange,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Read'.tr,
                read.toString(),
                Icons.mark_email_read,
                AppTheme.successGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Notification card ----------

  Widget _buildExpandableNotificationCard(
    AppNotification notification, {
    required bool isUnread,
  }) {
    final isExpanded = _expandedNotificationId == notification.id;
    final isIoTAlert = notification.notificationCategory == 'iot_alert';
    final color = _getCategoryColor(notification);
    final icon = _getCategoryIcon(notification);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      color: isUnread ? color.withValues(alpha: 0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        side: isExpanded
            ? BorderSide(color: color.withValues(alpha: 0.3), width: 1.5)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedNotificationId = null;
                } else {
                  _expandedNotificationId = notification.id;
                  if (isUnread) {
                    _notificationService.markAsRead(notification.id);
                  }
                }
              });
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
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
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Badges
                        Row(
                          children: [
                            if (notification.alertType != null && notification.alertType!.isNotEmpty) ...[
                              _buildAlertTypeBadge(notification.alertType!),
                              const SizedBox(width: 6),
                            ],
                            if (notification.deviceId != null && notification.deviceId!.isNotEmpty)
                              _buildDeviceBadge(notification.deviceId!),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Text(
                          notification.message,
                          style: AppTheme.bodyMedium.copyWith(
                            color: isUnread ? AppTheme.darkGrey : AppTheme.mediumGrey,
                          ),
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppConstants.spacingS),
                        Row(
                          children: [
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
                            ),
                            const Spacer(),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 20,
                              color: AppTheme.mediumGrey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedDetails(notification),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(AppNotification notification) {
    final isIoTAlert = notification.notificationCategory == 'iot_alert';
    final isHeatAlert = _normalize(notification.alertType ?? '') == 'heat';
    final showAIForm = _aiFormNotificationId == notification.id;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metadata
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Column(
              children: [
                if (notification.alertType != null && notification.alertType!.isNotEmpty)
                  _buildDetailRow('Alert Type'.tr, notification.alertType!),
                if (notification.deviceId != null && notification.deviceId!.isNotEmpty)
                  _buildDetailRow('Device ID'.tr, notification.deviceId!),
                if (notification.referenceId != null)
                  _buildDetailRow('Reference ID'.tr, '#${notification.referenceId}'),
                _buildDetailRow(
                  'Created'.tr,
                  DateFormat('MMM dd, yyyy HH:mm').format(notification.timestamp),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),

          // Heat alert: "Was AI done?" Yes/No buttons
          if (isHeatAlert && notification.deviceId != null && !showAIForm) ...[
            Text(
              'Was Artificial Insemination done?'.tr,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _aiFormNotificationId = notification.id;
                        _selectedSemenType = 'NORMAL';
                      });
                    },
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text('Yes'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _expandedNotificationId = null);
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: Text('No'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
          ],

          // AI Entry form (shown after tapping Yes)
          if (showAIForm) ...[
            _buildAIEntryForm(notification),
            const SizedBox(height: AppConstants.spacingM),
          ],

          // Action buttons row
          Row(
            children: [
              if (isIoTAlert && notification.deviceId != null && notification.deviceId!.isNotEmpty) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/buffalo-device-details', extra: {
                        'animalId': '',
                        'beltId': notification.deviceId!,
                        'rfid': null,
                        'tagNumber': null,
                        'age': null,
                        'breed': null,
                        'status': null,
                        'animal': null,
                      });
                    },
                    icon: const Icon(Icons.pets, size: 18),
                    label: Text('View Buffalo'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
              ],
              if (notification.notificationCategory == 'ticket') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/all-health-tickets');
                    },
                    icon: const Icon(Icons.assignment, size: 18),
                    label: Text('View Ticket'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
              ],
              if (!notification.isRead)
                IconButton(
                  onPressed: () => _notificationService.markAsRead(notification.id),
                  icon: const Icon(Icons.mark_email_read),
                  color: AppTheme.successGreen,
                  tooltip: 'Mark as read'.tr,
                ),
              IconButton(
                onPressed: () {
                  _notificationService.removeNotification(notification.id);
                  setState(() {
                    _expandedNotificationId = null;
                    _aiFormNotificationId = null;
                  });
                },
                icon: const Icon(Icons.delete_outline),
                color: AppTheme.errorRed,
                tooltip: 'Delete'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- AI Entry form for Heat alerts ----------

  Widget _buildAIEntryForm(AppNotification notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Entry'.tr,
            style: AppTheme.headingSmall.copyWith(color: Colors.green.shade800),
          ),
          const SizedBox(height: 12),

          // Semen straw type
          Text(
            'Semen Straw Type'.tr,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSemenTypeChip('NORMAL'),
              const SizedBox(width: 10),
              _buildSemenTypeChip('SORTED'),
            ],
          ),
          const SizedBox(height: 16),

          // Submit / Cancel
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmittingAI
                      ? null
                      : () => _submitAIEntry(notification),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  child: _isSubmittingAI
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Submit AI Entry'.tr),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _isSubmittingAI
                    ? null
                    : () {
                        setState(() => _aiFormNotificationId = null);
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.mediumGrey,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                child: Text('Cancel'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemenTypeChip(String type) {
    final isSelected = _selectedSemenType == type;
    return ChoiceChip(
      selected: isSelected,
      label: Text(type),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : AppTheme.darkGrey,
      ),
      selectedColor: Colors.green.shade700,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
        ),
      ),
      onSelected: (_) {
        setState(() => _selectedSemenType = type);
      },
    );
  }

  Future<void> _submitAIEntry(AppNotification notification) async {
    if (notification.deviceId == null || notification.deviceId!.isEmpty) return;

    setState(() => _isSubmittingAI = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        if (mounted) ToastUtils.showError(context, 'Session expired'.tr);
        return;
      }

      final body = {
        'device_id': notification.deviceId!,
        'ai_generate_date': DateTime.now().toUtc().toIso8601String(),
        'is_ai_generated': false,
        'semen_straw_type': _selectedSemenType,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.appLiveUrl}/animal/ai_entry'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ToastUtils.showSuccess(context, 'AI entry recorded successfully'.tr);
        setState(() {
          _aiFormNotificationId = null;
          _expandedNotificationId = null;
        });
      } else {
        final error = jsonDecode(response.body);
        final detail = error['detail'] ?? 'Failed to submit AI entry';
        ToastUtils.showError(context, detail.toString());
      }
    } catch (e) {
      if (mounted) ToastUtils.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmittingAI = false);
    }
  }

  // ---------- Helper widgets ----------

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.mediumGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeBadge(String alertType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 0.5),
      ),
      child: Text(
        alertType,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.orange.shade800,
        ),
      ),
    );
  }

  Widget _buildDeviceBadge(String deviceId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 0.5),
      ),
      child: Text(
        deviceId,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Color _getCategoryColor(AppNotification notification) {
    if (notification.notificationCategory == 'iot_alert') return Colors.orange;
    return NotificationColors.getColor(notification.type);
  }

  IconData _getCategoryIcon(AppNotification notification) {
    if (notification.notificationCategory == 'iot_alert') return Icons.sensors;
    if (notification.notificationCategory == 'ticket') return Icons.assignment;
    return NotificationColors.getIcon(notification.type);
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppConstants.iconM),
        const SizedBox(height: AppConstants.spacingS),
        Text(value, style: AppTheme.headingSmall.copyWith(color: color)),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now'.tr;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ${'ago'.tr}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ${'ago'.tr}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ${'ago'.tr}';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppTheme.mediumGrey),
          SizedBox(height: AppConstants.spacingM),
          Text('No notifications'.tr, style: AppTheme.headingMedium),
          SizedBox(height: AppConstants.spacingS),
          Text(
            'You\'re all caught up!'.tr,
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
