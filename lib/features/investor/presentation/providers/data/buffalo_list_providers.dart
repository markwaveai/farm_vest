import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/investor/presentation/providers/data/investor_data_providers.dart';
import 'package:farm_vest/features/investor/presentation/providers/filter/buffalo_filter_notifier.dart';
import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';

/* -------------------------------------------------------------------------- */
/*                          DERIVED DATA PROVIDERS                            */
/* -------------------------------------------------------------------------- */

/// Provider for raw buffalo list (unfiltered).
///
/// Extracts the animal list from the investor animals response.
/// This provider returns an AsyncValue containing the list of animals.
///
/// Use this when you need the complete, unfiltered list of animals.
///
/// Example:
/// ```dart
/// final rawListAsync = ref.watch(rawBuffaloListProvider);
/// rawListAsync.when(
///   data: (animals) => Text('Total: ${animals.length}'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error'),
/// );
/// ```
final rawBuffaloListProvider = Provider<AsyncValue<List<InvestorAnimal>>>((
  ref,
) {
  final responseAsync = ref.watch(investorAnimalsProvider);

  return responseAsync.whenData((response) {
    if (response == null) return [];
    return response.data;
  });
});

/// Provider for filtered buffalo list.
///
/// Applies the current filter state to the raw buffalo list.
/// This provider automatically updates when either the animal list
/// or the filter state changes.
///
/// Filters applied:
/// - Search query (matches animal ID or farm name)
/// - Health status (healthy, warning, critical, or all)
/// - Selected farms
/// - Selected locations
///
/// Example:
/// ```dart
/// final filteredListAsync = ref.watch(filteredBuffaloListProvider);
/// filteredListAsync.when(
///   data: (animals) => ListView.builder(
///     itemCount: animals.length,
///     itemBuilder: (context, index) => AnimalCard(animals[index]),
///   ),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
final filteredBuffaloListProvider =
    FutureProvider.autoDispose<List<InvestorAnimal>>((ref) async {
      final filter = ref.watch(buffaloFilterProvider);
      final token = await ref.read(authRepositoryProvider).getToken();

      // Call dynamic search API
      // If query is empty, pass "all" to get everything (as per backend logic)
      final results = await AnimalApiServices.searchAnimals(
        token: token ?? '',
        query: filter.searchQuery.isEmpty ? 'all' : filter.searchQuery,
        healthStatus: filter.statusFilter == 'all' ? null : filter.statusFilter,
      );

      // Map nested search_animal response to InvestorAnimal manually
      // because InvestorAnimal.fromJson expects a flat structure
      var animals = results.map((data) {
        final animal = data['animal_details'] ?? {};
        final farm = data['farm_details'] ?? {};
        final shed = data['shed_details'] ?? {};

        return InvestorAnimal(
          animalId: animal['animal_id'] ?? '',
          rfid: animal['rfid_tag_number'],
          age: animal['age_months'] is int ? animal['age_months'] : null,
          shedName: shed['shed_name'],
          shedId: shed['id'] is int ? shed['id'] : null,
          animalType: animal['animal_type'] ?? 'Buffalo',
          images:
              (animal['images'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          farmName: farm['farm_name'],
          farmLocation: farm['location'],
          healthStatus: animal['health_status'] ?? 'Unknown',
        );
      }).toList();

      // Apply Farm & Location filters locally (backend requires IDs, we have Names)
      if (filter.selectedFarms.isNotEmpty &&
          !filter.selectedFarms.contains('all')) {
        animals = animals
            .where((a) => filter.selectedFarms.contains(a.farmName))
            .toList();
      }

      if (filter.selectedLocations.isNotEmpty &&
          !filter.selectedLocations.contains('all')) {
        animals = animals
            .where((a) => filter.selectedLocations.contains(a.farmLocation))
            .toList();
      }

      return animals;
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
  final responseAsync = ref.watch(investorAnimalsProvider);
  return responseAsync.whenData((response) {
        if (response == null) return ['All Farms'];

        final farms = <String>{};
        for (var animal in response.data) {
          if (animal.farmName != null && animal.farmName!.isNotEmpty) {
            farms.add(animal.farmName!);
          }
        }

        if (farms.isEmpty) return ['All Farms'];
        return farms.toList()..sort();
      }).value ??
      ['All Farms'];
});

/// Provider for unique farm locations.
///
/// Extracts all unique locations from the animal list for filter options.
/// Returns a list of locations sorted alphabetically.
///
/// Returns ['All Locations'] if no locations are available.
///
/// Example:
/// ```dart
/// final locations = ref.watch(allLocationsProvider);
/// Wrap(
///   children: locations.map((location) => FilterChip(
///     label: Text(location),
///     onSelected: (selected) => /* handle selection */,
///   )).toList(),
/// );
/// ```
final allLocationsProvider = Provider<List<String>>((ref) {
  final responseAsync = ref.watch(investorAnimalsProvider);
  return responseAsync.whenData((response) {
        if (response == null) return ['All Locations'];

        final locations = <String>{};
        for (var animal in response.data) {
          if (animal.farmLocation != null && animal.farmLocation!.isNotEmpty) {
            locations.add(animal.farmLocation!);
          }
        }

        if (locations.isEmpty) return ['All Locations'];
        return locations.toList()..sort();
      }).value ??
      ['All Locations'];
});
