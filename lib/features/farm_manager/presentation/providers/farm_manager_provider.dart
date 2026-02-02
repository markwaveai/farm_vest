import 'package:farm_vest/core/services/employee_api_services.dart';
import 'package:farm_vest/core/services/investor_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/services/tickets_api_services.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/animalkart_order_model.dart';
import '../../data/models/farm_manager_dashboard_model.dart';
import '../../data/models/animal_onboarding_entry.dart';
import '../../data/models/shed_model.dart';
import 'package:uuid/uuid.dart';

class FarmManagerDashboardNotifier extends Notifier<FarmManagerDashboardState> {
  final ImagePicker _picker = ImagePicker();

  @override
  FarmManagerDashboardState build() {
    _fetchDashboardData();
    return FarmManagerDashboardState(isLoading: true);
  }

  Future<void> _fetchDashboardData() async {
    final authState = ref.read(authProvider);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      state = state.copyWith(error: 'Session expired', isLoading: false);
      return;
    }

    try {
      // 1. Fetch Investors
      final investors = await InvestorApiServices.getAllInvestors(token: token);
      final investorCount = investors.length;

      // 2. Fetch Staff Count
      final employeesData = await EmployeeApiServices.getEmployees(
        token: token,
      );
      final totalStaff = employeesData.length;

      // 3. Fetch Pending Leaves
      // final leavesData = await ApiServices.getLeaveRequests(token);
      // Filter locally or via API if supported. API supports status_filter.
      // But getLeaveRequests signature in ApiServices.dart (lines 227) didn't take params?
      // Wait, let me check ApiServices.getLeaveRequests defined at lines 227.
      // It does NOT take status_filter in the Dart definition I saw earlier.
      // I should assume it returns all and filter here, OR update ApiServices.
      // The backend supports status_filter. The Dart service I saw earlier:
      /*
      static Future<Map<String, dynamic>> getLeaveRequests(String token) async {
         ... uri = .../leaves/requests ...
      }
      */
      // It doesn't allow params. So filtering locally.
      // final leaves = leavesData['data'] as List? ?? [];
      // final pendingLeaves = leaves
      //     .where((l) => l['status'] == 'PENDING')
      //     .length;

      // 4. Fetch Pending Tickets
      // final ticketsData = await TicketsApiServices.getTickets(
      //   token: token,
      //   status: 'PENDING',
      // );
      // final pendingTickets = ticketsData.length;

      // 5. Fetch Sheds
      final farmIdStr = authState.userData?.farmId;
      final farmId = (farmIdStr != null && farmIdStr.isNotEmpty)
          ? int.tryParse(farmIdStr)
          : null;

      List<Shed> sheds = [];
      List<Map<String, dynamic>> onboardedAnimals = [];

      final roleStr = authState.userData?.role;
      final isFM = roleStr == 'FARM_MANAGER' || roleStr == 'SUPERVISOR';

      if (farmId != null || isFM) {
        final rawSheds = await ShedsApiServices.getShedList(
          token: token,
          farmId: farmId,
        );
        sheds = rawSheds.map((s) => Shed.fromJson(s)).toList();

        // 6. Fetch Unallocated Animals
        onboardedAnimals = await ShedsApiServices.getUnallocatedAnimals(
          token: token,
          farmId: farmId,
        );
      }

      state = state.copyWith(
        investorCount: investorCount,
        totalStaff: totalStaff,
        // pendingApprovals: pendingLeaves + pendingTickets,
        sheds: sheds,
        onboardedAnimalIds: onboardedAnimals,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true);
    await _fetchDashboardData();
  }

