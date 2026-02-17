// Enums for the FarmVest application

import 'dart:io';
import 'package:flutter/material.dart';
/// Defines the different types of users in the application
enum UserType {
  customer('customer'),
  supervisor('supervisor'),
  doctor('doctor'),
  assistant('assistant'),
  farmManager('farm_manager');

  final String value;
  const UserType(this.value);

  static UserType fromString(String value) {
    final normalized = value.toLowerCase().trim().replaceAll(' ', '_');

    // Explicit mapping for known backend roles
    if (normalized == 'investor' || normalized == 'customer') {
      return UserType.customer;
    }
    if (normalized == 'supervisor') return UserType.supervisor;
    if (normalized == 'doctor') return UserType.doctor;
    if (normalized == 'farm_manager' || normalized == 'manager') {
      return UserType.farmManager;
    }
    if (normalized == 'assistant' || normalized == 'assistant_doctor') {
      return UserType.assistant;
    }

    return UserType.values.firstWhere(
      (type) => type.value == normalized,
      orElse: () => UserType.customer, // Default to customer if not found
    );
  }

  String get backendValue {
    switch (this) {
      case UserType.customer:
        return 'INVESTOR';
      case UserType.farmManager:
        return 'FARM_MANAGER';
      case UserType.supervisor:
        return 'SUPERVISOR';
      case UserType.doctor:
        return 'DOCTOR';
      case UserType.assistant:
        return 'ASSISTANT_DOCTOR';
    }
  }

  String get label {
    switch (this) {
      case UserType.customer:
        return 'Investor';
      case UserType.farmManager:
        return 'Farm Manager';
      case UserType.supervisor:
        return 'Supervisor';
      case UserType.doctor:
        return 'Doctor';
      case UserType.assistant:
        return 'Assistant';
    }
  }

  IconData get icon {
    switch (this) {
      case UserType.farmManager:
        return Icons.agriculture;
      case UserType.supervisor:
        return Icons.assignment_ind;
      case UserType.doctor:
        return Icons.medical_services;
      case UserType.assistant:
        return Icons.health_and_safety;
      case UserType.customer:
        return Icons.trending_up;
    }
  }

  Color get color {
    switch (this) {
      case UserType.farmManager:
        return Colors.green;
      case UserType.supervisor:
        return Colors.orange;
      case UserType.doctor:
        return Colors.red;
      case UserType.assistant:
        return Colors.teal;
      case UserType.customer:
        return Colors.indigo;
    }
  }
}

/// Defines the different routes in the application
enum AppRoutes {
  splash('/splash'),
  userTypeSelection('/user-type-selection'),
  login('/login'),
  customerDashboard('/customer-dashboard'),
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
  pending('PENDING', 'Pending'),
  open('OPEN', 'Open'),
  inProgress('IN_PROGRESS', 'In Progress'),
  resolved('RESOLVED', 'Resolved'),
  closed('CLOSED', 'Closed');

  final String value;
  final String displayName;
  const TicketStatus(this.value, this.displayName);

  static TicketStatus fromString(String status) {
    final normalized = status.toUpperCase().trim().replaceAll(' ', '_');
    return TicketStatus.values.firstWhere(
      (s) => s.value == normalized || s.displayName.toUpperCase() == normalized,
      orElse: () => TicketStatus.open,
    );
  }
}

/// Defines the different types of tickets
enum TicketType {
  health('HEALTH', 'Health Issue'),
  transfer('TRANSFER', 'Transfer Request'),
  other('OTHER', 'Other');

  final String value;
  final String label;
  const TicketType(this.value, this.label);

  static TicketType fromString(String type) {
    final normalized = type.toUpperCase().trim().replaceAll(' ', '_');
    return TicketType.values.firstWhere(
      (t) => t.value == normalized || t.label.toUpperCase() == normalized,
      orElse: () => TicketType.other,
    );
  }
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

/// Defines the different priorities a ticket can have
enum TicketPriority {
  low('LOW', 'Low'),
  medium('MEDIUM', 'Medium'),

  high('HIGH', 'High'),
  critical('CRITICAL', 'Critical');

  final String value;
  final String label;
  const TicketPriority(this.value, this.label);

  static TicketPriority fromString(String priority) {
    final normalized = priority.toUpperCase().trim();
    return TicketPriority.values.firstWhere(
      (p) => p.value == normalized || p.label.toUpperCase() == normalized,
      orElse: () => TicketPriority.medium,
    );
  }
}

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
