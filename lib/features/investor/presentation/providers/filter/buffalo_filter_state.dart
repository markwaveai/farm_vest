/// State class for buffalo filtering.
///
/// Manages all filter criteria including search query, health status,
/// farm selection, and location selection.
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

  /// Creates a copy of this state with the given fields replaced.
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

  /// Checks if any filters are active.
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      statusFilter != 'all' ||
      selectedFarms.isNotEmpty ||
      selectedLocations.isNotEmpty;

  /// Resets all filters to default values.
  BuffaloFilterState get cleared => const BuffaloFilterState();

  @override
  String toString() {
    return 'BuffaloFilterState(searchQuery: $searchQuery, statusFilter: $statusFilter, '
        'selectedFarms: $selectedFarms, selectedLocations: $selectedLocations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BuffaloFilterState &&
        other.searchQuery == searchQuery &&
        other.statusFilter == statusFilter &&
        other.selectedFarms == selectedFarms &&
        other.selectedLocations == selectedLocations;
  }

  @override
  int get hashCode {
    return searchQuery.hashCode ^
        statusFilter.hashCode ^
        selectedFarms.hashCode ^
        selectedLocations.hashCode;
  }
}
