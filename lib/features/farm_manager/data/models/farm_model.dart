class Farm {
  final int id;
  final String farmName;
  final String location;
  final int totalBuffaloesCount;
  final FarmManagerSummary? farmManager;
  final List<ShedSummary> sheds;
  final bool isTest;
  final DateTime? createdAt;

  Farm({
    required this.id,
    required this.farmName,
    required this.location,
    this.totalBuffaloesCount = 0,
    this.farmManager,
    this.sheds = const [],
    this.isTest = false,
    this.createdAt,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      farmName: json['farm_name'] ?? json['name'] ?? '',
      location: json['location'] ?? '',
      totalBuffaloesCount: json['total_buffaloes_count'] is num
          ? (json['total_buffaloes_count'] as num).toInt()
          : 0,
      farmManager: json['farm_manager'] != null
          ? FarmManagerSummary.fromJson(json['farm_manager'])
          : null,
      sheds:
          (json['sheds'] as List<dynamic>?)
              ?.map((s) => ShedSummary.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      isTest: json['is_test'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_name': farmName,
      'location': location,
      'total_buffaloes_count': totalBuffaloesCount,
      'farm_manager': farmManager?.toJson(),
      'sheds': sheds.map((s) => s.toJson()).toList(),
      'is_test': isTest,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class FarmManagerSummary {
  final int userId;
  final String name;
  final String mobile;
  final String? email;
  final String? employmentStatus;

  FarmManagerSummary({
    required this.userId,
    required this.name,
    required this.mobile,
    this.email,
    this.employmentStatus,
  });

  factory FarmManagerSummary.fromJson(Map<String, dynamic> json) {
    return FarmManagerSummary(
      userId: json['user_id'] is num ? (json['user_id'] as num).toInt() : 0,
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      employmentStatus: json['employment_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'mobile': mobile,
      'email': email,
      'employment_status': employmentStatus,
    };
  }
}

class ShedSummary {
  final int id;
  final String shedId;
  final String? shedName;
  final int capacity;
  final int buffaloesCount;

  ShedSummary({
    required this.id,
    required this.shedId,
    this.shedName,
    required this.capacity,
    required this.buffaloesCount,
  });

  factory ShedSummary.fromJson(Map<String, dynamic> json) {
    return ShedSummary(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      shedId: json['shed_id']?.toString() ?? '',
      shedName: json['shed_name'],
      capacity: json['capacity'] is num ? (json['capacity'] as num).toInt() : 0,
      buffaloesCount: json['buffaloes_count'] is num
          ? (json['buffaloes_count'] as num).toInt()
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shed_id': shedId,
      'shed_name': shedName,
      'capacity': capacity,
      'buffaloes_count': buffaloesCount,
    };
  }
}
