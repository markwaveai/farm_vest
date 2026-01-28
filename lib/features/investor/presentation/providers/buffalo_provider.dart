import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/data/models/unit_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final unitResponseProvider = FutureProvider<UnitResponse?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) return null;

    // Use the new aggregated dashboard data API
    // final response = await ApiServices.getInvestorDashboardData(token);
    // return response;
  } catch (e) {
    return null;
  }
});

final cctvFeedsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  if (authState.mobileNumber == null) return [];

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return [];

    // final response = await ApiServices.getInvestorAnimalsLocal(token);
    final Map<String, Map<String, dynamic>> sheds = {};

    // for (var animal in response) {
    //   final shedName = animal['shed_name'] ?? animal['farm_name'] ?? 'Shed';
    //   if (!sheds.containsKey(shedName)) {
    //     final List<String> urls = [];
    //     if (animal['cctv_url']?.toString().isNotEmpty ?? false)
    //       urls.add(animal['cctv_url']);
    //     if (animal['cctv_url_2']?.toString().isNotEmpty ?? false)
    //       urls.add(animal['cctv_url_2']);
    //     if (animal['cctv_url_3']?.toString().isNotEmpty ?? false)
    //       urls.add(animal['cctv_url_3']);
    //     if (animal['cctv_url_4']?.toString().isNotEmpty ?? false)
    //       urls.add(animal['cctv_url_4']);

    //     if (urls.isNotEmpty) {
    //       sheds[shedName] = {'name': shedName, 'urls': urls};
    //     }
    //   }
    // }
    return sheds.values.toList();
  } catch (e) {
    return [];
  }
});

// 3. Raw List Provider (Derived from unitResponse)
final rawBuffaloListProvider = Provider<AsyncValue<List<Animal>>>((ref) {
  final responseAsync = ref.watch(unitResponseProvider);

  return responseAsync.whenData((response) {
    if (response == null) return [];

    // Prioritize direct animals list from new API structure
    if (response.animals != null && response.animals!.isNotEmpty) {
      return response.animals!;
    }

    // Fallback to legacy orders structure
    if (response.orders == null) return [];

    List<Animal> buffaloes = [];
    for (var order in response.orders!) {
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

        // New flow: direct animals
        if (response?.animals != null) {
          for (var buffalo in response!.animals!) {
            if (buffalo.farmName != null) farms.add(buffalo.farmName!);
          }
        }

        // Legacy flow: orders
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

        // If data found, return list, otherwise default
        if (farms.isNotEmpty) return farms.toList();
        return ['Kurnool'];
      }).value ??
      ['Kurnool'];
});

final allLocationsProvider = Provider<List<String>>((ref) {
  final responseAsync = ref.watch(unitResponseProvider);
  return responseAsync.whenData((response) {
        Set<String> locations = {};

        // New flow: direct animals
        if (response?.animals != null) {
          for (var buffalo in response!.animals!) {
            if (buffalo.farmLocation != null)
              locations.add(buffalo.farmLocation!);
          }
        }

        // Legacy flow: orders
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

        // If data found, return list, otherwise default
        if (locations.isNotEmpty) return locations.toList();
        return ['Kurnool'];
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
