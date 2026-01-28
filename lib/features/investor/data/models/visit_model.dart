class InvestorFarm {
  final int farmId;
  final String farmName;
  final String location;
  final int investorBuffaloesCount;

  InvestorFarm({
    required this.farmId,
    required this.farmName,
    required this.location,
    required this.investorBuffaloesCount,
  });

  factory InvestorFarm.fromJson(Map<String, dynamic> json) {
    return InvestorFarm(
      farmId: json['farm_id'] as int,
      farmName: json['farm_name'] as String,
      location: json['location'] as String,
      investorBuffaloesCount: json['investor_buffaloes_count'] as int,
    );
  }
}

class VisitAvailability {
  final String visitDate;
  final String farmName;
  final int totalCapacityPerSlot;
  final List<String> availableSlots;
  final List<dynamic> filledSlots;

  VisitAvailability({
    required this.visitDate,
    required this.farmName,
    required this.totalCapacityPerSlot,
    required this.availableSlots,
    required this.filledSlots,
  });

  factory VisitAvailability.fromJson(Map<String, dynamic> json) {
    return VisitAvailability(
      visitDate: json['visit_date'] as String,
      farmName: json['farm_name'] as String,
      totalCapacityPerSlot: json['total_capacity_per_slot'] as int,
      availableSlots: List<String>.from(json['available_slots'] ?? []),
      filledSlots: List<dynamic>.from(json['filled_slots'] ?? []),
    );
  }
}

class Visit {
  final String visitId;
  final String userMobile;
  final String visitDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String status;
  final String? farmName;
  final String? farmLocation;
  final int farmId;

  Visit({
    required this.visitId,
    required this.userMobile,
    required this.visitDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    this.farmName,
    this.farmLocation,
    required this.farmId,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      visitId: json['visit_id'] as String,
      userMobile: json['user_mobile'] as String,
      visitDate: json['visit_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      status: json['status'] as String,
      farmName: json['farm_name'] as String?,
      farmLocation: json['farm_location'] as String?,
      farmId: json['farm_id'] as int,
    );
  }
}

class VisitBookingRequest {
  final int farmId;
  final String startTime;
  final String visitDate;

  VisitBookingRequest({
    required this.farmId,
    required this.startTime,
    required this.visitDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'farm_id': farmId,
      'start_time': startTime,
      'visit_date': visitDate,
    };
  }
}
