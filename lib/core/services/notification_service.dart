import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

enum NotificationType { info, warning, error, success }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final List<Function(List<AppNotification>)> _listeners = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initializeFCM() async {
    // Request permission
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Handle background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // Navigate to tickets or relevant screen
      // AppRouter.router.push('/tickets');
    });

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        addNotification(
          AppNotification(
            id:
                message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: message.notification?.title ?? 'Notification',
            message: message.notification?.body ?? '',
            type: NotificationType.info,
            timestamp: DateTime.now(),
          ),
        );
      }
    });

    // Check for initial message
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        // Handle navigation for initial message
      }
    });

    // Print FCM Token
    await printFCMToken();
  }

  Future<void> printFCMToken() async {
    try {
      if (Platform.isIOS) {
        // Wait for APNS token to be available
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        int retryCount = 0;
        while (apnsToken == null && retryCount < 10) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          retryCount++;
          debugPrint('Waiting for APNS token... (Attempt $retryCount)');
        }

        if (apnsToken == null) {
          debugPrint(
            'APNS token still null after retries. FCM token might fail.',
          );
        } else {
          debugPrint('APNS token set: $apnsToken');
        }
      }

      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint('================ FCM TOKEN ================');
      debugPrint(token);
      debugPrint('============================================');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  void addListener(Function(List<AppNotification>) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(List<AppNotification>) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_notifications);
    }
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }

  // Predefined notification generators
  void sendVaccinationReminder(String buffaloId) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Vaccination Reminder',
        message: '$buffaloId is due for vaccination',
        type: NotificationType.warning,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendHealthIssueAlert(String buffaloId, String issue) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Health Issue Alert',
        message: '$buffaloId: $issue',
        type: NotificationType.error,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendRecoveryUpdate(String buffaloId) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Recovery Complete',
        message: '$buffaloId has fully recovered',
        type: NotificationType.success,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendVisitConfirmation(String date, String time) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Visit Confirmed',
        message: 'Your visit is scheduled for $date at $time',
        type: NotificationType.info,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendTicketUpdate(String ticketId, String status) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Ticket Update',
        message: 'Ticket $ticketId status: $status',
        type: NotificationType.info,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendTransferApproval(String buffaloId, bool approved) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: approved ? 'Transfer Approved' : 'Transfer Rejected',
        message:
            '$buffaloId transfer request ${approved ? 'approved' : 'rejected'}',
        type: approved ? NotificationType.success : NotificationType.warning,
        timestamp: DateTime.now(),
      ),
    );
  }

  void sendPriorityAlert(String message) {
    addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Priority Alert',
        message: message,
        type: NotificationType.error,
        timestamp: DateTime.now(),
      ),
    );
  }

  // Initialize with sample notifications
  void initializeSampleNotifications() {
    final sampleNotifications = [
      AppNotification(
        id: '1',
        title: 'Vaccination Reminder',
        message: 'BUF-003 is due for FMD vaccination',
        type: NotificationType.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      AppNotification(
        id: '2',
        title: 'Health Issue Alert',
        message: 'BUF-007 showing signs of fever',
        type: NotificationType.error,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: '3',
        title: 'Recovery Complete',
        message: 'BUF-012 has fully recovered from infection',
        type: NotificationType.success,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: '4',
        title: 'Visit Confirmed',
        message: 'Your visit is scheduled for Dec 15, 2024 at 10:00 AM',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      AppNotification(
        id: '5',
        title: 'Ticket Update',
        message: 'Ticket TKT-001 has been assigned to Dr. Sharma',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
      ),
    ];

    _notifications.addAll(sampleNotifications);
    _notifyListeners();
  }
}

// Notification colors helper
class NotificationColors {
  static Color getColor(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.success:
        return Colors.green;
    }
  }

  static IconData getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
    }
  }
}
