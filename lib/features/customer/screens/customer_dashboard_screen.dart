import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/buffalo_provider.dart';
import '../providers/dashboard_stats_provider.dart';
import '../widgets/buffalo_card.dart';
import '../models/unit_response.dart';

class CustomerDashboardScreen extends ConsumerStatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  ConsumerState<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState
    extends ConsumerState<CustomerDashboardScreen> {
  int _currentIndex = 0;
  bool _isGridView = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Home - already on dashboard
        break;
      case 1:
        context.go('/asset-valuation');
        break;
      case 2:
        context.go('/cctv-live');
        break;
      case 3:
        context.go('/revenue');
        break;
      case 4:
        context.go('/customer-profile');
        break;
    }
  }

  // Previously _hasActiveFilters logic
  bool get _hasActiveFilters {
    final filter = ref.read(buffaloFilterProvider);
    return filter.statusFilter != 'all' ||
        filter.selectedFarms.isNotEmpty ||
        filter.selectedLocations.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buffalos = ref.watch(filteredBuffaloListProvider);
    final stats = ref.watch(dashboardStatsProvider);

    // We watch the filter provider just to rebuild if active filters change (for the filter icon color)
    ref.watch(buffaloFilterProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('My Buffaloes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go(
              '/notifications',
              extra: {'fallbackRoute': '/customer-dashboard'},
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () {
          // Add your refresh logic here. With Riverpod, this might trigger a provider refresh.
          return Future.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            // Consolidated Stats & Financial Overview
            stats.when(
              data: (data) => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      context,
                      value: data['count'] ?? '0',
                      label: 'Total Units',
                      icon: Icons.grid_view, // Changed icon to distinguish
                      isCompact: true,
                    ),
                    _buildStatItem(
                      context,
                      value: data['buffaloes'] ?? '0',
                      label: 'Buffaloes',
                      icon: Icons.pets,
                      isCompact: true,
                    ),
                    _buildStatItem(
                      context,
                      value: data['calves'] ?? '0',
                      label: 'Calfs',
                      icon: Icons.child_care,
                      isCompact: true,
                    ),
                    _buildStatItem(
                      context,
                      value: data['revenue']?.toString() ?? '₹0',
                      label: 'Revenue',
                      icon: Icons.trending_up,
                      isCompact: true,
                    ),
                    _buildStatItem(
                      context,
                      value: data['netProfit']?.toString() ?? '₹0',
                      label: 'Net Profit',
                      icon: Icons.monetization_on,
                      isCompact: true,
                    ),
                  ],
                ),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ),
            ),

            _buildSearchAndFilterBar(),

            // Buffalo List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Buffaloes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    tooltip: _isGridView
                        ? 'Switch to List View'
                        : 'Switch to Grid View',
                  ),
                ],
              ),
            ),

            // Buffalo List/Grid View
            Expanded(
              child: buffalos.when(
                data: (data) => data.isEmpty
                    ? const Center(child: Text('No buffaloes found'))
                    : (_isGridView
                          ? _buildGridView(data)
                          : _buildListView(data)),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error: ${err.toString()}')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.secondary,
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Assets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            activeIcon: Icon(Icons.videocam),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_outlined),
            activeIcon: Icon(Icons.attach_money),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.white,
                  child: Icon(Icons.person, size: 30, color: AppTheme.primary),
                ),
                const SizedBox(height: AppConstants.spacingM),
                Text(
                  'FarmVest',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'farmvest@gmail.com',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.home, color: AppTheme.primary),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              if (ModalRoute.of(context)?.settings.name !=
                  '/customer-dashboard') {
                context.go('/customer-dashboard');
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppTheme.primary),
            title: const Text('Monthly Visits'),
            onTap: () {
              Navigator.pop(context);
              context.go('/monthly-visits');
            },
          ),

          ListTile(
            leading: const Icon(Icons.videocam, color: AppTheme.primary),
            title: const Text('Live CCTV'),
            onTap: () {
              Navigator.pop(context);
              context.go('/cctv-live');
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.medical_services,
              color: AppTheme.primary,
            ),
            title: const Text('Health Records'),
            onTap: () {
              Navigator.pop(context);
              context.go('/health-records');
            },
          ),

          ListTile(
            leading: const Icon(Icons.assessment, color: AppTheme.primary),
            title: const Text('Revenue'),
            onTap: () {
              Navigator.pop(context);
              context.go('/revenue');
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primary,
            ),
            title: const Text('Asset Valuation'),
            onTap: () {
              Navigator.pop(context);
              context.go('/asset-valuation');
            },
          ),

          const Divider(),

          // Support Section
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppTheme.primary),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              context.go('/support');
            },
          ),

          // Profile Section
          ListTile(
            leading: const Icon(Icons.person, color: AppTheme.primary),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              context.go('/customer-profile');
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorRed),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        context.go('/login'); // Navigate to login
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: AppTheme.errorRed),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // We use Consumer here to listen to provider updates inside the modal if needed,
        // or just read initial values. The filter provider is global so we can just use reference to notifier.
        // However, standard pattern for modals is using a local state and applying, OR live updates.
        // The original code used local state and applied on button press.
        // I will replicate "Apply" logic: Read from provider into local state, modify local state, then write back to provider on specific actions.

        // Actually, to make it truly reactive and simple, we could update the provider LIVE (no Apply button needed),
        // OR use a local copy. The UI has an "Apply Filters" button, so local copy is best.

        final currentFilterState = ref.read(buffaloFilterProvider);

        return StatefulBuilder(
          builder: (context, setModalState) {
            // We need to manage state locally within this modal builder
            // We initialize from currentFilterState
            // But StatefulBuilder re-runs builder only on setModalState.
            // We need to initialize state variables outside builder or use a wrapper widget.
            // Since we are inside a method, let's just initialize variables before StatefulBuilder.
            return _FilterSheetContent(
              initialState: currentFilterState,
              onApply: (newState) {
                ref
                    .read(buffaloFilterProvider.notifier)
                    .applyFilters(
                      status: newState.statusFilter,
                      farms: newState.selectedFarms,
                      locations: newState.selectedLocations,
                    );
                Navigator.pop(context);
              },
              allFarms: ref.read(allFarmsProvider),
              allLocations: ref.read(allLocationsProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.filter_alt,
                  color: _hasActiveFilters
                      ? AppTheme.primary
                      : Colors.grey[700],
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

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    bool isCompact = false,
  }) {
    final theme = Theme.of(context);
    final iconSize = isCompact ? 18.0 : 20.0;
    final padding = isCompact ? 6.0 : 8.0;
    final valueStyle = isCompact
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondary,
            fontSize: 16,
          )
        : theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondary,
          );
    final labelStyle = isCompact
        ? theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Colors.grey[600],
          )
        : theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppTheme.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.secondary, size: iconSize),
        ),
        SizedBox(height: isCompact ? 4 : 8),
        Text(value, style: valueStyle),
        Text(label, style: labelStyle),
      ],
    );
  }

  Widget _buildGridView(List<Animal> buffalos) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75, // Taller cards
      ),
      itemCount: buffalos.length,
      itemBuilder: (context, index) {
        final buffalo = buffalos[index];

        // Check for calves
        final allAnimals = ref.read(rawBuffaloListProvider).value ?? [];
        List<Animal> calves = buffalo.children ?? [];
        if (calves.isEmpty) {
          calves = allAnimals.where((a) => a.parentId == buffalo.id).toList();
        }

        return BuffaloCard(
          farmName: 'FarmVest Unit',
          location: 'Hyderabad',
          id: buffalo.breedId ?? 'Unknown ID',
          healthStatus: 'Healthy',
          lastMilking: 'Checked recently',
          age: '${buffalo.ageYears ?? 0} years',
          breed: buffalo.breedId ?? 'Unknown Breed',
          isGridView: true,
          onTap: () {
            // Navigate to buffalo details with full object
            context.go('/unit-details', extra: {'buffalo': buffalo});
          },
          onCalvesTap: calves.isNotEmpty
              ? () {
                  context.push(
                    '/buffalo-calves',
                    extra: {
                      'calves': calves,
                      'parentId': buffalo.id ?? 'Unknown',
                    },
                  );
                }
              : null,
        );
      },
    );
  }

  Widget _buildListView(List<Animal> buffalos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: buffalos.length,
      itemBuilder: (context, index) {
        final buffalo = buffalos[index];

        // Check for calves
        final allAnimals = ref.read(rawBuffaloListProvider).value ?? [];
        List<Animal> calves = buffalo.children ?? [];
        if (calves.isEmpty) {
          calves = allAnimals.where((a) => a.parentId == buffalo.id).toList();
        }

        return BuffaloCard(
          farmName: 'FarmVest Unit',
          location: 'Hyderabad',
          id: buffalo.breedId ?? 'Unknown ID',
          healthStatus: 'Healthy',
          lastMilking: 'Checked recently',
          age: '${buffalo.ageYears ?? 0} years',
          breed: buffalo.breedId ?? 'Unknown Breed',
          isGridView: false,
          onTap: () {
            // Navigate to buffalo details
            context.go('/unit-details', extra: {'buffalo': buffalo});
          },
          onCalvesTap: calves.isNotEmpty
              ? () {
                  context.push(
                    '/buffalo-calves',
                    extra: {
                      'calves': calves,
                      'parentId': buffalo.id ?? 'Unknown',
                    },
                  );
                }
              : null,
        );
      },
    );
  }
}

