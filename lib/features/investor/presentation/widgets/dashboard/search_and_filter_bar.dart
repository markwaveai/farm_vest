import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchAndFilterBar extends ConsumerStatefulWidget {
  const SearchAndFilterBar({super.key});

  @override
  ConsumerState<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends ConsumerState<SearchAndFilterBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final currentQuery = ref.read(buffaloFilterProvider).searchQuery;
    if (currentQuery.isNotEmpty) {
      _searchController.text = currentQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    final filter = ref.read(buffaloFilterProvider);
    return filter.statusFilter != 'all' ||
        filter.selectedFarms.isNotEmpty ||
        filter.selectedLocations.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to changes in filter query to update controller if needed
    ref.listen<BuffaloFilterState>(buffaloFilterProvider, (previous, next) {
      if (previous?.searchQuery != next.searchQuery &&
          _searchController.text != next.searchQuery) {
        _searchController.text = next.searchQuery;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: theme.textTheme.bodyMedium,
            textCapitalization: TextCapitalization.characters,
            // keyboardType: TextInputType.,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: 'Search by ID...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? Colors.grey[400] : null,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? AppTheme.darkSurfaceVariant
                  : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.filter_alt,
                  color: _hasActiveFilters
                      ? AppTheme.primary
                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
                onPressed: () => _showFilterSheet(context),
              ),
            ),
            onChanged: (value) {
              ref.read(buffaloFilterProvider.notifier).setSearchQuery(value);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return _FilterSheetContent();
      },
    );
  }
}

class _FilterSheetContent extends ConsumerStatefulWidget {
  const _FilterSheetContent();

  @override
  ConsumerState<_FilterSheetContent> createState() =>
      _FilterSheetContentState();
}

class _FilterSheetContentState extends ConsumerState<_FilterSheetContent> {
  late String currentFilter;
  late Set<String> currentFarms;
  late Set<String> currentLocations;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(buffaloFilterProvider);
    currentFilter = initialState.statusFilter;
    currentFarms = Set.from(initialState.selectedFarms);
    currentLocations = Set.from(initialState.selectedLocations);
  }

  @override
  Widget build(BuildContext context) {
    final allFarms = ref.watch(allFarmsProvider);
    final allLocations = ref.watch(allLocationsProvider);
    final allHealthStatuses = ref.watch(allHealthStatusesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentFilter = 'all';
                        currentFarms.clear();
                        currentLocations.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          _buildFilterSection(
            title: 'Health Status',
            items: ['all', ...allHealthStatuses],
            selectedItems: {currentFilter},
            onSelectionChanged: (selected) {
              setState(() {
                currentFilter = selected.isNotEmpty ? selected.first : 'all';
              });
            },
            singleSelect: true,
          ),
          _buildFilterSection(
            title: 'Farms',
            items: allFarms,
            selectedItems: currentFarms,
            onSelectionChanged: (selected) {
              setState(() {
                currentFarms.clear();
                currentFarms.addAll(selected);
              });
            },
          ),
          _buildFilterSection(
            title: 'Locations',
            items: allLocations,
            selectedItems: currentLocations,
            onSelectionChanged: (selected) {
              setState(() {
                currentLocations.clear();
                currentLocations.addAll(selected);
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(buffaloFilterProvider.notifier)
                      .applyFilters(
                        status: currentFilter,
                        farms: currentFarms,
                        locations: currentLocations,
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required Set<String> selectedItems,
    required Function(Set<String>) onSelectionChanged,
    bool singleSelect = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(
                item == 'all'
                    ? 'All'
                    : item[0].toUpperCase() +
                          item.substring(1).toLowerCase().replaceAll('_', ' '),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = Set<String>.from(selectedItems);
                if (singleSelect) {
                  newSelection.clear();
                  if (selected) {
                    newSelection.add(item);
                  } else {
                    newSelection.add('all');
                  }
                } else {
                  if (selected) {
                    newSelection.add(item);
                    if (item == 'all') {
                      newSelection.clear();
                      newSelection.add('all');
                    } else {
                      newSelection.remove('all');
                    }
                  } else {
                    newSelection.remove(item);
                  }
                }
                onSelectionChanged(newSelection);
              },
              backgroundColor: isDark
                  ? AppTheme.darkSurfaceVariant
                  : Colors.grey[200],
              selectedColor: AppTheme.secondary.withValues(alpha: 0.2),
              checkmarkColor: isSelected ? AppTheme.secondary : null,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppTheme.secondary
                    : (isDark ? Colors.grey[300] : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.secondary
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
