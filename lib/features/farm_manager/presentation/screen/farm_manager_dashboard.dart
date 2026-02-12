import 'dart:ui';
import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/widgets/employee_bottom_navigation.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/staff_list_provider.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_manager_dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmManagerDashboard extends ConsumerStatefulWidget {
  const FarmManagerDashboard({super.key});

  @override
  ConsumerState<FarmManagerDashboard> createState() =>
      _FarmManagerDashboardState();
}

class _FarmManagerDashboardState extends ConsumerState<FarmManagerDashboard> {
  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).refreshUserData();
      ref.read(farmManagerProvider.notifier).refreshDashboard();
      ref.read(staffListProvider.notifier).loadStaff();
    });
  }

  void _baseDialog(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _searchDialog(BuildContext context) {
    String query = "";
    List<InvestorAnimal> results = [];
    bool isSearching = false;

    _baseDialog(
      context,
      title: "Search Animal",
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> performSearch() async {
            if (query.trim().isEmpty) return;
            setDialogState(() => isSearching = true);
            try {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('access_token') ?? '';
              final list = await AnimalApiServices.searchAnimals(
                token: token,
                query: query,
              );
              setDialogState(() {
                results = list;
                isSearching = false;
              });
            } catch (e) {
              setDialogState(() => isSearching = false);
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "RFID or Ear Tag",
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => query = val,
                      onSubmitted: (_) => performSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: performSearch,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isSearching
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (results.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  "Search Results",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final animal = results[index];
                      final rfid = animal.rfid ?? animal.animalId;
                      final shedName = animal.shedName ?? 'Not Allocated';
                      final hasAllocation = animal.shedId != null;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.pets,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: Text(
                          "Animal: $rfid",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          "Shed: $shedName",
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          if (hasAllocation) {
                            Navigator.pop(context);
                            context.push(
                              '/buffalo-allocation',
                              extra: {
                                'shedId': animal.shedId,
                                'parkingId': animal.parkingId,
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ] else if (!isSearching && query.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "No animals found",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = ref.watch(farmManagerProvider);
    final ss = ref.watch(staffListProvider);
    final authState = ref.watch(authProvider);
    final user = authState.userData;

    String displayName = "Manager";
    if (user != null &&
        (user.firstName.isNotEmpty || user.lastName.isNotEmpty)) {
      final fname = user.firstName.isNotEmpty
          ? user.firstName[0].toUpperCase() + user.firstName.substring(1)
          : "";
      final lname = user.lastName.isNotEmpty
          ? user.lastName[0].toUpperCase() + user.lastName.substring(1)
          : "";
      displayName = "$fname $lname".trim();
    } else if (user != null && user.name.isNotEmpty) {
      displayName = user.name;
    }
    displayName = "$displayName,";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              text: 'Hello ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              children: [
                TextSpan(
                  text: displayName,
                  style: const TextStyle(
                    color: AppTheme.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (ref.watch(authProvider).availableRoles.length > 1)
            IconButton(
              onPressed: () => _showSwitchRoleBottomSheet(),
              icon: Icon(
                Icons.swap_horiz_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tooltip: 'Switch Role',
            ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _searchDialog(context),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.imageUrl!,
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              size: 20,
                              color: AppTheme.primary,
                            ),
                      ),
                    )
                  : const Icon(Icons.person, size: 20, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ds.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : ds.error != null
          ? _buildErrorView(ds.error!)
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(farmManagerProvider.notifier).refreshDashboard();
                await ref.read(staffListProvider.notifier).loadStaff();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Overview Management"),
                    const SizedBox(height: 16),
                    _buildStatsGrid(ds, ss),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Operations"),
                    const SizedBox(height: 16),
                    _buildQuickActionGrid(),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Pending Allocation"),
                    const SizedBox(height: 16),
                    _buildRecentActivity(ds),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: EmployeeBottomNavigation(
        role: UserType.farmManager,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            context.push('/onboard-animal');
          } else if (index == 1) {
            context.push('/buffalo-allocation');
          } else if (index == 2) {
            context.push('/reports');
          } else if (index == 3) {
            context.push('/buffalo-profile');
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = 4);
          context.go('/farm-manager-dashboard');
        },
        child: Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : AppTheme.darkPrimary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkPrimary
                  : AppTheme.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.asset(
              'assets/icons/home.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primary
                  : AppTheme.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildStatsGrid(FarmManagerDashboardState ds, StaffListState ss) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          "Investors",
          ds.investorCount.toString(),
          Icons.monetization_on_rounded,
          Colors.blue,
          () => context.go('/investor-details'),
        ),
        _buildStatCard(
          "Staff",
          ss.staff.length.toString(),
          Icons.group_rounded,
          Colors.green,
          () => context.go('/staff-list'),
        ),
        _buildStatCard(
          "Active Sheds",
          ds.sheds.length.toString(),
          Icons.warehouse_rounded,
          Colors.orange,
          () => context.push('/buffalo-allocation'),
        ),
        _buildStatCard(
          "Pending Allocation",
          ds.onboardedAnimalIds.length.toString(),
          Icons.hourglass_empty_rounded,
          Colors.pink,
          () => context.push('/buffalo-allocation'),
        ),
        _buildStatCard(
          "Transfers",
          "View",
          Icons.compare_arrows_rounded,
          Colors.purple,
          () => context.push('/manager-transfer-approvals'),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildActionItem(
          'Manage Staff',
          Icons.people_outline,
          const Color(0xFF673AB7),
          () => context.go('/staff-list'),
        ),
        _buildActionItem(
          'Reports',
          Icons.bar_chart_rounded,
          const Color(0xFF3F51B5),
          () => context.push('/reports'),
        ),
        _buildActionItem(
          'Onboard Animal',
          Icons.add_box_outlined,
          const Color(0xFF009688),
          () => context.go('/onboard-animal'),
        ),
        _buildActionItem(
          'Create Transfer',
          Icons.move_up_rounded,
          const Color(0xFF607D8B),
          () => context.push('/create-transfer-ticket'),
        ),
        _buildActionItem(
          'Transfers List',
          Icons.compare_arrows_rounded,
          const Color(0xFF9C27B0),
          () => context.push('/manager-transfer-approvals'),
        ),
        _buildActionItem(
          'Search Animal',
          Icons.search_rounded,
          const Color(0xFFFF9800),
          () => _searchDialog(context),
        ),
        _buildActionItem(
          'Health Tickets',
          Icons.medical_services_outlined,
          const Color(0xFFF44336),
          () => context.push('/all-health-tickets'),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(FarmManagerDashboardState ds) {
    if (ds.onboardedAnimalIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.grey.shade100,
          ),
        ),
        child: Text(
          "Everything is allocated!",
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }
    return Column(
      children: ds.onboardedAnimalIds.take(3).map((item) {
        String rfid = 'Unknown';
        if (item is String) {
          rfid = item.split('-').last;
        } else if (item is Map) {
          rfid =
              (item['rfid_tag'] ??
                      item['rfid'] ??
                      item['rfid_tag_number'] ??
                      item['animal_id'] ??
                      '')
                  .toString();
          if (rfid.contains('-')) {
            rfid = rfid.split('-').last;
          }
        } else {
          rfid = item.toString().split('-').last;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.1)
                    : Colors.black.withOpacity(0.01),
                blurRadius: 5,
              ),
            ],
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFF1F8E9),
              child: Icon(Icons.pets_rounded, size: 18, color: Colors.green),
            ),
            title: Text(
              "RFID: $rfid",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              "Status: Pending",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).hintColor,
            ),
            onTap: () => context.push('/buffalo-allocation'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorView(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text(
            "Failed to load dashboard",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            msg,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                ref.read(farmManagerProvider.notifier).refreshDashboard(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRoleInfo(UserType role) {
    switch (role) {
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
              const Text(
                'Choose which portal you want to access',
                style: TextStyle(color: Colors.grey),
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
}
