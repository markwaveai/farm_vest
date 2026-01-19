import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/widgets/floating_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:farm_vest/core/services/api_services.dart';

// 1. Data Models (unchanged)
class SupervisorTask {
  final String title;
  final String subtitle;
  SupervisorTask(this.title, this.subtitle);
}

class HealthConcern {
  final String title;
  final String subtitle;
  HealthConcern(this.title, this.subtitle);
}

class SupervisorDashboardStats {
  final String totalAnimals;
  final String milkToday;
  final String activeIssues;
  final String transfers;

  SupervisorDashboardStats({
    required this.totalAnimals,
    required this.milkToday,
    required this.activeIssues,
    required this.transfers,
  });
}

class DashboardImage {
  final File? localFile;
  final String? networkUrl;
  final bool isUploading;
  final bool hasError;

  DashboardImage({
    this.localFile,
    this.networkUrl,
    this.isUploading = false,
    this.hasError = false,
  });
}

// 2. State Class - Now includes checklist state
class SupervisorDashboardState {
  final SupervisorDashboardStats stats;
  final List<SupervisorTask> tasks;
  final List<HealthConcern> healthConcerns;
  final bool isLoading;

  // Checklist state
  final bool morningFeed;
  final bool waterCleaning;
  final bool shedWash;
  final bool eveningMilking;

  // Image URLs
  final List<DashboardImage> images;

  SupervisorDashboardState({
    required this.stats,
    this.tasks = const [],
    this.healthConcerns = const [],
    this.isLoading = false,
    this.morningFeed = true,
    this.waterCleaning = true,
    this.shedWash = false,
    this.eveningMilking = false,
    this.images = const [],
  });

  SupervisorDashboardState copyWith({
    SupervisorDashboardStats? stats,
    List<SupervisorTask>? tasks,
    List<HealthConcern>? healthConcerns,
    bool? isLoading,
    bool? morningFeed,
    bool? waterCleaning,
    bool? shedWash,
    bool? eveningMilking,
    List<DashboardImage>? images,
  }) {
    return SupervisorDashboardState(
      stats: stats ?? this.stats,
      tasks: tasks ?? this.tasks,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      isLoading: isLoading ?? this.isLoading,
      morningFeed: morningFeed ?? this.morningFeed,
      waterCleaning: waterCleaning ?? this.waterCleaning,
      shedWash: shedWash ?? this.shedWash,
      eveningMilking: eveningMilking ?? this.eveningMilking,
      images: images ?? this.images,
    );
  }
}

// 3. Notifier - Now with methods to toggle checklist items
class SupervisorDashboardNotifier extends Notifier<SupervisorDashboardState> {
  final ImagePicker _picker = ImagePicker();
  @override
  SupervisorDashboardState build() {
    _fetchData();
    return SupervisorDashboardState(
      isLoading: true,
      stats: SupervisorDashboardStats(
        totalAnimals: '0',
        milkToday: '0L',
        activeIssues: '0',
        transfers: '0',
      ),
    );
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(seconds: 1));
    final newStats = SupervisorDashboardStats(
      totalAnimals: '142',
      milkToday: '0L',
      activeIssues: '5',
      transfers: '1',
    );
    state = state.copyWith(stats: newStats, isLoading: false);
  }

  // Methods to update checklist state
  void toggleMorningFeed(bool value) =>
      state = state.copyWith(morningFeed: value);
  void toggleWaterCleaning(bool value) =>
      state = state.copyWith(waterCleaning: value);
  void toggleShedWash(bool value) => state = state.copyWith(shedWash: value);
  void toggleEveningMilking(bool value) =>
      state = state.copyWith(eveningMilking: value);

  // Image picking methods
  Future<void> pickFromGallery() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages == null || pickedImages.isEmpty) return;

    // Add local images immediately with uploading state
    List<DashboardImage> newImages = pickedImages
        .map(
          (xFile) =>
              DashboardImage(localFile: File(xFile.path), isUploading: true),
        )
        .toList();

    state = state.copyWith(images: [...state.images, ...newImages]);

    // Upload images in background
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

    // Check if the image still exists in the list (user might have removed it)
    if (index >= state.images.length) return;

    // Ideally we should match by ID or object reference, but index is okay for now
    // assuming no reordering or race conditions with multiple removals.
    // To be safer, we can try to find the object in the current list.

    final currentList = List<DashboardImage>.from(state.images);
    // Find index of the specific object we added.
    // Since DashboardImage doesn't verify identity, strict equality check might fail if strict immutability isn't preserved?
    // Actually objects are new instances.

    // Let's rely on the fact that we appended them. But user might have deleted some.
    // A better way is to find the image by local path.
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
    required String shed,
    required String breed,
    required String row,
  }) async {
    // 1. Validate inputs
    if (shed.isEmpty || breed.isEmpty || row.isEmpty) {
      FloatingToast.showSimpleToast('Please fill all fields');
      return false;
    }

    final validImages = state.images
        .where((img) => img.networkUrl != null)
        .toList();

    if (validImages.isEmpty) {
      if (state.images.any((img) => img.isUploading)) {
        FloatingToast.showSimpleToast(
          'Please wait for image upload to complete',
        );
      } else {
        FloatingToast.showSimpleToast('Please upload an image');
      }
      return false;
    }

    state = state.copyWith(isLoading: true);

    // 2. Prepare payload
    // Assuming the API expects keys like 'shed', 'breed', 'row', 'image_url'
    // Sending the first image as the primary image_url.
    // If the API supports multiple, we can send the list.
    final payload = {
      'shed': shed,
      'breed': breed,
      'row': row,
      'imageUrl': validImages.first.networkUrl,
    };

    // 3. Call API
    final success = await ApiServices.onboardAnimal(payload);

    if (success) {
      state = state.copyWith(
        isLoading: false,
        images: [],
      ); // Clear images on success
      return true;
    } else {
      FloatingToast.showSimpleToast('Failed to onboard animal');
      state = state.copyWith(isLoading: false);
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

  // 4. Provider (unchanged)
}

final supervisorDashboardProvider =
    NotifierProvider<SupervisorDashboardNotifier, SupervisorDashboardState>(
      SupervisorDashboardNotifier.new,
    );
