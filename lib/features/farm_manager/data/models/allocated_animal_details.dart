class AllocatedAnimalDetails {
  final AnimalInfo animalDetails;
  final ShedInfo shedDetails;
  final FarmInfo farmDetails;
  final InvestorInfo investorDetails;
  final StaffInfo? farmManager;
  final StaffInfo? supervisor;

  AllocatedAnimalDetails({
    required this.animalDetails,
    required this.shedDetails,
    required this.farmDetails,
    required this.investorDetails,
    this.farmManager,
    this.supervisor,
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
    );
  }
}

class AnimalInfo {
  final int id;
  final String animalId;
  final String rfidTagNumber;
  final String? earTag;
  final String? breedName;
  final String? status;
  final int? rowNumber;
  final String? parkingId;
  final List<String> images;
  final String? onboardedAt;
  final String? dateOfCalving;

  AnimalInfo({
    required this.id,
    required this.animalId,
    required this.rfidTagNumber,
    this.earTag,
    this.breedName,
    this.status,
    this.rowNumber,
    this.parkingId,
    this.images = const [],
    this.onboardedAt,
    this.dateOfCalving,
  });

  factory AnimalInfo.fromJson(Map<String, dynamic> json) {
    int? parseRow(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) {
        return int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
      }
      return null;
    }

    return AnimalInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      animalId: json['animal_id'] ?? '',
      rfidTagNumber: json['rfid_tag_number'] ?? '',
      earTag: json['ear_tag'],
      breedName: json['breed_name'],
      status: json['status'],
      rowNumber: parseRow(json['row_number']),
      parkingId: json['parking_id'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      onboardedAt: json['onboarded_at'],
      dateOfCalving: json['date_of_calving'],
    );
  }
}

class ShedInfo {
  final int id;
  final String shedId;
  final String shedName;
  final int capacity;
  final int buffaloesCount;

  ShedInfo({
    required this.id,
    required this.shedId,
    required this.shedName,
    required this.capacity,
    required this.buffaloesCount,
  });

  factory ShedInfo.fromJson(Map<String, dynamic> json) {
    return ShedInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      shedId: json['shed_id'] ?? '',
      shedName: json['shed_name'] ?? '',
      capacity: json['capacity'] is num ? (json['capacity'] as num).toInt() : 0,
      buffaloesCount: json['buffaloes_count'] is num
          ? (json['buffaloes_count'] as num).toInt()
          : 0,
    );
  }
}

class FarmInfo {
  final int id;
  final String farmName;
  final String location;

  FarmInfo({required this.id, required this.farmName, required this.location});

  factory FarmInfo.fromJson(Map<String, dynamic> json) {
    return FarmInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      farmName: json['farm_name'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

class InvestorInfo {
  final int id;
  final String fullName;
  final String mobile;
  final String? email;

  InvestorInfo({
    required this.id,
    required this.fullName,
    required this.mobile,
    this.email,
  });

  factory InvestorInfo.fromJson(Map<String, dynamic> json) {
    return InvestorInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
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
