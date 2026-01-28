/// Model for investor animal data from /api/investors/animals endpoint.
///
/// This model represents a simplified animal view for investors,
/// containing only the essential information they need to see.
class InvestorAnimal {
  /// Unique identifier for the animal
  final String animalId;

  /// List of image URLs for the animal
  final List<String> images;

  /// Name of the farm where the animal is located
  final String? farmName;

  /// Location of the farm (e.g., 'KURNOOL', 'HYDERABAD')
  final String? farmLocation;

  /// Current health status of the animal
  final String healthStatus;

  /// Creates an instance of [InvestorAnimal].
  const InvestorAnimal({
    required this.animalId,
    required this.images,
    this.farmName,
    this.farmLocation,
    required this.healthStatus,
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
    return InvestorAnimal(
      animalId: json['animal_id'] as String,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      farmName: json['farm_name'] as String?,
      farmLocation: json['farm_location'] as String?,
      healthStatus: json['health_status'] as String? ?? 'Unknown',
    );
  }

  /// Converts this [InvestorAnimal] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'images': images,
      'farm_name': farmName,
      'farm_location': farmLocation,
      'health_status': healthStatus,
    };
  }

  /// Creates a copy of this [InvestorAnimal] with the given fields replaced.
  InvestorAnimal copyWith({
    String? animalId,
    List<String>? images,
    String? farmName,
    String? farmLocation,
    String? healthStatus,
  }) {
    return InvestorAnimal(
      animalId: animalId ?? this.animalId,
      images: images ?? this.images,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      healthStatus: healthStatus ?? this.healthStatus,
    );
  }

  @override
  String toString() {
    return 'InvestorAnimal(animalId: $animalId, farmName: $farmName, '
        'farmLocation: $farmLocation, healthStatus: $healthStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvestorAnimal && other.animalId == animalId;
  }

  @override
  int get hashCode => animalId.hashCode;
}

/// Response model for /api/investors/animals endpoint.
class InvestorAnimalsResponse {
  /// Status of the response
  final String status;

  /// Number of animals returned
  final int count;

  /// List of investor animals
  final List<InvestorAnimal> data;

  /// Creates an instance of [InvestorAnimalsResponse].
  const InvestorAnimalsResponse({
    required this.status,
    required this.count,
    required this.data,
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
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
