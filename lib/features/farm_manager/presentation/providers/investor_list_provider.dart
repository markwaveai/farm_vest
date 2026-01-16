import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Model for an Investor
// This should be moved to a proper model file in data/models eventually
class Investor {
  final String name;
  final String location;
  final String amount;
  final String date;
  final String status;

  Investor({
    required this.name,
    required this.location,
    required this.amount,
    required this.date,
    required this.status,
  });
}

// 2. State definition for the investor list - NOW INCLUDES SEARCH
class InvestorListState {
  final List<Investor> investors;
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
    List<Investor>? investors,
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
  final List<Investor> _sourceInvestors = [
    Investor(
      name: "Rahul Sharma",
      location: "Hyderabad, India",
      amount: "₹25,00,000",
      date: "Jan 2024",
      status: "Active",
    ),
    Investor(
      name: "Venture Alpha",
      location: "Bangalore, India",
      amount: "₹75,00,000",
      date: "Mar 2024",
      status: "Active",
    ),
    Investor(
      name: "Sneha Patel",
      location: "Ahmedabad, India",
      amount: "₹5,00,000",
      date: "Apr 2023",
      status: "Exited",
    ),
    Investor(
      name: "Aayush Sharma",
      location: "Mumbai, India",
      amount: "10,00,000",
      date: "Jan 2025",
      status: "Active",
    ),
    Investor(
      name: "Anjaneyulu",
      location: "Hyderabad, India",
      amount: "33,00,000",
      date: "Oct 2023",
      status: "Active",
    ),
  ];

  @override
  InvestorListState build() {
    // Initially, show all investors
    return InvestorListState(investors: _sourceInvestors);
  }

  void _runFilters({String? status, String? query}) {
    state = state.copyWith(isLoading: true);
    final currentStatus = status ?? state.statusFilter;
    final currentQuery = query ?? state.searchQuery;

    // Apply status filter first
    List<Investor> filteredList;
    if (currentStatus == 'all') {
      filteredList = _sourceInvestors;
    } else {
      filteredList = _sourceInvestors
          .where((i) => i.status.toLowerCase() == currentStatus.toLowerCase())
          .toList();
    }

    // Then apply search query on the result
    if (currentQuery.isNotEmpty) {
      filteredList = filteredList
          .where((i) =>
              i.name.toLowerCase().contains(currentQuery.toLowerCase()))
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
