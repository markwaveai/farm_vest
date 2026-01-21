class TicketModel {
  final String visitDate;
  final List<String> availableSlots;
  final String message;

  TicketModel({
    required this.visitDate,
    required this.availableSlots,
    required this.message,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      visitDate: json['visit_date'] ?? '',
      availableSlots: List<String>.from(json['available_slots'] ?? []),
      message: json['message'] ?? '',
    );
  }
}

class Ticket {
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

  Ticket({
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

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
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
