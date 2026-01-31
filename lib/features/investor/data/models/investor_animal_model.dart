import 'package:farm_vest/core/theme/app_constants.dart';

/// Model for investor animal data from /api/investors/animals endpoint.
///
/// This model represents a simplified animal view for investors,
/// containing only the essential information they need to see.
class InvestorAnimal {
  /// Unique identifier for the animal
  final String animalId;
  final String? rfid;
  final int? age;

  /// List of image URLs for the animal
  final List<String> images;
  final int? shedId;
  final String? shedName;
  final String? animalType;
  final String? breed;

  /// Name of the farm where the animal is located
  final String? farmName;

  /// Location of the farm (e.g., 'KURNOOL', 'HYDERABAD')
  final String? farmLocation;

  /// Current health status of the animal
  final String healthStatus;

  /// Date when the animal was onboarded
  final DateTime? onboardedAt;

  /// Creates an instance of [InvestorAnimal].
  const InvestorAnimal({
    required this.animalId,
    this.rfid,
    this.age,
    required this.shedName,
    required this.animalType,

    required this.images,
    this.farmName,
    this.farmLocation,
    required this.shedId,
    required this.healthStatus,
    this.breed,
    this.onboardedAt,
  });

  /// Creates an [InvestorAnimal] from JSON data.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "animal_id": "97c5bbd5-3ee7-4f0e-88ac-f82942b4a07e",
  ///   "images": ["https://..."],
  ///   "farm_name": "test uma",
  ///   "farm_location": "KURNOOL",
  ///   "health_status": "Healthy"
  /// }
  /// ```
  factory InvestorAnimal.fromJson(Map<String, dynamic> json) {
    // Check if data is nested or flat
    final bool isNested = json.containsKey('animal_details');

    final animalData = isNested ? json['animal_details'] : json;
    final farmData = isNested ? json['farm_details'] : json;
    final shedData = isNested ? json['shed_details'] : json;

    return InvestorAnimal(
      animalId: (animalData['animal_id'] ?? animalData['id']?.toString() ?? '')
          .toString(),
      rfid: (animalData['rfid_tag_number'] ?? animalData['rfid'] ?? '')
          .toString(),
      age: animalData['age_months'] is int ? animalData['age_months'] : null,
      images:
          (animalData['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      farmName: (farmData['farm_name'] ?? farmData['name'] ?? '').toString(),
      farmLocation: (farmData['location'] ?? farmData['farm_location'] ?? '')
          .toString(),
      shedId: shedData['id'] is int ? shedData['id'] : null,
      shedName: (shedData['shed_name'] ?? shedData['name'] ?? '').toString(),
      healthStatus: (animalData['health_status'] ?? kHyphen).toString(),
      animalType: (animalData['animal_type'] ?? 'Buffalo').toString(),
      breed: (animalData['breed_name'] ?? animalData['breed'] ?? 'Murrah')
          .toString(),
      onboardedAt: animalData['onboarded_at'] != null
          ? DateTime.tryParse(animalData['onboarded_at'].toString())
          : null,
    );
  }

  /// Converts this [InvestorAnimal] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'rfid': rfid,
      'age': age,
      'shed_name': shedName,
      'shed_id': shedId,
      'animal_id': animalId,
      'images': images,
      'farm_name': farmName,
      'farm_location': farmLocation,
      'health_status': healthStatus,
      'animal_type': animalType,
      'onboarded_at': onboardedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [InvestorAnimal] with the given fields replaced.
  InvestorAnimal copyWith({
    String? rfid,
    int? age,
    String? shedName,
    int? shedId,
    String? animalId,
    List<String>? images,
    String? farmName,
    String? farmLocation,
    String? healthStatus,
    String? animalType,
    DateTime? onboardedAt,
  }) {
    return InvestorAnimal(
      animalId: animalId ?? this.animalId,
      rfid: rfid ?? this.rfid,
      animalType: animalType ?? this.animalType,
      age: age ?? this.age,
      shedName: shedName ?? this.shedName,
      shedId: shedId ?? this.shedId,

      images: images ?? this.images,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      healthStatus: healthStatus ?? this.healthStatus,
      onboardedAt: onboardedAt ?? this.onboardedAt,
    );
  }

  @override
  String toString() {
    return 'InvestorAnimal(animalId: $animalId, farmName: $farmName, '
        'farmLocation: $farmLocation, healthStatus: $healthStatus)';
  }
  // String toString() {
  //   return 'InvestorAnimal(rfid: $rfid, age: $age, shedName: $shedId, '
  //       'farmName: $farmName, farmLocation: $farmLocation)';
  // }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvestorAnimal && other.animalId == animalId;
  }
  //  bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   return other is InvestorAnimal && other.rfid == rfid;
  // }

  @override
  int get hashCode => rfid.hashCode;
}

/// Response model for /api/investors/animals endpoint.
class InvestorAnimalsResponse {
  /// Status of the response
  final String status;

  /// Number of animals returned
  final int count;

  /// List of investor animals
  final List<InvestorAnimal> data;

  /// Parent animal information (if applicable, e.g., from get_calves)
  final String? parentAnimalId;
  final String? parentRfid;

  /// Creates an instance of [InvestorAnimalsResponse].
  const InvestorAnimalsResponse({
    required this.status,
    required this.count,
    required this.data,
    this.parentAnimalId,
    this.parentRfid,
  });

  /// Creates an [InvestorAnimalsResponse] from JSON data.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "count": 2,
  ///   "data": [...]
  /// }
  /// ```
  factory InvestorAnimalsResponse.fromJson(Map<String, dynamic> json) {
    return InvestorAnimalsResponse(
      status: json['status'] as String? ?? 'success',
      count: json['count'] as int? ?? 0,
      parentAnimalId: json['parent_animal_id']?.toString(),
      parentRfid: json['parent_rfid']?.toString(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => InvestorAnimal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Converts this [InvestorAnimalsResponse] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'parent_animal_id': parentAnimalId,
      'parent_rfid': parentRfid,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