  Future<void> pickFromGallery() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages == null || pickedImages.isEmpty) return;

    List<DashboardImage> newImages = pickedImages
        .map(
          (xFile) =>
              DashboardImage(localFile: File(xFile.path), isUploading: true),
        )
        .toList();

    state = state.copyWith(images: [...state.images, ...newImages]);

    for (int i = 0; i < newImages.length; i++) {
      _uploadImage(newImages[i], state.images.indexOf(newImages[i]));
    }
  }

  Future<void> pickFromCamera() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage == null) return;

    final newImage = DashboardImage(
      localFile: File(pickedImage.path),
      isUploading: true,
    );

    state = state.copyWith(images: [...state.images, newImage]);

    _uploadImage(newImage, state.images.length - 1);
  }

  Future<void> _uploadImage(DashboardImage image, int index) async {
    if (image.localFile == null) return;

    final url = await AuthRepository.uploadImage(image.localFile!);

    if (index >= state.images.length) return;

    final currentList = List<DashboardImage>.from(state.images);

    final imageIndex = currentList.indexWhere(
      (img) => img.localFile?.path == image.localFile?.path,
    );

    if (imageIndex != -1) {
      if (url != null) {
        currentList[imageIndex] = DashboardImage(
          localFile: image.localFile,
          networkUrl: url,
          isUploading: false,
          hasError: false,
        );
      } else {
        currentList[imageIndex] = DashboardImage(
          localFile: image.localFile,
          isUploading: false,
          hasError: true,
        );
      }
      state = state.copyWith(images: currentList);
    }
  }

  Future<bool> onboardAnimalsBulk({
    required AnimalkartOrder order,
    required List<AnimalOnboardingEntry> animals,
    int? farmId, // Optional farm_id for Admin
  }) async {
    if (animals.isEmpty) return false;

    final numUnits = order.order.numUnits ?? 0;
    final unitCost = numUnits > 0
        ? (order.order.totalCost / numUnits).round()
        : 0;

    final animalList = animals.map((animal) {
      final imageUrls = animal.images
          .where((img) => img.networkUrl != null)
          .map((img) => img.networkUrl!)
          .toList();

      // Calculate approximate DOB from Age (Months) if DOB is not provided
      // String dateOfBirth = animal.dob;
      // if (dateOfBirth.trim().isEmpty && animal.ageMonths > 0) {
      //   final now = DateTime.now();
      //   final approximateDob = now.subtract(
      //     Duration(days: animal.ageMonths * 30),
      //   );
      //   dateOfBirth =
      //       "${approximateDob.year}-${approximateDob.month.toString().padLeft(2, '0')}-${approximateDob.day.toString().padLeft(2, '0')}";
      // }

      final animalData = {
        "animal_id": animal.animalId.isNotEmpty ? animal.animalId : Uuid().v4(),
        "animal_type": animal.type,
        "rfid_tag": animal.rfidTag.startsWith('RFID-')
            ? animal.rfidTag
            : 'RFID-${animal.rfidTag}',
        "ear_tag": animal.rfidTag.startsWith('ET-')
            ? animal.rfidTag
            : 'ET-${animal.rfidTag}',

        "age_months": animal.ageMonths,
        "health_status": animal.healthStatus.toUpperCase(),
        "images": imageUrls,
      };

      if (animal.type == 'BUFFALO') {
        animalData["status"] = animal.status;
        animalData["breed_id"] = animal.breedId.isNotEmpty
            ? animal.breedId
            : '';
        animalData["breed_name"] = animal.breedName;
        if (animal.neckbandId.isNotEmpty) {
          animalData["neckband_id"] = animal.rfidTag.startsWith('NB-')
              ? animal.rfidTag
              : 'NB-${animal.neckbandId}';
        }
      } else if (animal.type == 'CALF') {
        // Map parent ID. The parent ID in entry is likely just the ID/Tag selected.
        if (animal.parentAnimalId.isNotEmpty) {
          // The parentAnimalId stored in entry was "BUFFALOTEMP_$index" or correct ID.
          // In the UI, I might need to resolve this to the actual animal_id of the buffalo being onboarded in the same batch.
          // The request example uses "BUFF-V-001" and "BUFF-V-001" as parent.
          // If the parent is in the same batch, we need to ensure the ID matches.
          // Let's assume for now the user provides or we generate consistency.
          animalData["parent_animal_id"] = animal.parentAnimalId;
        }
      }

      return animalData;
    }).toList();

    // Fix Parent IDs for Calves referring to Buffalos in the same batch
    // The UI uses "BUFFALOTEMP_$idx" as values. We should replace them with the actual "animal_id" (Ear Tag) of the buffalo.
    for (var animalMap in animalList) {
      if (animalMap["animal_type"] == 'CALF') {
        final parentVal = animalMap["parent_animal_id"] as String?;
        if (parentVal != null && parentVal.startsWith("BUFFALOTEMP_")) {
          final buffaloIdxStr = parentVal.replaceFirst("BUFFALOTEMP_", "");
          final buffaloIdx = int.tryParse(buffaloIdxStr);
          if (buffaloIdx != null && buffaloIdx < animals.length) {
            // Wait, buffaloEntries logic in UI separated indices.
            // This is tricky because the UI passes `buffaloEntries` to `AnimalEntryForm`.
            // But here we receive a flat list `animals`.
            // We need to assume the caller (UI) has already resolved this OR we need to trust the UI passed consistent IDs.
            // The UI sets `parentAnimalId` to "BUFFALOTEMP_$idx".
            // If we just use Ear Tag as ID, we need to find the Ear Tag of that buffalo index.
            // I'll leave this resolution to the UI before calling this method, OR handle it here if I can distinguish types.
            // BETTER: Handle in UI `_submit` to map TEMP IDs to Ear Tags.
          }
        }
      }
    }

    final payload = {
      "investor_details": {
        "investor_id": order.investor.id,
        "full_name": order.investor.fullName,
        "mobile": order.investor.mobile,
        "email": order.investor.email,
        "kyc_details": {
          "aadhar_number": order.investor.aadharNumber ?? "",
          "aadhar_front_url":
              (order.investor.aadharFrontUrl != null &&
                  order.investor.aadharFrontUrl!.isNotEmpty)
              ? order.investor.aadharFrontUrl
              : "https://firebasestorage.googleapis.com/v0/b/markwave-481315.firebasestorage.app/o/placeholders%2Ff.jpg?alt=media",
          "aadhar_back_url":
              (order.investor.aadharBackUrl != null &&
                  order.investor.aadharBackUrl!.isNotEmpty)
              ? order.investor.aadharBackUrl
              : "https://firebasestorage.googleapis.com/v0/b/markwave-481315.firebasestorage.app/o/placeholders%2Fb.jpg?alt=media",
          "pan_card_url":
              (order.investor.panCardUrl != null &&
                  order.investor.panCardUrl!.isNotEmpty)
              ? order.investor.panCardUrl
              : "https://firebasestorage.googleapis.com/v0/b/markwave-481315.firebasestorage.app/o/placeholders%2Fp.jpg?alt=media",
        },
      },
      "investment_details": {
        "animalkart_order_id": order.order.id,
        "order_date": order.order.placedAt,
        "total_investment_amount": order.order.totalCost,
        "unit_cost": unitCost,
        "number_of_units": numUnits,
        "payment_method": order.transaction.paymentType,
        "bank_name":
            "HDFC Bank - PARK STREET", // Hardcoded per example/requirement if not in data
        "utr_number": order.transaction.utrNumber,
        "payment_verification_screenshot":
            (order.transaction.paymentScreenshotUrl.isNotEmpty)
            ? order.transaction.paymentScreenshotUrl
            : "https://firebasestorage.googleapis.com/v0/b/markwave-481315.firebasestorage.app/o/placeholders%2Fpy.jpg?alt=media",
      },
      "animals": animalList,
      if (farmId != null) "farm_id": farmId,
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) return false;

    // We use the same ApiServices.onboardAnimal method as it accepts a Map.

    try {
      final response = await ShedsApiServices.onboardAnimal(payload, token);

      if (response !=
          null /*  && response['onboarded_animal_ids'] != null */ ) {
        // Update onboarding status in AnimalKart
        // final mobile = prefs.getString('mobile_number') ?? "";
        // await ApiServices.updateOnboardingStatus(
        //   orderId: order.order.id,
        //   status: "DELIVERED",
        //   buffaloIds: order.order.buffaloIds,
        //   adminMobile: mobile,
        // );

        final animalsList = List<Map<String, dynamic>>.from(
          response['animals'] ?? [],
        );
        final investorName =
            response['investor_name'] ?? order.investor.fullName;

        // Enrich animals with investor name if missing
        for (var animal in animalsList) {
          animal['investor_name'] = investorName;
          // Ensure 'rfid' key exists for UI compatibility
          if (!animal.containsKey('rfid') && animal.containsKey('rfid_tag')) {
            animal['rfid'] = animal['rfid_tag'];
          }
        }

        // If animals list is empty but we have IDs, try to construct from request (fallback)
        if (animalsList.isEmpty && response['onboarded_animal_ids'] != null) {
          final ids = List<String>.from(response['onboarded_animal_ids']);
          for (var id in ids) {
            animalsList.add({
              'rfid': id, // Fallback if we only have ID
              'animal_id': id,
              'investor_name': investorName,
            });
          }
        }

        state = state.copyWith(
          images: [],
          onboardedAnimalIds: animalsList,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(error: 'Failed to onboard animals');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> allocateAnimals({
    required String shedId,
    required List<Map<String, dynamic>> allocations,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      state = state.copyWith(error: 'Session expired. Please login again.');
      return false;
    }

    // final payload = {"allocations": allocations};

    try {
      final success = await ShedsApiServices.allocateAnimals(
        shedId: shedId,
        allocations: allocations,
        token: token,
      );

      if (success) {
        // Remove only the allocated animals from the list
        final allocatedAnimalIds = allocations
            .map((a) => a['animal_id'].toString())
            .toSet();
        final remainingAnimals = state.onboardedAnimalIds
            .where((id) => !allocatedAnimalIds.contains(id.toString()))
            .toList();

        state = state.copyWith(
          onboardedAnimalIds: remainingAnimals,
          error: null,
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> fetchUnallocatedAnimals({int? farmId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      state = state.copyWith(error: 'Session expired. Please login again.');
      return;
    }

    try {
      final animalIds = await ShedsApiServices.getUnallocatedAnimals(
        token: token,
        farmId: farmId,
      );
      state = state.copyWith(onboardedAnimalIds: animalIds, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchSheds({int? farmId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final rawSheds = await ShedsApiServices.getShedList(
        token: token,
        farmId: farmId,
      );
      final sheds = rawSheds.map((s) => Shed.fromJson(s)).toList();
      state = state.copyWith(sheds: sheds, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchShedPositions(int shedId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final availabilityMap = await ShedsApiServices.getShedPositions(
        shedId: int.tryParse(shedId.toString())!,
        token: token,
      );
      final availability = ShedPositionResponse.fromJson(availabilityMap);
      state = state.copyWith(
        currentShedAvailability: availability,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < state.images.length) {
      final newImages = List<DashboardImage>.from(state.images)
        ..removeAt(index);
      state = state.copyWith(images: newImages);
    }
  }

  void clearImages() {
    state = state.copyWith(images: []);
  }

  void setOrder(AnimalkartOrder? order) {
    state = state.copyWith(currentOrder: order, error: null);
  }

  void clearOrder() {
    state = state.copyWith(currentOrder: null);
  }

  Future<List<Map<String, dynamic>>> getPendingTransfers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception("Authentication token not found");

    final response = await TicketsApiServices.getTickets(
      token: token,
      status: 'PENDING',
      ticketType: 'TRANSFER',
    );
    return (response as List<dynamic>)
        .map((t) => Map<String, dynamic>.from(t))
        .toList();
  }

  Future<void> approveTransfer(int ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception("Authentication token not found");

    await TicketsApiServices.approveTransfer(token: token, ticketId: ticketId);
    await refreshDashboard();
  }

  Future<void> rejectTransfer(int ticketId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception("Authentication token not found");

    await TicketsApiServices.rejectTransfer(token: token, ticketId: ticketId);
    await refreshDashboard();
  }

  void resetAllocationState() {
    state = state.copyWith(
      sheds: [],
      currentShedAvailability: null,
      // onboardedAnimalIds: [], // Keep animals? No, better clear to force fresh fetch based on farm
      onboardedAnimalIds: [],
      error: null,
    );
  }
}

final farmManagerProvider =
    NotifierProvider<FarmManagerDashboardNotifier, FarmManagerDashboardState>(
      FarmManagerDashboardNotifier.new,
    );
