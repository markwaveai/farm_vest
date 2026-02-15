class AllocatedAnimalDetails {
  final AnimalInfo animalDetails;
  final ShedInfo shedDetails;
  final FarmInfo farmDetails;
  final InvestorInfo investorDetails;
  final StaffInfo? farmManager;
  final StaffInfo? supervisor;
  final StaffInfo? doctor;
  final StaffInfo? assistantDoctor;

  AllocatedAnimalDetails({
    required this.animalDetails,
    required this.shedDetails,
    required this.farmDetails,
    required this.investorDetails,
    this.farmManager,
    this.supervisor,
    this.doctor,
    this.assistantDoctor,
  });

  factory AllocatedAnimalDetails.fromJson(Map<String, dynamic> json) {
    return AllocatedAnimalDetails(
      animalDetails: AnimalInfo.fromJson(json['animal_details'] ?? {}),
      shedDetails: ShedInfo.fromJson(json['shed_details'] ?? {}),
      farmDetails: FarmInfo.fromJson(json['farm_details'] ?? {}),
      investorDetails: InvestorInfo.fromJson(json['investor_details'] ?? {}),
      farmManager: json['farm_manager'] != null
          ? StaffInfo.fromJson(json['farm_manager'])
          : null,
      supervisor: json['supervisor'] != null
          ? StaffInfo.fromJson(json['supervisor'])
          : null,
      doctor: json['doctor'] != null
          ? StaffInfo.fromJson(json['doctor'])
          : null,
      assistantDoctor: json['assistant_doctor'] != null
          ? StaffInfo.fromJson(json['assistant_doctor'])
          : null,
    );
  }
}

class AnimalInfo {
  final int animalId;
  final String rfidTagNumber;
  final String? earTag;
  final String? breedName;
  final String? status;
  final String? healthStatus;
  final int? ageMonths;
  final String? rowNumber;
  final String? parkingId;
  final List<String> images;
  final String? onboardedAt;
  final String? dateOfCalving;

  AnimalInfo({
    required this.animalId,
    required this.rfidTagNumber,
    this.earTag,
    this.breedName,
    this.status,
    this.healthStatus,
    this.ageMonths,
    this.rowNumber,
    this.parkingId,
    this.images = const [],
    this.onboardedAt,
    this.dateOfCalving,
  });

  factory AnimalInfo.fromJson(Map<String, dynamic> json) {
    return AnimalInfo(
      animalId: json['animal_id'] is num
          ? (json['animal_id'] as num).toInt()
          : 0,
      rfidTagNumber: json['rfid_tag_number'] ?? '',
      earTag: json['ear_tag'],
      breedName: json['breed_name'],
      status: json['status'],
      healthStatus: json['health_status'],
      ageMonths: json['age_months'] is num
          ? (json['age_months'] as num).toInt()
          : null,
      rowNumber: json['row_number']?.toString(),
      parkingId: json['parking_id'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      onboardedAt: json['onboarded_at'],
      dateOfCalving: json['date_of_calving'],
    );
  }
}

class ShedInfo {
  final int shedId;
  final String shedName;
  final int capacity;
  final int buffaloesCount;

  ShedInfo({
    required this.shedId,
    required this.shedName,
    required this.capacity,
    required this.buffaloesCount,
  });

  factory ShedInfo.fromJson(Map<String, dynamic> json) {
    return ShedInfo(
      shedId: json['shed_id'] is num ? (json['shed_id'] as num).toInt() : 0,
      shedName: json['shed_name'] ?? '',
      capacity: json['capacity'] is num ? (json['capacity'] as num).toInt() : 0,
      buffaloesCount: json['buffaloes_count'] is num
          ? (json['buffaloes_count'] as num).toInt()
          : 0,
    );
  }
}

class FarmInfo {
  final int farmId;
  final String farmName;
  final String location;

  FarmInfo({
    required this.farmId,
    required this.farmName,
    required this.location,
  });

  factory FarmInfo.fromJson(Map<String, dynamic> json) {
    return FarmInfo(
      farmId: json['farm_id'] is num ? (json['farm_id'] as num).toInt() : 0,
      farmName: json['farm_name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

class InvestorInfo {
  final int investorId;
  final String fullName;
  final String mobile;
  final String? email;

  InvestorInfo({
    required this.investorId,
    required this.fullName,
    required this.mobile,
    this.email,
  });

  factory InvestorInfo.fromJson(Map<String, dynamic> json) {
    return InvestorInfo(
      investorId: json['investor_id'] is num
          ? (json['investor_id'] as num).toInt()
          : 0,
      fullName: json['full_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
    );
  }
}

class StaffInfo {
  final int userId;
  final String fullName;
  final String mobile;

  StaffInfo({
    required this.userId,
    required this.fullName,
    required this.mobile,
  });

  factory StaffInfo.fromJson(Map<String, dynamic> json) {
    return StaffInfo(
      userId: json['user_id'] is num ? (json['user_id'] as num).toInt() : 0,
      fullName: json['full_name'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}
