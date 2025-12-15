import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_services.dart';
import '../../auth/providers/auth_provider.dart';
import '../../customer/models/unit_response.dart';
// import 'package:flutter_riverpod/legacy.dart'; // Removing legacy if unused or keep if needed, but adding ApiServices

// 1. Logic for the Filter State
class BuffaloFilterState {
  final String searchQuery;
  final String statusFilter; // 'all', 'healthy', 'warning', 'critical'
  final Set<String> selectedFarms;
  final Set<String> selectedLocations;

  const BuffaloFilterState({
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.selectedFarms = const {},
    this.selectedLocations = const {},
  });

  BuffaloFilterState copyWith({
    String? searchQuery,
    String? statusFilter,
    Set<String>? selectedFarms,
    Set<String>? selectedLocations,
  }) {
    return BuffaloFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      selectedFarms: selectedFarms ?? this.selectedFarms,
      selectedLocations: selectedLocations ?? this.selectedLocations,
    );
  }
}

class BuffaloFilterNotifier extends Notifier<BuffaloFilterState> {
  @override
  BuffaloFilterState build() {
    return const BuffaloFilterState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void toggleFarm(String farmName, bool isSelected) {
    final newFarms = Set<String>.from(state.selectedFarms);
    if (isSelected) {
      newFarms.add(farmName);
    } else {
      newFarms.remove(farmName);
    }
    state = state.copyWith(selectedFarms: newFarms);
  }

  void setFarms(Set<String> farms) {
    state = state.copyWith(selectedFarms: farms);
  }

  void toggleLocation(String location, bool isSelected) {
    final newLocations = Set<String>.from(state.selectedLocations);
    if (isSelected) {
      newLocations.add(location);
    } else {
      newLocations.remove(location);
    }
    state = state.copyWith(selectedLocations: newLocations);
  }

  void setLocations(Set<String> locations) {
    state = state.copyWith(selectedLocations: locations);
  }

  void clearAll() {
    state = const BuffaloFilterState();
  }

  void applyFilters({
    required String status,
    required Set<String> farms,
    required Set<String> locations,
  }) {
    state = state.copyWith(
      statusFilter: status,
      selectedFarms: farms,
      selectedLocations: locations,
    );
  }
}

final buffaloFilterProvider =
    NotifierProvider<BuffaloFilterNotifier, BuffaloFilterState>(
      BuffaloFilterNotifier.new,
    );

// 2. Data Provider (Central Unit Response)
final unitResponseProvider = FutureProvider<UnitResponse?>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.mobileNumber ?? "";

  if (userId.isEmpty) return null;

  return await ApiServices.getUnits(userId);
});

// 3. Raw List Provider (Derived from unitResponse)
final rawBuffaloListProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final responseAsync = ref.watch(unitResponseProvider);

  return responseAsync.whenData((response) {
    if (response?.units == null) return [];

    List<Animal> buffaloes = [];
    for (var unit in response!.units!) {
      if (unit.buffalos != null) {
        buffaloes.addAll(unit.buffalos!);
      }
    }
    return buffaloes;
  });
});

// 4. Computed/Derived Provider (Filtered List)
final filteredBuffaloListProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final allBuffaloesAsync = ref.watch(rawBuffaloListProvider);
  final filter = ref.watch(buffaloFilterProvider);

  return allBuffaloesAsync.whenData((allBuffaloes) {
    return allBuffaloes.where((buffalo) {
      final matchesSearch =
          filter.searchQuery.isEmpty ||
          (buffalo.id?.toLowerCase().contains(
                filter.searchQuery.toLowerCase(),
              ) ??
              false);

      final matchesFarm =
          filter.selectedFarms.isEmpty ||
          filter.selectedFarms.contains('all') ||
          filter.selectedFarms.contains('FarmVest Unit');

      final matchesLocation =
          filter.selectedLocations.isEmpty ||
          filter.selectedLocations.contains('all') ||
          filter.selectedLocations.contains('Hyderabad');

      final matchesHealth = filter.statusFilter == 'all' || true;

      return matchesSearch &&
          matchesFarm &&
          matchesLocation &&
          matchesHealth &&
          (buffalo.parentId == null); // Only show parent buffalos
    }).toList();
  });
});

// 5. Unique Values Providers (for Filter Chips)
final allFarmsProvider = Provider<List<String>>((ref) {
  return ['FarmVest Unit'];
});

final allLocationsProvider = Provider<List<String>>((ref) {
  return ['Hyderabad'];
});

// 6. Stats Providers
final buffaloStatsProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final responseAsync = ref.watch(unitResponseProvider);

  return responseAsync.whenData((response) {
    num buffaloCount = 0;
    num calfCount = 0;
    num totalRevenue = 0;
    num netProfit = 0;

    // Read directly from OverallStats
    if (response?.overallStats != null) {
      buffaloCount = response!.overallStats!.totalUnits ?? 0;
      calfCount = response.overallStats!.totalCalves ?? 0;
    }

    // Read directly from Financials
    if (response?.financials != null) {
      totalRevenue = response!.financials!.totalRevenueEarned ?? 0;
      netProfit = response.financials!.netProfit ?? 0;
    }

    return {
      'count': buffaloCount.toString(),
      'calves': calfCount.toString(),
      'revenue': '₹${totalRevenue.toStringAsFixed(0)}',
      'netProfit': '₹${netProfit.toStringAsFixed(0)}',
    };
  });
});
