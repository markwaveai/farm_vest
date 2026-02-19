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
  final String? notificationCategory; // "ticket", "iot_alert", "leave", etc.
  final int? referenceId; // ticket_id, iot_alert_id, etc.
  final String? alertType; // IoT alert subtype: "Heat", "Health", "BH", etc.
  final String? deviceId; // neckband/device ID for IoT alerts

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.notificationCategory,
    this.referenceId,
    this.alertType,
    this.deviceId,
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
    String? alertType,
    String? deviceId,
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
      alertType: alertType ?? this.alertType,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final notifType = json['notification_type'] as String?;
    String? alertType;
    String? deviceId;

    // Extract alert type from title: "IoT Alert: Heat" → "Heat"
    final title = json['title'] ?? '';
    if (notifType == 'iot_alert' && title.startsWith('IoT Alert: ')) {
      alertType = title.substring('IoT Alert: '.length);
    }

    // Extract device ID from body: "Heat alert for device S1IAD1458" → "S1IAD1458"
    final body = json['body'] ?? '';
    final deviceMatch = RegExp(r'for device (\S+)').firstMatch(body);
    if (deviceMatch != null) {
      deviceId = deviceMatch.group(1);
    }

    return AppNotification(
      id: (json['notification_id'] ?? json['id']).toString(),
      title: title,
      message: body,
      type: notifType == 'iot_alert' ? NotificationType.warning : NotificationType.info,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      notificationCategory: notifType,
      referenceId: json['reference_id'],
      alertType: alertType,
      deviceId: deviceId,
    );
  }

  /// Create from neckband/IoT alerts endpoint response
  /// API fields: _id, deviceid, FarmName, farmid, msg_title, msg_body,
  ///             alert_type, notification_type, cdate_hr, timestamp
  factory AppNotification.fromNeckbandAlert(Map<String, dynamic> json) {
    final alertType = (json['alert_type'] ?? '') as String;
    final deviceId = (json['deviceid'] ?? json['device_id'] ?? '') as String;

    // msg_title / msg_body are the actual fields from Elastic
    final msgTitle = json['msg_title'] as String?;
    final msgBody = json['msg_body'] as String?;

    final title = (msgTitle != null && msgTitle.isNotEmpty)
        ? msgTitle
        : 'IoT Alert: $alertType';
    final body = (msgBody != null && msgBody.isNotEmpty)
        ? msgBody
        : '$alertType alert for device $deviceId';

    DateTime timestamp;
    try {
      if (json['timestamp'] != null) {
        // External API timestamps are UTC but lack 'Z' suffix — append it
        final raw = json['timestamp'].toString();
        timestamp = DateTime.parse(raw.endsWith('Z') ? raw : '${raw}Z').toLocal();
      } else if (json['created_at'] != null) {
        final raw = json['created_at'].toString();
        timestamp = DateTime.parse(raw.endsWith('Z') ? raw : '${raw}Z').toLocal();
      } else {
        timestamp = DateTime.now();
      }
    } catch (_) {
      timestamp = DateTime.now();
    }

    return AppNotification(
      id: (json['_id'] ?? json['iot_alert_id'] ?? json['id'] ?? 0).toString(),
      title: title,
      message: body,
      type: NotificationType.warning,
      timestamp: timestamp,
      isRead: true,
      notificationCategory: 'iot_alert',
      alertType: alertType.isNotEmpty ? alertType : null,
      deviceId: deviceId.isNotEmpty ? deviceId : null,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _localNotificationsKey = 'local_fcm_notifications';

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

    // Handle background notification tap — persist + navigate
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _persistAndHandleNotificationTap(message);
    });

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        final data = message.data;

        // Properly categorize: IoT alerts have alert_type or device_id (without ticket_id)
        final notifCategory = _categorizeFromFcmData(data);

        addNotification(
          AppNotification(
            id:
                message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: message.notification?.title ?? 'Notification',
            message: message.notification?.body ?? '',
            type: notifCategory == 'iot_alert'
                ? NotificationType.warning
                : NotificationType.info,
            timestamp: DateTime.now(),
            notificationCategory: notifCategory,
            referenceId: data['reference_id'] != null
                ? int.tryParse(data['reference_id'])
                : (data['ticket_id'] != null
                    ? int.tryParse(data['ticket_id'])
                    : null),
            alertType: data['alert_type'],
            deviceId: data['device_id'],
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
        _persistAndHandleNotificationTap(message);
      }
    });

    // Create the channel on the device (Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
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
    final notifType = data['notification_type'];
    final deviceId = data['device_id'];
    final alertType = data['alert_type'];
    final ticketId = data['ticket_id'];

    // For IoT alerts, use the alert subtype (Heat, Health, BH, etc.) as initialFilter
    // so the correct tab is auto-selected. Fall back to notification_type for others.
    String? initialFilter;
    if (alertType != null && alertType.isNotEmpty) {
      initialFilter = alertType; // e.g. "Heat", "Health", "BH", "MissingTag", "System"
    } else if (notifType != null) {
      initialFilter = notifType; // e.g. "ticket", "iot_alert"
    } else if (ticketId != null) {
      initialFilter = 'ticket';
    } else if (deviceId != null) {
      initialFilter = 'iot_alert';
    }

    AppRouter.router.push('/notifications', extra: {
      'fallbackRoute': '/',
      'initialFilter': initialFilter,
      'deviceId': deviceId,
      'alertType': alertType,
    });
  }

  /// Determine notification category from FCM data payload
  String? _categorizeFromFcmData(Map<String, dynamic> data) {
    // IoT alerts have alert_type or device_id (without ticket_id)
    if (data['alert_type'] != null ||
        (data['device_id'] != null && data['ticket_id'] == null)) {
      return 'iot_alert';
    }
    if (data['ticket_id'] != null || data['notification_type'] == 'ticket') {
      return 'ticket';
    }
    // Fallback: use notification_type as-is, but normalize known IoT types
    final rawType = data['notification_type']?.toString().toUpperCase();
    if (rawType == 'HEALTH' || rawType == 'HEAT' || rawType == 'BH' ||
        rawType == 'MISSING TAG' || rawType == 'SYSTEM' || rawType == 'IOT_ALERT') {
      return 'iot_alert';
    }
    return data['notification_type'] ?? 'ticket';
  }

  /// Persist FCM notification locally + navigate (for background/terminated taps)
  void _persistAndHandleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final notifCategory = _categorizeFromFcmData(data);

    final notif = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? data['title'] ?? 'Notification',
      message: message.notification?.body ?? data['body'] ?? '',
      type: notifCategory == 'iot_alert'
          ? NotificationType.warning
          : NotificationType.info,
      timestamp: DateTime.now(),
      notificationCategory: notifCategory,
      referenceId: data['reference_id'] != null
          ? int.tryParse(data['reference_id'])
          : (data['ticket_id'] != null
              ? int.tryParse(data['ticket_id'])
              : null),
      alertType: data['alert_type'],
      deviceId: data['device_id'],
    );

    addNotification(notif);
    _handleNotificationTap(data);
  }

  // -------- Local FCM Notification Persistence --------

  /// Save an FCM notification to SharedPreferences for persistence
  Future<void> _saveFcmNotificationLocally(AppNotification notif) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_localNotificationsKey) ?? [];
      final json = jsonEncode({
        'id': notif.id,
        'title': notif.title,
        'message': notif.message,
        'type': notif.type.index,
        'timestamp': notif.timestamp.toIso8601String(),
        'isRead': notif.isRead,
        'notificationCategory': notif.notificationCategory,
        'referenceId': notif.referenceId,
        'alertType': notif.alertType,
        'deviceId': notif.deviceId,
      });
      stored.insert(0, json);
      // Keep max 200 local notifications
      if (stored.length > 200) stored.removeRange(200, stored.length);
      await prefs.setStringList(_localNotificationsKey, stored);
    } catch (e) {
      debugPrint('[NotificationService] Error saving local notification: $e');
    }
  }

  /// Load locally persisted FCM notifications
  Future<List<AppNotification>> _loadLocalFcmNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_localNotificationsKey) ?? [];
      final List<AppNotification> result = [];
      for (final jsonStr in stored) {
        try {
          final json = jsonDecode(jsonStr);
          result.add(AppNotification(
            id: json['id'] ?? '',
            title: json['title'] ?? '',
            message: json['message'] ?? '',
            type: NotificationType.values[json['type'] ?? 0],
            timestamp: DateTime.parse(json['timestamp']),
            isRead: json['isRead'] ?? false,
            notificationCategory: json['notificationCategory'],
            referenceId: json['referenceId'],
            alertType: json['alertType'],
            deviceId: json['deviceId'],
          ));
        } catch (_) {
          // Skip malformed entries
        }
      }
      return result;
    } catch (e) {
      debugPrint('[NotificationService] Error loading local notifications: $e');
      return [];
    }
  }

  /// Update read status in local storage
  Future<void> _markLocalNotificationRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_localNotificationsKey) ?? [];
      final updated = <String>[];
      for (final jsonStr in stored) {
        try {
          final json = jsonDecode(jsonStr);
          if (json['id'] == notificationId) {
            json['isRead'] = true;
            updated.add(jsonEncode(json));
          } else {
            updated.add(jsonStr);
          }
        } catch (_) {
          updated.add(jsonStr);
        }
      }
      await prefs.setStringList(_localNotificationsKey, updated);
    } catch (e) {
      debugPrint('[NotificationService] Error updating local notification: $e');
    }
  }

  /// Remove a notification from local storage
  Future<void> _removeLocalNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_localNotificationsKey) ?? [];
      stored.removeWhere((jsonStr) {
        try {
          final json = jsonDecode(jsonStr);
          return json['id'] == notificationId;
        } catch (_) {
          return false;
        }
      });
      await prefs.setStringList(_localNotificationsKey, stored);
    } catch (e) {
      debugPrint('[NotificationService] Error removing local notification: $e');
    }
  }

  /// Check if a local FCM notification is likely a duplicate of an API notification
  bool _isLikelyDuplicate(AppNotification local, List<AppNotification> apiNotifs) {
    for (final api in apiNotifs) {
      // Same category
      if (local.notificationCategory != api.notificationCategory) continue;
      // Close timestamp (within 5 minutes)
      final timeDiff = local.timestamp.difference(api.timestamp).abs();
      if (timeDiff.inMinutes > 5) continue;
      // For IoT alerts: same device + alert type
      if (local.notificationCategory == 'iot_alert') {
        if (local.deviceId != null &&
            local.deviceId == api.deviceId &&
            local.alertType == api.alertType) return true;
      }
      // For tickets: same title
      if (local.title == api.title) return true;
    }
    return false;
  }

  void startPolling() {
    _pollTimer?.cancel();
    fetchUnreadCount();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
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

  /// Fetch both notification history and neckband IoT alerts, merge by timestamp
  Future<void> fetchNotificationHistory({int page = 1, int size = 20}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return;

      final baseUrl = AppConstants.appLiveUrl;

      const neckbandUrl = AppConstants.notificationServiceUrl;

      final List<AppNotification> merged = [];

      // Fetch ticket notifications (independent — don't block IoT on failure)
      try {
        final ticketResp = await http.get(
          Uri.parse('$baseUrl/notifications/history?page=$page&size=$size'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (ticketResp.statusCode == 200) {
          final data = jsonDecode(ticketResp.body);
          final List items = data['data'] ?? [];
          merged.addAll(items.map((item) => AppNotification.fromJson(item)));
        }
      } catch (e) {
        debugPrint('[NotificationService] Ticket API error: $e');
      }

      // Fetch neckband/IoT alerts (independent — don't block tickets on failure)
      try {
        final iotResp = await http.post(
          Uri.parse('$neckbandUrl/notifications/get-neckband-alerts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}),
        );
        if (iotResp.statusCode == 200) {
          final data = jsonDecode(iotResp.body);
          final List items = data['data'] ?? data['alerts'] ?? (data is List ? data : []);
          merged.addAll(
            items.map((item) => AppNotification.fromNeckbandAlert(item)),
          );
        }
      } catch (e) {
        debugPrint('[NotificationService] IoT alerts API error: $e');
      }

      // Load locally persisted FCM notifications and merge (deduplicate)
      final localNotifs = await _loadLocalFcmNotifications();
      for (final local in localNotifs) {
        if (!_isLikelyDuplicate(local, merged)) {
          merged.add(local);
        }
      }

      // Sort by timestamp descending
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _notifications.clear();
      _notifications.addAll(merged);
      _notifyListeners();
    } catch (e) {
      debugPrint('[NotificationService] Error fetching history: $e');
    }
  }

  /// Fetch only neckband IoT alerts with optional filters
  Future<List<AppNotification>> fetchNeckbandAlerts({
    int? farmId,
    int? shedId,
    String? deviceId,
    String? alertType,
  }) async {
    try {
      const neckbandUrl = AppConstants.notificationServiceUrl;
      final body = <String, dynamic>{};
      if (farmId != null && farmId > 0) body['farm_id'] = farmId;
      if (shedId != null && shedId > 0) body['shed_id'] = shedId;
      if (deviceId != null && deviceId.isNotEmpty) body['deviceid'] = deviceId;
      if (alertType != null && alertType.isNotEmpty) body['alert_type'] = alertType;

      final response = await http.post(
        Uri.parse('$neckbandUrl/notifications/get-neckband-alerts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['data'] ?? data['alerts'] ?? [];
        return items
            .map((item) => AppNotification.fromNeckbandAlert(item))
            .toList();
      }
    } catch (e) {
      debugPrint('[NotificationService] Error fetching neckband alerts: $e');
    }
    return [];
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
    _unreadCount++;
    _updateAppBadge();
    _notifyListeners();
    // Persist locally so it survives app restart and fetchNotificationHistory refresh
    _saveFcmNotificationLocally(notification);
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
      // Update local storage
      _markLocalNotificationRead(notificationId);
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
    _removeLocalNotification(notificationId);
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
