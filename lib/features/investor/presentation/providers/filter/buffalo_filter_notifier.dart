import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'buffalo_filter_state.dart';

/// Notifier for managing buffalo filter state.
///
/// Provides methods to update individual filter criteria or apply
/// multiple filters at once.
///
/// Example usage:
/// ```dart
/// // In a widget
/// final filterNotifier = ref.read(buffaloFilterProvider.notifier);
/// filterNotifier.setSearchQuery('MUR123');
/// filterNotifier.setStatusFilter('healthy');
/// ```
class BuffaloFilterNotifier extends Notifier<BuffaloFilterState> {
  @override
  BuffaloFilterState build() {
    return const BuffaloFilterState();
  }

  /// Updates the search query filter.
  ///
  /// The search query is used to filter animals by ID or farm name.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Updates the health status filter.
  ///
  /// Valid values: 'all', 'healthy', 'warning', 'critical'
  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  /// Toggles a farm in the selected farms set.
  ///
  /// Parameters:
  /// - [farmName]: Name of the farm to toggle
  /// - [isSelected]: Whether the farm should be selected or deselected
  void toggleFarm(String farmName, bool isSelected) {
    final newFarms = Set<String>.from(state.selectedFarms);
    if (isSelected) {
      newFarms.add(farmName);
    } else {
      newFarms.remove(farmName);
    }
    state = state.copyWith(selectedFarms: newFarms);
  }

  /// Sets the selected farms, replacing any existing selection.
  void setFarms(Set<String> farms) {
    state = state.copyWith(selectedFarms: farms);
  }

  /// Toggles a location in the selected locations set.
  ///
  /// Parameters:
  /// - [location]: Location to toggle
  /// - [isSelected]: Whether the location should be selected or deselected
  void toggleLocation(String location, bool isSelected) {
    final newLocations = Set<String>.from(state.selectedLocations);
    if (isSelected) {
      newLocations.add(location);
    } else {
      newLocations.remove(location);
    }
    state = state.copyWith(selectedLocations: newLocations);
  }

  /// Sets the selected locations, replacing any existing selection.
  void setLocations(Set<String> locations) {
    state = state.copyWith(selectedLocations: locations);
  }

  /// Clears all filters, resetting to default state.
  void clearAll() {
    state = const BuffaloFilterState();
  }

  /// Applies multiple filters at once.
  ///
  /// This is more efficient than calling individual setters when
  /// updating multiple filter criteria simultaneously.
  ///
  /// Parameters:
  /// - [status]: Health status filter
  /// - [farms]: Set of selected farm names
  /// - [locations]: Set of selected locations
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

/// Provider for buffalo filter state.
///
/// This provider manages the filter state for the buffalo list screen.
/// Use this to read the current filter state or to update it.
///
/// Example:
/// ```dart
/// // Read current state
/// final filterState = ref.watch(buffaloFilterProvider);
///
/// // Update state
/// ref.read(buffaloFilterProvider.notifier).setSearchQuery('MUR123');
/// ```
final buffaloFilterProvider =
    NotifierProvider<BuffaloFilterNotifier, BuffaloFilterState>(
      BuffaloFilterNotifier.new,
    );
