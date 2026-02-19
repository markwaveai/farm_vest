import 'dart:io';
import 'animalkart_order_model.dart';
import 'shed_model.dart';
import 'farm_model.dart';

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
  final List<Farm> farms;
  final ShedPositionResponse? currentShedAvailability;

  // Pagination fields for Sheds
  final int currentShedPage;
  final int totalShedPages;
  final bool hasMoreSheds;
  final bool isLoadingMoreSheds;

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
    this.farms = const [],
    this.currentShedAvailability,
    this.currentShedPage = 1,
    this.totalShedPages = 1,
    this.hasMoreSheds = false,
    this.isLoadingMoreSheds = false,
  });

  FarmManagerDashboardState copyWith({
    int? investorCount,
    int? totalStaff,
    int? pendingApprovals,
    bool? isLoading,
    String? error,
    List<DashboardImage>? images,
    AnimalkartOrder? currentOrder,
    bool clearCurrentOrder = false,
    List<dynamic>? onboardedAnimalIds,
    List<Shed>? sheds,
    List<Farm>? farms,
    ShedPositionResponse? currentShedAvailability,
    int? currentShedPage,
    int? totalShedPages,
    bool? hasMoreSheds,
    bool? isLoadingMoreSheds,
  }) {
    return FarmManagerDashboardState(
      investorCount: investorCount ?? this.investorCount,
      totalStaff: totalStaff ?? this.totalStaff,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      images: images ?? this.images,
      currentOrder: clearCurrentOrder
          ? null
          : (currentOrder ?? this.currentOrder),
      onboardedAnimalIds: onboardedAnimalIds ?? this.onboardedAnimalIds,
      sheds: sheds ?? this.sheds,
      farms: farms ?? this.farms,
      currentShedAvailability:
          currentShedAvailability ?? this.currentShedAvailability,
      currentShedPage: currentShedPage ?? this.currentShedPage,
      totalShedPages: totalShedPages ?? this.totalShedPages,
      hasMoreSheds: hasMoreSheds ?? this.hasMoreSheds,
      isLoadingMoreSheds: isLoadingMoreSheds ?? this.isLoadingMoreSheds,
    );
  }
}
