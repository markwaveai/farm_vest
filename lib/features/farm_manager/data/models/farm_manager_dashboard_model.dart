import 'dart:io';
import 'animalkart_order_model.dart';
import 'shed_model.dart';

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

class FarmManagerDashboardState {
  final int investorCount;
  final int totalStaff;
  final int pendingApprovals;
  final bool isLoading;
  final String? error;
  final List<DashboardImage> images;
  final AnimalkartOrder? currentOrder;
  final List<dynamic> onboardedAnimalIds;
  final List<Shed> sheds;
  final ShedPositionResponse? currentShedAvailability;

  FarmManagerDashboardState({
    this.investorCount = 0,
    this.totalStaff = 0,
    this.pendingApprovals = 0,
    this.isLoading = false,
    this.error,
    this.images = const [],
    this.currentOrder,
    this.onboardedAnimalIds = const [],
    this.sheds = const [],
    this.currentShedAvailability,
  });

  FarmManagerDashboardState copyWith({
    int? investorCount,
    int? totalStaff,
    int? pendingApprovals,
    bool? isLoading,
    String? error,
    List<DashboardImage>? images,
    AnimalkartOrder? currentOrder,
    List<dynamic>? onboardedAnimalIds,
    List<Shed>? sheds,
    ShedPositionResponse? currentShedAvailability,
  }) {
    return FarmManagerDashboardState(
      investorCount: investorCount ?? this.investorCount,
      totalStaff: totalStaff ?? this.totalStaff,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      images: images ?? this.images,
      currentOrder: currentOrder ?? this.currentOrder,
      onboardedAnimalIds: onboardedAnimalIds ?? this.onboardedAnimalIds,
      sheds: sheds ?? this.sheds,
      currentShedAvailability:
          currentShedAvailability ?? this.currentShedAvailability,
    );
  }
}