// Separate widget for the modal content to manage local state cleanly
class _FilterSheetContent extends StatefulWidget {
  final BuffaloFilterState initialState;
  final Function(BuffaloFilterState) onApply;
  final List<String> allFarms;
  final List<String> allLocations;

  const _FilterSheetContent({
    required this.initialState,
    required this.onApply,
    required this.allFarms,
    required this.allLocations,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late String currentFilter;
  late Set<String> currentFarms;
  late Set<String> currentLocations;

  @override
  void initState() {
    super.initState();
    currentFilter = widget.initialState.statusFilter;
    currentFarms = Set.from(widget.initialState.selectedFarms);
    currentLocations = Set.from(widget.initialState.selectedLocations);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // Health Status
          _buildFilterSection(
            title: 'Health Status',
            items: const ['all', 'healthy', 'warning', 'critical'],
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
            items: widget.allFarms,
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
            items: widget.allLocations,
            selectedItems: currentLocations,
            onSelectionChanged: (selected) {
              setState(() {
                currentLocations.clear();
                currentLocations.addAll(selected);
              });
            },
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    widget.initialState.copyWith(
                      statusFilter: currentFilter,
                      selectedFarms: currentFarms,
                      selectedLocations: currentLocations,
                    ),
                  );
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
                    fontSize: 16,
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
                    : item[0].toUpperCase() + item.substring(1),
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
              backgroundColor: Colors.grey[200],
              selectedColor: AppTheme.secondary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.secondary : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.secondary : Colors.grey[300]!,
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
