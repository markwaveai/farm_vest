import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/farm_manager_dashboard_model.dart';


// 2. Create the Notifier to manage the state
class FarmManagerDashboardNotifier extends Notifier<FarmManagerDashboardState> {
  @override
  FarmManagerDashboardState build() {
    // Load initial data when the provider is first created
    _fetchDashboardData();
    return FarmManagerDashboardState(isLoading: true);
  }

  // 3. Fetch data (mocked for now, but ready for API calls)
  Future<void> _fetchDashboardData() async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would make an API call here.
    // For now, we use the same mock data that was in the UI.
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
}

// 4. Define the final provider
final farmManagerProvider =
    NotifierProvider<FarmManagerDashboardNotifier, FarmManagerDashboardState>(
  FarmManagerDashboardNotifier.new,
);
