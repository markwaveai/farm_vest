class Shed {
  final int id;
  final String shedId;
  final String shedName;
  final String farmName;
  final int currentBuffaloes;
  final int capacity;
  final int availablePositions;
  final String? cctvUrl;
  final String? cctvUrl2;
  final String? cctvUrl3;
  final String? cctvUrl4;
  final int farmId;
  final Map<String, dynamic>? cameraConfig;

  Shed({
    required this.id,
    this.farmId = 0,
    required this.shedId,
    required this.shedName,
    required this.farmName,
    required this.currentBuffaloes,
    required this.capacity,
    required this.availablePositions,
    this.cctvUrl,
    this.cctvUrl2,
    this.cctvUrl3,
    this.cctvUrl4,
    this.cameraConfig,
  });

  factory Shed.fromJson(Map<String, dynamic> json) {
    return Shed(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      farmId: json['farm_id'] is num ? (json['farm_id'] as num).toInt() : 0,
      shedId: json['shed_id'] ?? '',
      shedName: json['shed_name'] ?? '',
      farmName: json['farm_name'] ?? '',
      currentBuffaloes: json['current_buffaloes'] is num
          ? (json['current_buffaloes'] as num).toInt()
          : 0,
      capacity: json['capacity'] is num ? (json['capacity'] as num).toInt() : 0,
      availablePositions: json['available_positions'] is num
          ? (json['available_positions'] as num).toInt()
          : 0,
      cctvUrl: json['cctv_url'],
      cctvUrl2: json['cctv_url_2'],
      cctvUrl3: json['cctv_url_3'],
      cctvUrl4: json['cctv_url_4'],
      cameraConfig: json['camera_config'],
    );
  }
}

class ShedPositionResponse {
  final String message;
  final String shedId;
  final String shedName;
  final String supervisorName;
  final String supervisorMobile;
  final int totalPositions;
  final String? cctvUrl;
  final String? cctvUrl2;
  final String? cctvUrl3;
  final String? cctvUrl4;
  final Map<String, dynamic>? farmDetails;
  final Map<String, dynamic> slotDetails;
  final Map<String, RowAvailability> rows;

  ShedPositionResponse({
    required this.message,
    required this.shedId,
    required this.shedName,
    required this.supervisorName,
    required this.supervisorMobile,
    required this.totalPositions,
    this.cctvUrl,
    this.cctvUrl2,
    this.cctvUrl3,
    this.cctvUrl4,
    this.farmDetails,
    this.slotDetails = const {},
    required this.rows,
  });

  factory ShedPositionResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, RowAvailability> rows = {};
    json.forEach((key, value) {
      if (key.startsWith('R') && value is Map<String, dynamic>) {
        rows[key] = RowAvailability.fromJson(value);
      }
    });

    return ShedPositionResponse(
      message: json['message'] ?? '',
      shedId: json['shed_id'] ?? '',
      shedName: json['shed_name'] ?? '',
      supervisorName: json['supervisor_name'] ?? '',
      supervisorMobile: json['supervisor_mobile'] ?? '',
      totalPositions: json['total_positions'] is num
          ? (json['total_positions'] as num).toInt()
          : 0,
      cctvUrl: json['cctv_url'],
      cctvUrl2: json['cctv_url_2'],
      cctvUrl3: json['cctv_url_3'],
      cctvUrl4: json['cctv_url_4'],
      farmDetails: json['farm_details'],
      slotDetails: json['slot_details'] != null
          ? Map<String, dynamic>.from(json['slot_details'])
          : {},
      rows: rows,
    );
  }
}

class RowAvailability {
  final List<String> available;
  final List<String> filled;

  RowAvailability({required this.available, required this.filled});

  factory RowAvailability.fromJson(Map<String, dynamic> json) {
    return RowAvailability(
      available: List<String>.from(json['available'] ?? []),
      filled: List<String>.from(json['filled'] ?? []),
    );
  }
}
