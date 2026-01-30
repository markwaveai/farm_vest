import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import '../providers/admin_provider.dart';

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
          role: role!.isEmpty ? null : role,
          name: query.isEmpty ? null : query,
          farmId: _selectedFarmId,
          isActive: ref.read(adminProvider).staffActiveFilter,
        );
  }

  void _onFilterChanged(String label) {
    if (_selectedRoleFilter != label) {
      setState(() => _selectedRoleFilter = label);
      _fetchStaff();
    }
  }

  void _onSearch(String query) {
    _fetchStaff();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final staffList = adminState.staffList;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
              return;
            }
            if (context.canPop()) {
              context.pop();
            } else {
              final userRole = ref.read(authProvider).role;
              if (userRole == UserType.admin) {
                context.go('/admin-dashboard');
              } else if (userRole == UserType.supervisor) {
                context.go('/supervisor-dashboard');
              } else {
                context.go('/farm-manager-dashboard');
              }
            }
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search staff...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearch,
              )
            : const Text('Staff Directory'),
        actions: [
          if (!_isSearching && authState.availableRoles.length > 1)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: _showSwitchRoleBottomSheet,
              tooltip: 'Switch Role',
            ),
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
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
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () => context.pushNamed('add-staff'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildFarmFilterChips(adminState.farms),
          _buildActiveInactiveFilters(adminState.staffActiveFilter),
          Expanded(
            child: adminState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : staffList.isEmpty
                ? const Center(
                    child: Text(
                      'No staff members found',
                      style: TextStyle(color: AppTheme.slate),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: staffList.length,
                    itemBuilder: (context, index) =>
                        _buildStaffTile(staffList[index], index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: _roleFilterMapping.keys.map((label) {
          return _filterChip(label, _selectedRoleFilter == label);
        }).toList(),
      ),
    );
  }

  Widget _buildFarmFilterChips(List<Map<String, dynamic>> farms) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _farmFilterChip("All Farms", null),
          ...farms.map((f) {
            return _farmFilterChip(
              f['farm_name']?.toString() ?? "Farm",
              f['id'] as int?,
            );
          }),
        ],
      ),
    );
  }

  Widget _farmFilterChip(String label, int? farmId) {
    final isSelected = _selectedFarmId == farmId;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) {
          setState(() => _selectedFarmId = farmId);
          _fetchStaff();
        },
        selectedColor: Colors.orange.withOpacity(0.2),
        checkmarkColor: Colors.orange,
        labelStyle: TextStyle(
          color: isSelected ? Colors.orange : AppTheme.slate,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (v) => _onFilterChanged(label),
        selectedColor: AppTheme.primary.withOpacity(0.2),
        checkmarkColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primary : AppTheme.slate,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildActiveInactiveFilters(bool staffActiveFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _activeInactiveChip("Active", true, staffActiveFilter),
          const SizedBox(width: 8),
          _activeInactiveChip("Inactive", false, staffActiveFilter),
        ],
      ),
    );
  }

  Widget _activeInactiveChip(String label, bool value, bool currentFilter) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          ref
              .read(adminProvider.notifier)
              .fetchStaff(
                role: _roleFilterMapping[_selectedRoleFilter]!.isEmpty
                    ? null
                    : _roleFilterMapping[_selectedRoleFilter],
                name: _searchController.text.trim().isEmpty
                    ? null
                    : _searchController.text.trim(),
                farmId: _selectedFarmId,
                isActive: value,
              );
        }
      },
      selectedColor: value
          ? Colors.green.withOpacity(0.2)
          : Colors.red.withOpacity(0.2),
      checkmarkColor: value ? Colors.green : Colors.red,
      labelStyle: TextStyle(
        color: isSelected
            ? (value ? Colors.green : Colors.red)
            : AppTheme.slate,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  void _showReassignDialog(BuildContext context, int staffId) {
    final adminState = ref.read(adminProvider);
    final farms = adminState.farms;
    final allStaff = adminState.staffList;

    // Find the staff member to check their role
    final staff = allStaff.firstWhere(
      (s) => s['id'] == staffId,
      orElse: () => {},
    );
    final roles = (staff['roles'] as List?)?.cast<String>() ?? [];
    final isSupervisor = roles.contains('SUPERVISOR');

    int? selectedFarmId;
    int? selectedShedId;
    List<Map<String, dynamic>> sheds = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reassign Employee'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select the new farm for this employee:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Farm',
                  ),
                  items: farms.map((f) {
                    return DropdownMenuItem<int>(
                      value: f['id'] as int,
                      child: Text(f['farm_name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedFarmId = val;
                      selectedShedId = null;

                      // Load sheds for selected farm if Supervisor
                      if (isSupervisor && val != null) {
                        final farm = farms.firstWhere((f) => f['id'] == val);
                        sheds =
                            (farm['sheds'] as List?)
                                ?.cast<Map<String, dynamic>>() ??
                            [];
                      }
                    });
                  },
                ),

                // Show shed selector for Supervisors
                if (isSupervisor && selectedFarmId != null) ...[
                  const SizedBox(height: 16),
                  const Text('Select shed for supervisor:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select Shed',
                    ),
                    value: selectedShedId,
                    items: sheds.map((s) {
                      return DropdownMenuItem<int>(
                        value: s['id'] as int,
                        child: Text(s['shed_name'] ?? 'Shed ${s['shed_id']}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedShedId = val),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedFarmId != null) {
                final primaryRole = roles.firstWhere(
                  (r) => r == 'FARM_MANAGER' || r == 'SUPERVISOR',
                  orElse: () => roles.isNotEmpty ? roles.first : '',
                );
                final success = await ref
                    .read(adminProvider.notifier)
                    .reassignEmployeeFarm(
                      staffId: staffId,
                      newFarmId: selectedFarmId!,
                      role: primaryRole,
                      shedId: selectedShedId,
                    );
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee reassigned successfully'),
                    ),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTile(Map<String, dynamic> staff, int index) {
    final roles = (staff['roles'] as List).cast<String>();
    final isActive = staff['is_active'] ?? true;
    final roleDisplay = roles.isNotEmpty
        ? roles.map((r) => r.replaceAll('_', ' ')).join(', ')
        : 'No Role';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
        border: isActive
            ? null
            : Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isActive
              ? AppTheme.lightGrey
              : Colors.red.withOpacity(0.1),
          radius: 25,
          child: Icon(
            Icons.person,
            color: isActive ? AppTheme.slate : Colors.red,
          ),
        ),
        title: Text(
          '${staff['first_name']} ${staff['last_name']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isActive ? null : TextDecoration.lineThrough,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              roleDisplay,
              style: TextStyle(
                color: isActive ? AppTheme.primary : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Mobile: ${staff['mobile']}',
              style: const TextStyle(fontSize: 12),
            ),
            if (staff['assigned_farms'] != null &&
                (staff['assigned_farms'] as List).isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: (staff['assigned_farms'] as List).map((f) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.agriculture_rounded,
                          size: 10,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          f['name']?.toString() ?? 'Farm',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (staff['assigned_sheds'] != null &&
                (staff['assigned_sheds'] as List).isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: (staff['assigned_sheds'] as List).map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.blueGrey.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warehouse_rounded,
                          size: 10,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          s['name']?.toString() ?? 'Shed',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (!isActive)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
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
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'reassign') {
              _showReassignDialog(context, staff['id']);
            } else if (value == 'toggle_status') {
              final success = await ref
                  .read(adminProvider.notifier)
                  .toggleEmployeeStatus(
                    mobile: staff['mobile'],
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
              child: Text(isActive ? 'Deactivate' : 'Activate'),
            ),
            const PopupMenuItem(
              value: 'reassign',
              child: Text('Reassign Farm'),
            ),
          ],
        ),
      ),
    );
  }
}
