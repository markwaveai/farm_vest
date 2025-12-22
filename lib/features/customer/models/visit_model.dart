class VisitAvailability {
  final String visitDate;
  final List<String> availableSlots;
  final String message;

  VisitAvailability({
    required this.visitDate,
    required this.availableSlots,
    required this.message,
  });

  factory VisitAvailability.fromJson(Map<String, dynamic> json) {
    return VisitAvailability(
      visitDate: json['visit_date'] ?? '',
      availableSlots: List<String>.from(json['available_slots'] ?? []),
      message: json['message'] ?? '',
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
  final String farmLocation;
  final String locationId;
  final String? userName;
  final String? userEmail;

  Visit({
    required this.visitId,
    required this.userMobile,
    required this.visitDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    required this.farmLocation,
    required this.locationId,
    this.userName,
    this.userEmail,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      visitId: json['visitId'] ?? '',
      userMobile: json['user_mobile'] ?? '',
      visitDate: json['visit_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      status: json['status'] ?? '',
      farmLocation: json['farm_location'] ?? '',
      locationId: json['location_id'] ?? '',
      userName: json['user_name'],
      userEmail: json['user_email'],
    );
  }
}

class VisitBookingRequest {
  final String farmLocation;
  final String locationId;
  final String startTime;
  final String userMobile;
  final String visitDate;

  VisitBookingRequest({
    required this.farmLocation,
    required this.locationId,
    required this.startTime,
    required this.userMobile,
    required this.visitDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "farm_location": farmLocation,
      "location_id": locationId,
      "start_time": startTime,
      "user_mobile": userMobile,
      "visit_date": visitDate,
    };
  }
}
