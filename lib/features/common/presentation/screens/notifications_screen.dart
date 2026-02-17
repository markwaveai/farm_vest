import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/services/notification_service.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

import 'package:farm_vest/core/localization/translation_helpers.dart';
class NotificationsScreen extends ConsumerStatefulWidget {
  final String fallbackRoute;
  NotificationsScreen({super.key, required this.fallbackRoute});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();

    // Fetch real notifications from backend
    _notificationService.fetchNotificationHistory();

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNotifications();
    });

    _notificationService.addListener(_onNotificationsChangedFull);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChangedFull);
    super.dispose();
  }

  void _updateNotifications() {
    if (mounted) {
      setState(() {
        _notifications = _notificationService.notifications;
      });
    }
  }

  void _onNotificationsChangedFull(List<AppNotification> allNotifications) {
    if (mounted) {
      _updateNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    final readNotifications = _notifications.where((n) => n.isRead).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        NavigationHelper.safePopOrNavigate(
          context,
          fallbackRoute: widget.fallbackRoute,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'.tr(ref)),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => NavigationHelper.safePopOrNavigate(
              context,
              fallbackRoute: widget.fallbackRoute,
            ),
          ),
          actions: [
            if (_notifications.isNotEmpty) ...[
              IconButton(
                icon: Icon(Icons.done_all),
                onPressed: () {
                  _notificationService.markAllAsRead();
                  ToastUtils.showInfo(context, 'All notifications marked as read'.tr(ref));
                },
                tooltip: 'Mark all as read'.tr(ref),
              ),
              IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: () => _showClearAllDialog(),
                tooltip: 'Clear all'.tr(ref),
              ),
            ],
          ],
        ),
        body: _notifications.isEmpty
            ? _buildEmptyState()
            : SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary
                    if (_notifications.isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spacingM),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  'Total'.tr(ref),
                                  _notifications.length.toString(),
                                  Icons.notifications,
                                  AppTheme.primary,
                                ),
                              ),
                              Expanded(
                                child: _buildSummaryItem(
                                  'Unread'.tr(ref),
                                  unreadNotifications.length.toString(),
                                  Icons.mark_email_unread,
                                  AppTheme.warningOrange,
                                ),
                              ),
                              Expanded(
                                child: _buildSummaryItem(
                                  'Read'.tr(ref),
                                  readNotifications.length.toString(),
                                  Icons.mark_email_read,
                                  AppTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingL),
                    ],

                    // Unread Notifications
                    if (unreadNotifications.isNotEmpty) ...[
                      Text('Unread'.tr(ref), style: AppTheme.headingMedium),
                      SizedBox(height: AppConstants.spacingM),
                      ...unreadNotifications.map(
                        (notification) => _buildNotificationCard(
                          notification,
                          isUnread: true,
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingL),
                    ],

                    // Read Notifications
                    if (readNotifications.isNotEmpty) ...[
                      Text('Read'.tr(ref), style: AppTheme.headingMedium),
                      SizedBox(height: AppConstants.spacingM),
                      ...readNotifications.map(
                        (notification) => _buildNotificationCard(
                          notification,
                          isUnread: false,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppTheme.mediumGrey,
          ),
          SizedBox(height: AppConstants.spacingM),
          Text('No notifications'.tr(ref), style: AppTheme.headingMedium),
          SizedBox(height: AppConstants.spacingS),
          Text(
            'You\'re all caught up!'.tr(ref),
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
        SizedBox(height: AppConstants.spacingS),
        Text(value, style: AppTheme.headingSmall.copyWith(color: color)),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  Widget _buildNotificationCard(
    AppNotification notification, {
    required bool isUnread,
  }) {
    final color = NotificationColors.getColor(notification.type);
    final icon = NotificationColors.getIcon(notification.type);

    return Card(
      margin: EdgeInsets.only(bottom: AppConstants.spacingM),
      color: isUnread ? color.withValues(alpha: 0.05) : null,
      child: InkWell(
        onTap: () {
          if (isUnread) {
            _notificationService.markAsRead(notification.id);
          }
          // Navigate to ticket if it's a ticket notification
          if (notification.notificationCategory == 'ticket' &&
              notification.referenceId != null) {
            context.push('/all-health-tickets');
          }
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: AppConstants.iconM),
              ),
              SizedBox(width: AppConstants.spacingM),

              // Content
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
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppConstants.spacingS),
                    Text(
                      notification.message,
                      style: AppTheme.bodyMedium.copyWith(
                        color: isUnread
                            ? AppTheme.darkGrey
                            : AppTheme.mediumGrey,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingS),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      _notificationService.markAsRead(notification.id);
                      break;
                    case 'delete':
                      _notificationService.removeNotification(notification.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (isUnread)
                    PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read),
                          SizedBox(width: AppConstants.spacingS),
                          Text('Mark as read'.tr(ref)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: AppConstants.spacingS),
                        Text('Delete'.tr(ref)),
                      ],
                    ),
                  ),
                ],
                child: Icon(Icons.more_vert, color: AppTheme.mediumGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now'.tr(ref);
    } else if (difference.inMinutes < 60) {
      return '@countm ago'.trParams({'count': difference.inMinutes.toString()});
    } else if (difference.inHours < 24) {
      return '@counth ago'.trParams({'count': difference.inHours.toString()});
    } else if (difference.inDays < 7) {
      return '@countd ago'.trParams({'count': difference.inDays.toString()});
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Notifications'.tr(ref)),
        content: Text('Are you sure you want to clear all notifications? This action cannot be undone.'.tr(ref)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(ref)),
          ),
          ElevatedButton(
            onPressed: () {
              _notificationService.clearAll();
              Navigator.pop(context);
              ToastUtils.showInfo(context, 'All notifications cleared'.tr(ref));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Clear all'.tr(ref)),
          ),
        ],
      ),
    );
  }
}
