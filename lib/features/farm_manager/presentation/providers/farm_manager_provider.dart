import 'package:farm_vest/core/services/employee_api_services.dart';
import 'package:farm_vest/core/utils/image_helper_compressor.dart';
import 'package:farm_vest/core/services/investor_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/services/farms_api_services.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_model.dart';
import 'package:farm_vest/core/services/tickets_api_services.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:async';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/animalkart_order_model.dart';
import '../../data/models/farm_manager_dashboard_model.dart';
import '../../data/models/animal_onboarding_entry.dart';
import '../../data/models/shed_model.dart';

class FarmManagerDashboardNotifier extends Notifier<FarmManagerDashboardState> {
  final ImagePicker _picker = ImagePicker();

  Timer? _refreshTimer;

  @override
  FarmManagerDashboardState build() {
    // Start periodic auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchDashboardData(isAutoRefresh: true);
    });

    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    _fetchDashboardData();
    return FarmManagerDashboardState(isLoading: true);
  }

  Future<void> _fetchDashboardData({bool isAutoRefresh = false}) async {
    final authState = ref.read(authProvider);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      state = state.copyWith(error: 'Session expired', isLoading: false);
      return;
    }

    // Set initial loading state but keep previous data if any
    if (!isAutoRefresh) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      int investorCount = state.investorCount;
      int totalStaff = state.totalStaff;
      List<Shed> sheds = state.sheds;
      List<Farm> farms = state.farms;
      List<dynamic> onboardedAnimals = state.onboardedAnimalIds;

      // 1. Fetch Investors
      try {
        final investors = await InvestorApiServices.getAllInvestors(
          token: token,
        );
        investorCount = investors.length;
      } catch (e) {
        debugPrint("Error fetching investors: $e");
      }

      // 2. Fetch Staff Count
      try {
        final employeesData = await EmployeeApiServices.getEmployees(
          token: token,
        );
        totalStaff = employeesData.length;
      } catch (e) {
        debugPrint("Error fetching employees: $e");
      }

      // 3. Fetch Sheds & Unallocated Animals
      final farmIdStr = authState.userData?.farmId;
      final farmId = (farmIdStr != null && farmIdStr.isNotEmpty)
          ? int.tryParse(farmIdStr)
          : null;

      final roleStr = authState.userData?.role;
      final isFM = roleStr == 'FARM_MANAGER' || roleStr == 'SUPERVISOR';

      if (farmId != null || isFM) {
        try {
          final shedResponse = await ShedsApiServices.getShedList(
            token: token,
            farmId: farmId,
            page: 1,
          );
          sheds = shedResponse.data;

          final pagination = shedResponse.pagination;
          state = state.copyWith(
            currentShedPage: pagination.currentPage,
            totalShedPages: pagination.totalPages,
            hasMoreSheds: pagination.currentPage < pagination.totalPages,
          );
        } catch (e) {
          debugPrint("Error fetching sheds: $e");
        }

        try {
          onboardedAnimals = await ShedsApiServices.getUnallocatedAnimals(
            token: token,
            farmId: farmId,
          );
        } catch (e) {
          debugPrint("Error fetching unallocated animals: $e");
        }
      }

      // 4. Fetch All Farms
      try {
        farms = await FarmsApiServices.getFarms(token: token);
      } catch (e) {
        debugPrint("Error fetching farms: $e");
      }

      state = state.copyWith(
        investorCount: investorCount,
        totalStaff: totalStaff,
        sheds: sheds,
        farms: farms,
        onboardedAnimalIds: onboardedAnimals,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      debugPrint("Global dashboard error: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true);
    await _fetchDashboardData();
  }

  Future<void> pickFromGallery() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages == null || pickedImages.isEmpty) return;

    List<DashboardImage> newImages = [];
    for (var xFile in pickedImages) {
      File file = File(xFile.path);
      try {
        file = await ImageCompressionHelper.getCompressedImageIfNeeded(
          file,
          isDocument: false,
        );
      } catch (e) {
        debugPrint("Compression error: $e");
      }
      newImages.add(DashboardImage(localFile: file, isUploading: true));
    }

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

    File file = File(pickedImage.path);
    try {
      file = await ImageCompressionHelper.getCompressedImageIfNeeded(
        file,
        isDocument: false,
      );
    } catch (e) {
      debugPrint("Compression error: $e");
    }

    final newImage = DashboardImage(localFile: file, isUploading: true);

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
    int? farmId, // Optional farm_id for specific farm selection
    bool isCpfPaid = true,
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
      String dateOfBirth = animal.dob;
      if (dateOfBirth.trim().isEmpty && animal.ageMonths > 0) {
        final now = DateTime.now();
        final approximateDob = now.subtract(
          Duration(days: (animal.ageMonths * 30.44).round()),
        );
        dateOfBirth =
            "${approximateDob.year}-${approximateDob.month.toString().padLeft(2, '0')}-${approximateDob.day.toString().padLeft(2, '0')}";
      }

      final animalData = {
        "animal_type": animal.type,
        "rfid_tag": animal.rfidTag.startsWith('RFID-')
            ? animal.rfidTag
            : 'RFID-${animal.rfidTag}',
        "ear_tag": animal.earTag.startsWith('ET-')
            ? animal.earTag
            : 'ET-${animal.earTag}',
        "age_months": animal.ageMonths,
        "age": (animal.ageMonths / 12).floor(),
        "date_of_birth": dateOfBirth.isNotEmpty ? dateOfBirth : null,
        "health_status": animal.healthStatus.toUpperCase(),
        "images": imageUrls,
        "row_number": "",
        "parking_id": "",
        "neckband_id": animal.neckbandId,
      };

      if (animal.type == 'BUFFALO') {
        animalData["tag_number"] =
            int.tryParse(animal.tagNumber.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
        animalData["status"] = animal.status;
        animalData["breed_id"] = animal.breedId.isNotEmpty
            ? animal.breedId
            : '';
        animalData["breed_name"] = animal.breedName;
        animalData["animalkart_buffalo_id"] = animal.animalId.toString();
      } else if (animal.type == 'CALF') {
        animalData["parent_animal_id"] = animal.parentAnimalId;
        animalData["tag_number"] = 0; // Default tag number for calves
      }

      return animalData;
    }).toList();

    final payload = {
      "investor_details": {
        "investor_id": order.investor.id.toString(),
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
        "animalkart_order_id": order.order.id.toString(),
        "is_cpf_paid": isCpfPaid,
        "order_date": order.order.placedAt,
        "total_investment_amount": order.order.totalCost,
        "unit_cost": unitCost,
        "number_of_units": numUnits,
        "payment_method": order.transaction.paymentType,
        "bank_name": "", // Hardcoded per example/requirement if not in data
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
        final mobile = prefs.getString('mobile_number') ?? "";

        // Extract animalkart_buffalo_id for AnimalKart update from response['data']
        final responseData = response['data'] as List<dynamic>? ?? [];
        final kartBuffaloIds = responseData
            .where(
              (e) =>
                  e['animal_type'] == 'BUFFALO' &&
                  e['animalkart_buffalo_id'] != null,
            )
            .map((e) => e['animalkart_buffalo_id'])
            .toList();

        // If data is present, use our filtered list (even if empty, meaning no buffaloes).
        // Fallback to onboarded_animal_ids only if data is missing (legacy support).
        final idsToUpdate = responseData.isNotEmpty
            ? kartBuffaloIds
            : List<dynamic>.from(response['onboarded_animal_ids'] ?? []);

        // Notify AnimalKart of successful onboarding
        ApiServices.updateOnboardingStatus(
          orderId: order.order.id,
          status: "DELIVERED",
          buffaloIds: idsToUpdate,
          // adminMobile: order.investor.mobile,
        );

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
          final ids = List<int>.from(response['onboarded_animal_ids']);
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
    required String rowNumber,
    required String animalId,
    required String parkingId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      state = state.copyWith(error: 'Session expired. Please login again.');
      return false;
    }

    try {
      final success = await ShedsApiServices.allocateAnimals(
        shedId: shedId,
        rowNumber: rowNumber,
        animalId: animalId,
        parkingId: parkingId,
        token: token,
      );

      if (success) {
        // Remove only the allocated animal from the list
        final remainingAnimals = state.onboardedAnimalIds.where((animal) {
          final id = (animal is Map)
              ? (animal['rfid_tag'] ??
                    animal['rfid'] ??
                    animal['rfid_tag_number'] ??
                    animal['animal_id'])
              : animal.toString();
          return id.toString() != animalId;
        }).toList();

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

  Future<void> fetchSheds({int? farmId, bool refresh = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentShedPage: 1,
        sheds: [],
        hasMoreSheds: false,
      );
    } else {
      if (!state.hasMoreSheds || state.isLoadingMoreSheds) return;
      state = state.copyWith(isLoadingMoreSheds: true);
    }

    try {
      final page = refresh ? 1 : state.currentShedPage + 1;
      final shedResponse = await ShedsApiServices.getShedList(
        token: token,
        farmId: farmId,
        page: page,
      );

      final newSheds = shedResponse.data;
      final pagination = shedResponse.pagination;

      state = state.copyWith(
        sheds: refresh ? newSheds : [...state.sheds, ...newSheds],
        currentShedPage: pagination.currentPage,
        totalShedPages: pagination.totalPages,
        hasMoreSheds: pagination.currentPage < pagination.totalPages,
        isLoading: false,
        isLoadingMoreSheds: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingMoreSheds: false,
      );
    }
  }

  Future<void> fetchMoreSheds({int? farmId}) async {
    await fetchSheds(farmId: farmId, refresh: false);
  }

  Future<void> fetchFarms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    try {
      final farms = await FarmsApiServices.getFarms(token: token);
      state = state.copyWith(farms: farms, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
    state = state.copyWith(clearCurrentOrder: true);
  }

  Future<List<Map<String, dynamic>>> getPendingTransfers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception("Authentication token not found");

    final response = await TicketsApiServices.getTickets(
      token: token,
      status: 'PENDING',
      ticketType: 'TRANSFER',
      // transferDirection: 'IN', // Or filter by logic? Logic is in backend.
    );
    // getTickets returns List<Ticket>. Convert to List<Map<String, dynamic>> for UI or change UI to use Ticket model.
    // The previous code cast response as List<dynamic> which is wrong if getTickets returns List<Ticket>.
    return response.map((t) => t.toJson()).toList();
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
