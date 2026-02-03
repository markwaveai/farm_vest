import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/admin_provider.dart';
import 'package:farm_vest/core/widgets/farm_selector_input.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const StaffManagementScreen({super.key, this.onBackPressed});

  @override
  ConsumerState<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedRoleFilter = 'All';
  int? _selectedFarmId;
  String? _selectedLocation; // Added location filter

  final Map<String, String> _roleFilterMapping = {
    'All': '',
    'Farm Managers': 'FARM_MANAGER',
    'Supervisors': 'SUPERVISOR',
    'Doctors': 'DOCTOR',
    'Assistants': 'ASSISTANT_DOCTOR',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _fetchStaff();
      ref.read(adminProvider.notifier).fetchFarms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getRoleInfo(UserType role) {
    switch (role) {
      case UserType.admin:
        return {
          'label': 'Administrator',
          'icon': Icons.admin_panel_settings,
          'color': Colors.blue,
        };
      case UserType.farmManager:
        return {
          'label': 'Farm Manager',
          'icon': Icons.agriculture,
          'color': Colors.green,
        };
      case UserType.supervisor:
        return {
          'label': 'Supervisor',
          'icon': Icons.assignment_ind,
          'color': Colors.orange,
        };
      case UserType.doctor:
        return {
          'label': 'Doctor',
          'icon': Icons.medical_services,
          'color': Colors.red,
        };
      case UserType.assistant:
        return {
          'label': 'Assistant Doctor',
          'icon': Icons.health_and_safety,
          'color': Colors.teal,
        };
      case UserType.customer:
        return {
          'label': 'Investor',
          'icon': Icons.trending_up,
          'color': Colors.indigo,
        };
    }
  }

  void _showSwitchRoleBottomSheet() {
    // ... (unchanged)
    final authState = ref.read(authProvider);
    final availableRoles = authState.availableRoles;
    final currentRole = authState.role;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Active Role',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose which portal you want to access',
                style: TextStyle(color: AppTheme.mediumGrey),
              ),
              const SizedBox(height: 24),
              ...availableRoles.map((role) {
                final info = _getRoleInfo(role);
                final isSelected = role == currentRole;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: isSelected
                        ? null
                        : () async {
                            Navigator.pop(context);
                            await ref
                                .read(authProvider.notifier)
                                .selectRole(role);

                            if (!mounted) return;
                            switch (role) {
                              case UserType.admin:
                                context.go('/admin-dashboard');
                                break;
                              case UserType.farmManager:
                                context.go('/farm-manager-dashboard');
                                break;
                              case UserType.supervisor:
                                context.go('/supervisor-dashboard');
                                break;
                              case UserType.doctor:
                                context.go('/doctor-dashboard');
                                break;
                              case UserType.assistant:
                                context.go('/assistant-dashboard');
                                break;
                              case UserType.customer:
                                context.go('/customer-dashboard');
                                break;
                            }
                          },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? info['color']
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected
                        ? (info['color'] as Color).withOpacity(0.05)
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: (info['color'] as Color).withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        info['icon'] as IconData,
                        color: info['color'] as Color,
                      ),
                    ),
                    title: Text(
                      info['label'] as String,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: info['color'] as Color,
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchStaff() {
    final role = _roleFilterMapping[_selectedRoleFilter];
    final query = _searchController.text.trim();
    ref
        .read(adminProvider.notifier)
        .fetchStaff(
          role: role?.isEmpty ?? true ? null : role,
          name: query.isEmpty ? null : query,
          farmId: _selectedFarmId,
          isActive: ref.read(adminProvider).staffActiveFilter,
        );
  }

  void _onSearch(String query) {
    _fetchStaff();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final adminState = ref.watch(
            adminProvider,
          ); // use watch to update when farms load

          // Extract locations from farms
          final locations = adminState.farms
              .map((f) => f.location)
              .where((l) => l.isNotEmpty)
              .toSet()
              .toList();
          locations.sort();

          return Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Reset filters
                        this.setState(() {
                          _selectedRoleFilter = 'All';
                          _selectedFarmId = null;
                          _selectedLocation = null;
                        });
                        ref
                            .read(adminProvider.notifier)
                            .fetchStaff(
                              isActive: true,
                            ); // Reset to default active
                        setState(() {}); // Update local sheet state
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSheetFilterChip(
                              setSheetState,
                              'Active',
                              adminState.staffActiveFilter == true,
                              () => ref
                                  .read(adminProvider.notifier)
                                  .fetchStaff(
                                    isActive: true,
                                    role:
                                        _roleFilterMapping[_selectedRoleFilter]!
                                            .isEmpty
                                        ? null
                                        : _roleFilterMapping[_selectedRoleFilter],
                                    name: _searchController.text.trim().isEmpty
                                        ? null
                                        : _searchController.text.trim(),
                                    farmId: _selectedFarmId,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            _buildSheetFilterChip(
                              setSheetState,
                              'Inactive',
                              adminState.staffActiveFilter == false,
                              () => ref
                                  .read(adminProvider.notifier)
                                  .fetchStaff(
                                    isActive: false,
                                    role:
                                        _roleFilterMapping[_selectedRoleFilter]!
                                            .isEmpty
                                        ? null
                                        : _roleFilterMapping[_selectedRoleFilter],
                                    name: _searchController.text.trim().isEmpty
                                        ? null
                                        : _searchController.text.trim(),
                                    farmId: _selectedFarmId,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Role',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _roleFilterMapping.keys.map((label) {
                            return _buildSheetFilterChip(
                              setSheetState,
                              label,
                              _selectedRoleFilter == label,
                              () {
                                this.setState(
                                  () => _selectedRoleFilter = label,
                                );
                                _fetchStaff();
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (locations.isEmpty)
                          const Text(
                            'No locations available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: locations.map((loc) {
                            return _buildSheetFilterChip(
                              setSheetState,
                              loc,
                              _selectedLocation == loc,
                              () {
                                this.setState(() {
                                  if (_selectedLocation == loc) {
                                    _selectedLocation = null;
                                  } else {
                                    _selectedLocation = loc;
                                  }
                                });
                                // Force rebuild to update local state in parent
                                this.setState(() {});
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Farm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSheetFilterChip(
                              setSheetState,
                              'All Farms',
                              _selectedFarmId == null,
                              () {
                                this.setState(() => _selectedFarmId = null);
                                _fetchStaff();
                              },
                            ),
                            ...adminState.farms
                                .where((f) {
                                  if (_selectedLocation == null) return true;
                                  return f.location == _selectedLocation;
                                })
                                .map((f) {
                                  return _buildSheetFilterChip(
                                    setSheetState,
                                    f.farmName,
                                    _selectedFarmId == f.id,
                                    () {
                                      this.setState(
                                        () => _selectedFarmId = f.id,
                                      );
                                      _fetchStaff();
                                    },
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Show Results',
                  onPressed: () {
                    this.setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSheetFilterChip(
    StateSetter setSheetState,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
        setSheetState(() {}); // Refresh sheet UI
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var adminState = ref.watch(adminProvider);
    var staffList = adminState.staffList;
    final authState = ref.watch(authProvider);

    // Apply client-side location filtering
    if (_selectedLocation != null) {
      staffList = staffList.where((s) {
        final farmIdStr = s.farmId;
        if (farmIdStr == null || farmIdStr.isEmpty) return true;

        try {
          final farmId = int.parse(farmIdStr);
          final farm = adminState.farms.firstWhere((f) => f.id == farmId);
          return farm.location == _selectedLocation;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    int activeFilters = 0;
    if (_selectedRoleFilter != 'All') activeFilters++;
    if (_selectedFarmId != null) activeFilters++;
    if (_selectedLocation != null) activeFilters++; // Count location filter
    if (adminState.staffActiveFilter == false) activeFilters++;

    return Scaffold(
      backgroundColor: AppTheme.white, // Clean white background
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
              return;
            }
            context.pop();
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search staff...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: _onSearch,
              )
            : const Text(
                'Staff Directory',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _fetchStaff();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: Colors.black),
                  tooltip: 'Filters',
                  onPressed: _showFilterBottomSheet,
                ),
                if (activeFilters > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeFilters',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: AppTheme.primary),
              onPressed: () => context.pushNamed('add-staff'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Summary Bar (Optional - shows what's active)
          if (activeFilters > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.lightGrey,
              child: Row(
                children: [
                  Text(
                    'Active Filters: $_selectedRoleFilter ${adminState.staffActiveFilter ? '' : '(Inactive)'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRoleFilter = 'All';
                        _selectedFarmId = null;
                      });
                      ref
                          .read(adminProvider.notifier)
                          .fetchStaff(isActive: true);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : staffList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No staff members found',
                          style: TextStyle(color: AppTheme.slate, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: staffList.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildStaffTile(staffList[index], index),
                  ),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(BuildContext context, int staffId) {
  final adminState = ref.read(adminProvider);
    final farms = adminState.farms;
  final allStaff = adminState.staffList;

    // Find the staff member to check their role
  final staff = allStaff.firstWhere(
    (s) => s.id == staffId.toString(),
    orElse: () => UserModel(
      id: '',
      mobile: '',
      firstName: '',
      lastName: '',
      name: '',
      email: '',
      role: '',
    ),
  );
  final roles = staff.roles;
  final bool isSupervisor = roles.contains('SUPERVISOR');

  int? selectedFarmId;
  int? selectedShedId;
  List<Map<String, dynamic>> sheds = [];
  bool isLoadingSheds = false;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        final bool isFormValid =
            selectedFarmId != null &&
            (!isSupervisor || selectedShedId != null);

        return AlertDialog(
          title: const Text('Reassign Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                const Text('Select the new farm for this employee:'),
                const SizedBox(height: 16),
              FarmSelectorInput(
                selectedFarmId: selectedFarmId,
                label: 'Select Farm',
                onChanged: (farmId) async {
                  setState(() {
                    selectedFarmId = farmId;
                    selectedShedId = null;
                    sheds.clear();
                    isLoadingSheds = isSupervisor;
                  });

                  if (isSupervisor && farmId != null) {
                    try {
                      final prefs =
                          await SharedPreferences.getInstance();
                      final token =
                          prefs.getString('access_token');

                      if (token == null) return;

                      final fetchedSheds =
                          await ShedsApiServices.getSheds(
                        token: token,
                        farmId: farmId,
                      );

                      if (context.mounted) {
                        setState(() => sheds = fetchedSheds);
                      }
                    } catch (e) {
                      debugPrint('Shed fetch error: $e');
                    } finally {
                      if (context.mounted) {
                        setState(() => isLoadingSheds = false);
                      }
                    }
                  } else {
                    setState(() => isLoadingSheds = false);
                  }
                },
              ),

                // Show shed selector for Supervisors
              if (isSupervisor && selectedFarmId != null) ...[
                const SizedBox(height: 16),
                const Text('Select shed for supervisor:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedShedId,
                    decoration: const InputDecoration(
                      labelText: 'Select Shed',
                      border: OutlineInputBorder(),
                    ),
                    items: sheds.map((s) {
                      return DropdownMenuItem<int>(
                        value: s['id'],
                        child: Text(
                          '${s['shed_name']} (${s['shed_id']})',
                        ),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => selectedShedId = v),
                  ),

                if (!isLoadingSheds && sheds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'No sheds found for this farm',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            /// CONFIRM BUTTON (SMART ENABLE)
            PrimaryButton(
              text: 'Confirm',
              onPressed: isFormValid
                  ? () async {
                      final primaryRole = roles.firstWhere(
                        (r) =>
                            r == 'FARM_MANAGER' ||
                            r == 'SUPERVISOR',
                        orElse: () => roles.first,
                      );

                      final success = await ref
                          .read(adminProvider.notifier)
                          .reassignEmployeeFarm(
                            staffId: staffId,
                            newFarmId: selectedFarmId!,
                            role: primaryRole,
                            shedId:
                                isSupervisor ? selectedShedId : null,
                          );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Employee reassigned successfully',
                            ),
                          ),
                        );
                      }
                    }
                  : null,
            ),
          ],
        );
      },
    ),
  );
}



  Widget _buildStaffTile(UserModel staff, int index) {
    final roles = staff.roles;
    final isActive = staff.isActive;
    final roleDisplay = roles.isNotEmpty
        ? roles.map((r) => r.replaceAll('_', ' ')).join(', ')
        : 'No Role';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Can add detail view navigation here
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      staff.firstName.isNotEmpty
                          ? staff.firstName.substring(0, 1).toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppTheme.primary : Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${staff.firstName} ${staff.lastName}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isActive ? AppTheme.dark : Colors.grey,
                                decoration: isActive
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'INACTIVE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleDisplay,
                        style: TextStyle(
                          color: isActive ? AppTheme.primary : Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Location Display
                      () {
                        final farms = ref.watch(adminProvider).farms;
                        String? locationLabel;

                        // Try to get farm name/location
                        String? name = staff.farmName;
                        String? loc = staff.farmLocation;

                        // Fallback to ID lookup
                        if ((name == null ||
                                name.isEmpty ||
                                name.toLowerCase() == "null") &&
                            staff.farmId != null) {
                          try {
                            final fId = int.parse(staff.farmId!);
                            final farm = farms.firstWhere((f) => f.id == fId);
                            name = farm.farmName;
                            loc = farm.location;
                          } catch (_) {}
                        }

                        if (loc != null &&
                            loc.isNotEmpty &&
                            loc.toLowerCase() != "null") {
                          locationLabel = loc;
                          if (name != null &&
                              name.isNotEmpty &&
                              name.toLowerCase() != "null" &&
                              name != loc) {
                            locationLabel = "$loc • $name";
                          }
                        } else if (name != null &&
                            name.isNotEmpty &&
                            name.toLowerCase() != "null") {
                          locationLabel = name;
                        }

                        // Add shed if available
                        if (staff.shedName != null &&
                            staff.shedName!.isNotEmpty &&
                            staff.shedName!.toLowerCase() != "null") {
                          locationLabel =
                              (locationLabel != null
                                  ? "$locationLabel • "
                                  : "") +
                              staff.shedName!;
                        }

                        if (locationLabel != null &&
                            locationLabel.isNotEmpty &&
                            locationLabel != "null") {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 2.0,
                              bottom: 2.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    locationLabel
                                        .toUpperCase(), // Highlight with uppercase
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[700],
                                      letterSpacing: 0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }(),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            staff.mobile,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (staff.email.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  staff.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Actions
                Column(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.grey,
                      ),
                      onSelected: (value) async {
                        if (value == 'reassign') {
                          try {
                            _showReassignDialog(context, int.parse(staff.id));
                          } catch (_) {}
                        } else if (value == 'toggle_status') {
                          final success = await ref
                              .read(adminProvider.notifier)
                              .toggleEmployeeStatus(
                                mobile: staff.mobile,
                                isActive: !isActive,
                              );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Employee ${isActive ? 'deactivated' : 'activated'} successfully',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle_status',
                          child: Row(
                            children: [
                              Icon(
                                isActive ? Icons.block : Icons.check_circle,
                                color: isActive ? Colors.red : Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(isActive ? 'Deactivate' : 'Activate'),
                            ],
                          ),
                        ),
                        if (isActive)
                          const PopupMenuItem(
                            value: 'reassign',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.move_up_rounded,
                                  color: AppTheme.slate,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text('Reassign Farm'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
