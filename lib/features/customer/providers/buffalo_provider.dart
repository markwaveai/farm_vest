import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_services.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:farm_vest/features/customer/models/unit_response.dart';
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
    if (response?.orders == null) return [];

    List<Animal> buffaloes = [];
    for (var order in response!.orders!) {
      if (order.buffalos != null && order.paymentStatus == 'PAID') {
        buffaloes.addAll(order.buffalos!);
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
      final query = filter.searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          (buffalo.id?.toLowerCase().contains(query) ?? false) ||
          (buffalo.breedId?.toLowerCase().contains(query) ?? false);

      final matchesFarm =
          filter.selectedFarms.isEmpty ||
          filter.selectedFarms.contains('all') ||
          filter.selectedFarms.contains(buffalo.farmName ?? 'Kurnool');

      final matchesLocation =
          filter.selectedLocations.isEmpty ||
          filter.selectedLocations.contains('all') ||
          filter.selectedLocations.contains(buffalo.farmLocation ?? 'Kurnool');

      final matchesHealth =
          filter.statusFilter == 'all' ||
          (buffalo.healthStatus?.toLowerCase() ==
              filter.statusFilter.toLowerCase());

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
  final responseAsync = ref.watch(unitResponseProvider);
  return responseAsync.whenData((response) {
        Set<String> farms = {};
        if (response?.orders != null) {
          for (var order in response!.orders!) {
            if (order.buffalos != null) {
              for (var buffalo in order.buffalos!) {
                if (buffalo.farmName != null) {
                  farms.add(buffalo.farmName!);
                }
              }
            }
          }
        }
        return farms.toList();
      }).value ??
      ['Kurnool'];
});

final allLocationsProvider = Provider<List<String>>((ref) {
  final responseAsync = ref.watch(unitResponseProvider);
  return responseAsync.whenData((response) {
        Set<String> locations = {};
        if (response?.orders != null) {
          for (var order in response!.orders!) {
            if (order.buffalos != null) {
              for (var buffalo in order.buffalos!) {
                if (buffalo.farmLocation != null) {
                  locations.add(buffalo.farmLocation!);
                }
              }
            }
          }
        }
        return locations.toList();
      }).value ??
      ['Kurnool'];
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
      buffaloCount = response!.overallStats!.buffaloesCount ?? 0;
      calfCount = response.overallStats!.calvesCount ?? 0;
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
