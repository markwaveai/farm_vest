import 'farm_manager_dashboard_model.dart';

class AnimalOnboardingEntry {
  String animalId;
  String rfidTag;
  String earTag;
  String neckbandId;
  String dob;
  int ageMonths;
  String healthStatus;
  String status;
  String type; // 'BUFFALO' or 'CALF'
  String breedId;
  String breedName;
  String parentAnimalId;
  List<DashboardImage> images;

  AnimalOnboardingEntry({
    this.animalId = '',
    required this.rfidTag,
    required this.earTag,
    this.neckbandId = '',
    required this.dob,
    this.ageMonths = 0,
    required this.healthStatus,
    this.status = '',
    required this.type,
    this.breedId = '',
    this.breedName = '',
    this.parentAnimalId = '',
    List<DashboardImage>? images,
  }) : images = images ?? [];

  AnimalOnboardingEntry copyWith({
    String? animalId,
    String? rfidTag,
    String? earTag,
    String? neckbandId,
    String? dob,
    int? ageMonths,
    String? healthStatus,
    String? status,
    String? type,
    String? breedId,
    String? breedName,
    String? parentAnimalId,
    List<DashboardImage>? images,
  }) {
    return AnimalOnboardingEntry(
      animalId: animalId ?? this.animalId,
      rfidTag: rfidTag ?? this.rfidTag,
      earTag: earTag ?? this.earTag,
      neckbandId: neckbandId ?? this.neckbandId,
      dob: dob ?? this.dob,
      ageMonths: ageMonths ?? this.ageMonths,
      healthStatus: healthStatus ?? this.healthStatus,
      status: status ?? this.status,
      type: type ?? this.type,
      breedId: breedId ?? this.breedId,
      breedName: breedName ?? this.breedName,
      parentAnimalId: parentAnimalId ?? this.parentAnimalId,
      images: images ?? this.images,
    );
  }
}
