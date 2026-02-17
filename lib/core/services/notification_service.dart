import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/router/app_router.dart';
import 'dart:io';
// import 'package:flutter_app_badger/flutter_app_badger.dart';  // Temporarily disabled for release build
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  final String? notificationCategory; // "ticket", "leave", etc.
  final int? referenceId; // ticket_id, leave_id, etc.

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.notificationCategory,
    this.referenceId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? notificationCategory,
    int? referenceId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      notificationCategory: notificationCategory ?? this.notificationCategory,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['body'] ?? '',
      type: NotificationType.info,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      notificationCategory: json['notification_type'],
      referenceId: json['reference_id'],
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final List<Function(List<AppNotification>)> _listeners = [];
  Timer? _pollTimer;
  int _unreadCount = 0;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

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
      _handleNotificationTap(message.data);
    });

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        final data = message.data;
        addNotification(
          AppNotification(
            id:
                message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: message.notification?.title ?? 'Notification',
            message: message.notification?.body ?? '',
            type: NotificationType.info,
            timestamp: DateTime.now(),
            notificationCategory: data['ticket_id'] != null ? 'ticket' : null,
            referenceId: data['ticket_id'] != null
                ? int.tryParse(data['ticket_id'])
                : null,
          ),
        );
        // Refresh unread count from backend
        fetchUnreadCount();
      }
    });

    // Check for initial message (app opened from terminated state via notification)
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        _handleNotificationTap(message.data);
      }
    });

    // Create the channel on the device (Android 8.0+)
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'farmvest_notifications', // id
      'FarmVest Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Update foreground presentation options to allow heads-up notifications
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Print FCM Token
    await printFCMToken();

    // Subscribe to test IoT topic
    // await subscribeToTopic('iot_alert'); // Removed static subscription

    // Start polling unread count every 30 seconds
    startPolling();
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final ticketId = data['ticket_id'];
    if (ticketId != null) {
      AppRouter.router.push('/all-health-tickets');
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    fetchUnreadCount();
    _pollTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchUnreadCount();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Fetch unread count from backend API
  Future<void> fetchUnreadCount() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final baseUrl = AppConstants.appLiveUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread_count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newCount = data['unread_count'] ?? 0;
        if (newCount != _unreadCount) {
          _unreadCount = newCount;
          _updateAppBadge();
          _notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Error fetching unread count: $e');
    }
  }

  /// Fetch notification history from backend API
  Future<void> fetchNotificationHistory({int page = 1, int size = 20}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final baseUrl = AppConstants.appLiveUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/history?page=$page&size=$size'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['data'] ?? [];
        _notifications.clear();
        _notifications.addAll(
          items.map((item) => AppNotification.fromJson(item)),
        );
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationService] Error fetching history: $e');
    }
  }

  /// Mark notification(s) as read via backend API
  Future<void> markAsReadOnServer({int? notificationId}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final baseUrl = AppConstants.appLiveUrl;
      String url = '$baseUrl/notifications/mark_read';
      if (notificationId != null) {
        url += '?notification_id=$notificationId';
      }

      await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      await fetchUnreadCount();
    } catch (e) {
      debugPrint('[NotificationService] Error marking read: $e');
    }
  }

  Future<void> printFCMToken() async {
    try {
      if (Platform.isIOS) {
        // Wait for APNS token to be available
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        int retryCount = 0;
        while (apnsToken == null && retryCount < 10) {
          await Future.delayed(Duration(seconds: 1));
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
    _unreadCount++;
    _updateAppBadge();
    _notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
      // Also mark on server
      final serverId = int.tryParse(notificationId);
      if (serverId != null) {
        markAsReadOnServer(notificationId: serverId);
      }
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
    _updateAppBadge();
    _notifyListeners();
    // Also mark all on server
    markAsReadOnServer();
  }

  // Temporarily disabled for release build - flutter_app_badger package issue
  void _updateAppBadge() {
    // try {
    //   FlutterAppBadger.isAppBadgeSupported()
    //       .then((isSupported) {
    //         if (isSupported) {
    //           if (_unreadCount > 0) {
    //             FlutterAppBadger.updateBadgeCount(_unreadCount);
    //           } else {
    //             FlutterAppBadger.removeBadge();
    //           }
    //         }
    //       })
    //       .catchError((e) {
    //         debugPrint('App badge not supported on this device: $e');
    //       });
    // } catch (e) {
    //   debugPrint('App badge error: $e');
    // }
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
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
        notificationCategory: 'ticket',
        referenceId: int.tryParse(ticketId),
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
        notificationCategory: 'ticket',
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
