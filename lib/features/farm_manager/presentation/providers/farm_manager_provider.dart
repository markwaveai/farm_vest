import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/widgets/floating_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/farm_manager_dashboard_model.dart';

class FarmManagerDashboardNotifier extends Notifier<FarmManagerDashboardState> {
  final ImagePicker _picker = ImagePicker();

  @override
  FarmManagerDashboardState build() {
    _fetchDashboardData();
    return FarmManagerDashboardState(isLoading: true);
  }

  Future<void> _fetchDashboardData() async {
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      investorCount: 13,
      totalStaff: 24,
      pendingApprovals: 5,
      isLoading: false,
    );
  }

  void refreshDashboard() {
    state = state.copyWith(isLoading: true);
    _fetchDashboardData();
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

  Future<bool> onboardAnimal({
    required String shedId,
    required String rowId,
    required String dob,
    required String animalCartId,
    required String healthStatus,
    required String investorId,
    required String positionId,
    required String rfidTag,
    required String status,
  }) async {
    // Validate all fields
    if (shedId.isEmpty ||
        rowId.isEmpty ||
        dob.isEmpty ||
        animalCartId.isEmpty ||
        healthStatus.isEmpty ||
        investorId.isEmpty ||
        positionId.isEmpty ||
        rfidTag.isEmpty ||
        status.isEmpty) {
      return false;
    }

    final validImages = state.images
        .where((img) => img.networkUrl != null)
        .map((img) => img.networkUrl!)
        .toList();

    if (validImages.isEmpty) {
      if (state.images.any((img) => img.isUploading)) {
         return false;
      } else {
         return false;
      }
    }

    final payload = {
      "DOB": dob,
      "animal_cart_id": int.tryParse(animalCartId) ?? 0,
      "animal_type": "BUFFALO",
      "health_status": healthStatus,
      "images": validImages,
      "investor_id": int.tryParse(investorId) ?? 0,
      "position_id": positionId,
      "rfid_tag_number": rfidTag,
      "row_id": rowId,
      "shed_id": shedId,
      "status": status,
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final success = await ApiServices.onboardAnimal(payload, token!);

    if (success) {
      state = state.copyWith(images: []); // Clear images on success
      return true;
    } else {
      return false;
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
}

final farmManagerProvider =
    NotifierProvider<FarmManagerDashboardNotifier, FarmManagerDashboardState>(
  FarmManagerDashboardNotifier.new,
);
