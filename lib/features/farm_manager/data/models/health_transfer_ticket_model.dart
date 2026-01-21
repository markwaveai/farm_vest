class HealthTransferTicketModel {
  final int ticketId;
  final int animalId;
  final int shedId;
  final String rowId;
  final String positionId;
  final List<String> disease;
  final String description;
  final String? priority;
  final String status;
  final int? doctorId;
  final int? assistantDoctorId;
  final DateTime createdAt;

  HealthTransferTicketModel({
    required this.ticketId,
    required this.animalId,
    required this.shedId,
    required this.rowId,
    required this.positionId,
    required this.disease,
    required this.description,
    this.priority,
    required this.status,
    this.doctorId,
    this.assistantDoctorId,
    required this.createdAt,
  });

  factory HealthTransferTicketModel.fromJson(Map<String, dynamic> json) {
    return HealthTransferTicketModel(
      ticketId: json['ticket_id'] as int,
      animalId: json['animal_id'] as int,
      shedId: json['shed_id'] as int,
      rowId: json['row_id'] as String,
      positionId: json['position_id'] as String,
      disease: (json['disease'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String,
      priority: json['priority'] as String?,
      status: json['status'] as String,
      doctorId: json['doctor_id'] as int?,
      assistantDoctorId: json['assistant_doctor_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
      'animal_id': animalId,
      'shed_id': shedId,
      'row_id': rowId,
      'position_id': positionId,
      'disease': disease,
      'description': description,
      'priority': priority,
      'status': status,
      'doctor_id': doctorId,
      'assistant_doctor_id': assistantDoctorId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
