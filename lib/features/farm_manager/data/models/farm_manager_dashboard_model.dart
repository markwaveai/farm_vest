
// 1. Define the data model for the dashboard state
class FarmManagerDashboardState {
  final int investorCount;
  final int totalStaff;
  final int pendingApprovals;
  final bool isLoading;
  final String? error;

  FarmManagerDashboardState({
    this.investorCount = 0,
    this.totalStaff = 0,
    this.pendingApprovals = 0,
    this.isLoading = false,
    this.error,
  });

  FarmManagerDashboardState copyWith({
    int? investorCount,
    int? totalStaff,
    int? pendingApprovals,
    bool? isLoading,
    String? error,
  }) {
    return FarmManagerDashboardState(
      investorCount: investorCount ?? this.investorCount,
      totalStaff: totalStaff ?? this.totalStaff,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}