import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/investor_api_services.dart';
import 'package:farm_vest/features/investor/data/models/investor_model.dart'
    as model;

// Local Investor class removed in favor of data/models/investor_model.dart

// 2. State definition for the investor list - NOW INCLUDES SEARCH
class InvestorListState {
  final List<model.Investor> investors;
  final String statusFilter; // "all", "active", "exited"
  final String searchQuery;
  final bool isLoading;

  InvestorListState({
    this.investors = const [],
    this.statusFilter = 'all',
    this.searchQuery = '',
    this.isLoading = false,
  });

  InvestorListState copyWith({
    List<model.Investor>? investors,
    String? statusFilter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return InvestorListState(
      investors: investors ?? this.investors,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 3. The Notifier to manage the state
class InvestorListNotifier extends Notifier<InvestorListState> {
  // Hold the original, unfiltered list of investors
  List<model.Investor> _sourceInvestors = [];

  @override
  InvestorListState build() {
    _loadInvestors();
    return InvestorListState(isLoading: true);
  }

  Future<void> _loadInvestors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) return;

      _sourceInvestors = await InvestorApiServices.getAllInvestors(
        token: token,
      );
      _runFilters();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Ideally handle error state
    }
  }

  void _runFilters({String? status, String? query}) {
    state = state.copyWith(isLoading: true);
    final currentStatus = status ?? state.statusFilter;
    final currentQuery = query ?? state.searchQuery;

    // Apply status filter first
    List<model.Investor> filteredList;
    if (currentStatus == 'all') {
      filteredList = _sourceInvestors;
    } else {
      // Note: model.Investor doesn't have 'status' string, might need active_status from JSON or handling here
      // Assuming 'Active' for all returned for now, or based on animal count
      filteredList = _sourceInvestors;
    }

    // Then apply search query on the result
    if (currentQuery.isNotEmpty) {
      filteredList = filteredList
          .where(
            (i) =>
                i.fullName.toLowerCase().contains(currentQuery.toLowerCase()) ||
                i.phoneNumber.contains(currentQuery),
          )
          .toList();
    }

    // Simulate a small delay
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(
        investors: filteredList,
        isLoading: false,
        statusFilter: currentStatus,
        searchQuery: currentQuery,
      );
    });
  }

  void setStatusFilter(String status) {
    _runFilters(status: status);
  }

  void setSearchQuery(String query) {
    _runFilters(query: query);
  }
}

// 4. The final provider that the UI will use
final investorListProvider =
    NotifierProvider<InvestorListNotifier, InvestorListState>(
      InvestorListNotifier.new,
    );
