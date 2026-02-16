import 'package:farm_vest/core/services/notification_service.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable notification bell icon button with unread badge.
/// Use in AppBar actions across all role dashboards.
class NotificationBellButton extends StatefulWidget {
  final String fallbackRoute;
  final Color? iconColor;

  const NotificationBellButton({
    super.key,
    required this.fallbackRoute,
    this.iconColor,
  });

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _unreadCount = _notificationService.unreadCount;
    _notificationService.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged(List<AppNotification> notifications) {
    if (mounted) {
      setState(() {
        _unreadCount = _notificationService.unreadCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_outlined,
            color: widget.iconColor ?? Theme.of(context).colorScheme.onSurface,
          ),
          if (_unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () => context.push(
        '/notifications',
        extra: {'fallbackRoute': widget.fallbackRoute},
      ),
      tooltip: 'Notifications',
    );
  }
}
