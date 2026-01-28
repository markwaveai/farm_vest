// Enums for the FarmVest application

import 'dart:io';

/// Defines the different types of users in the application
enum UserType {
  customer('customer'),
  supervisor('supervisor'),
  doctor('doctor'),
  assistant('assistant'),
  farmManager('farm_manager'),
  admin('admin');

  final String value;
  const UserType(this.value);

  static UserType fromString(String value) {
    final normalized = value.toLowerCase().trim().replaceAll(' ', '_');

    // Explicit mapping for known backend roles
    if (normalized == 'investor' || normalized == 'customer')
      return UserType.customer;
    if (normalized == 'supervisor') return UserType.supervisor;
    if (normalized == 'doctor') return UserType.doctor;
    if (normalized == 'farm_manager' || normalized == 'manager')
      return UserType.farmManager;
    if (normalized == 'admin' || normalized == 'administrator')
      return UserType.admin;
    if (normalized == 'assistant' || normalized == 'assistant_doctor')
      return UserType.assistant;

    return UserType.values.firstWhere(
      (type) => type.value == normalized,
      orElse: () => UserType.customer, // Default to customer if not found
    );
  }
}

/// Defines the different routes in the application
enum AppRoutes {
  splash('/splash'),
  userTypeSelection('/user-type-selection'),
  login('/login'),
  customerDashboard('/customer-dashboard'),
  adminDashboard('/admin-dashboard'),
  unitDetails('/unit-details'),
  cctvLive('/cctv-live'),
  monthlyVisits('/monthly-visits'),
  revenue('/revenue'),
  assetValuation('/asset-valuation'),
  support('/support'),
  supervisorDashboard('/supervisor-dashboard'),
  doctorDashboard('/doctor-dashboard'),
  assistantDashboard('/assistant-dashboard'),
  farmManagerDashboard('/farm-manager-dashboard'),
  milkProduction('/milk-production'),
  healthIssues('/health-issues'),
  raiseTicket('/raise-ticket'),
  profile('/profile'),
  notifications('/notifications');

  final String path;
  const AppRoutes(this.path);

  /// Helper method to get route name from path
  static AppRoutes? fromPath(String path) {
    try {
      return AppRoutes.values.firstWhere((route) => route.path == path);
    } catch (e) {
      return null;
    }
  }
}

/// Defines the different statuses a ticket can have
enum TicketStatus {
  open('Open'),
  inProgress('In Progress'),
  resolved('Resolved'),
  closed('Closed');

  final String displayName;
  const TicketStatus(this.displayName);
}

/// Defines the different types of notifications
enum NotificationType {
  info('info'),
  success('success'),
  warning('warning'),
  error('error');

  final String value;
  const NotificationType(this.value);
}

enum MessageType { user, ai, system, typing }

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime time;
  final File? imageFile;

  ChatMessage({
    required this.text,
    required this.type,
    required this.time,
    this.imageFile,
  });
}

enum CompressFormat {
  jpeg,
  png,

  /// - iOS: Supported from iOS11+.
  /// - Android: Supported from API 28+ which require hardware encoder supports,
  ///   Use [HeifWriter](https://developer.android.com/reference/androidx/heifwriter/HeifWriter.html)
  heic,

  /// Only supported on Android.
  webp,
}
