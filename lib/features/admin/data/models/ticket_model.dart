class Ticket {
  final int id;
  final String ticketType;
  final String status;
  final String description;
  final String? animalId;
  final String? rfid;
  final DateTime? createdAt;
  final String? priority;
  final Map<String, dynamic>? metadata;

  Ticket({
    required this.id,
    required this.ticketType,
    required this.status,
    required this.description,
    this.animalId,
    this.rfid,
    this.createdAt,
    this.priority,
    this.metadata,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      ticketType: json['ticket_type'] ?? json['type'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      animalId: json['animal_id']?.toString(),
      rfid: json['rfid']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      priority: json['priority'],
      metadata:
          json, // Capture full JSON to access extra fields like source_shed_name
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_type': ticketType,
      'status': status,
      'description': description,
      'animal_id': animalId,
      'rfid': rfid,
      'created_at': createdAt?.toIso8601String(),
      'priority': priority,
      'metadata': metadata,
    };
  }
}
