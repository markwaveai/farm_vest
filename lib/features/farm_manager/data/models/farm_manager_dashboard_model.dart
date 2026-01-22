
import 'dart:io';

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

  FarmManagerDashboardState({
    this.investorCount = 0,
    this.totalStaff = 0,
    this.pendingApprovals = 0,
    this.isLoading = false,
    this.error,
    this.images = const [],
  });

  FarmManagerDashboardState copyWith({
    int? investorCount,
    int? totalStaff,
    int? pendingApprovals,
    bool? isLoading,
    String? error,
    List<DashboardImage>? images,
  }) {
    return FarmManagerDashboardState(
      investorCount: investorCount ?? this.investorCount,
      totalStaff: totalStaff ?? this.totalStaff,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      images: images ?? this.images,
    );
  }
}
