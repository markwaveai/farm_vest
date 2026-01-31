import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/investor/presentation/providers/filter/buffalo_filter_notifier.dart';
import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';

/* -------------------------------------------------------------------------- */
/*                          DERIVED DATA PROVIDERS                            */
/* -------------------------------------------------------------------------- */

/// Provider for raw buffalo list (unfiltered).
///
/// Fetches the complete list of animals for the investor from the search API.
/// This acts as the "Source of Truth" for both the UI list and the filters.
final rawBuffaloListProvider = FutureProvider<List<InvestorAnimal>>((
  ref,
) async {
  final token = await ref.read(authRepositoryProvider).getToken();
  if (token == null) return [];

  final results = await AnimalApiServices.searchAnimals(
    token: token,
    query: 'all', // Get everything initially
  );

  return results;
});

/// Provider for filtered buffalo list.
///
/// Applies the current filter state to the raw buffalo list.
/// This ensures the UI list and the filter options are always in sync.
final filteredBuffaloListProvider = Provider<AsyncValue<List<InvestorAnimal>>>((
  ref,
) {
  final rawListAsync = ref.watch(rawBuffaloListProvider);
  final filter = ref.watch(buffaloFilterProvider);

  return rawListAsync.whenData((animals) {
    var filteredList = animals;

    // Apply search query filter
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filteredList = filteredList.where((a) {
        return (a.rfid?.toLowerCase().contains(query) ?? false) ||
            (a.animalId.toLowerCase().contains(query)) ||
            (a.farmName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply Health Status filter
    if (filter.statusFilter != 'all') {
      filteredList = filteredList
          .where(
            (a) =>
                a.healthStatus.toLowerCase() ==
                filter.statusFilter.toLowerCase(),
          )
          .toList();
    }

    // Apply Farm filter
    if (filter.selectedFarms.isNotEmpty &&
        !filter.selectedFarms.contains('all')) {
      filteredList = filteredList
          .where((a) => filter.selectedFarms.contains(a.farmName))
          .toList();
    }

    // Apply Location filter
    if (filter.selectedLocations.isNotEmpty &&
        !filter.selectedLocations.contains('all')) {
      filteredList = filteredList
          .where((a) => filter.selectedLocations.contains(a.farmLocation))
          .toList();
    }

    return filteredList;
  });
});

/// Provider for unique farm names.
///
/// Extracts all unique farm names from the animal list for filter options.
/// Returns a list of farm names sorted alphabetically.
///
/// Returns ['All Farms'] if no farms are available.
///
/// Example:
/// ```dart
/// final farms = ref.watch(allFarmsProvider);
/// DropdownButton<String>(
///   items: farms.map((farm) => DropdownMenuItem(
///     value: farm,
///     child: Text(farm),
///   )).toList(),
/// );
/// ```
final allFarmsProvider = Provider<List<String>>((ref) {
  final responseAsync = ref.watch(rawBuffaloListProvider);
  return responseAsync.when(
    data: (animals) {
      if (animals.isEmpty) return [];
      final farms = animals
          .map((a) => a.farmName)
          .where((name) => name != null && name.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      farms.sort();
      return farms;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for unique farm locations.
final allLocationsProvider = Provider<List<String>>((ref) {
  final responseAsync = ref.watch(rawBuffaloListProvider);
  return responseAsync.when(
    data: (animals) {
      if (animals.isEmpty) return [];
      final locations = animals
          .map((a) => a.farmLocation)
          .where((loc) => loc != null && loc.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      locations.sort();
      return locations;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for unique health statuses.
final allHealthStatusesProvider = Provider<List<String>>((ref) {
  final responseAsync = ref.watch(rawBuffaloListProvider);
  return responseAsync.when(
    data: (animals) {
      if (animals.isEmpty) return [];
      final statuses = animals
          .map((a) => a.healthStatus)
          .where((s) => s.isNotEmpty && s != kHyphen)
          .toSet()
          .toList();
      statuses.sort();
      return statuses;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
