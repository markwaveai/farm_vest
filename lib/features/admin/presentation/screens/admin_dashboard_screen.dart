import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import '../providers/admin_provider.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_model.dart';
import 'ticket_management_screen.dart';
import 'staff_management_screen.dart';
import '../widgets/admin_bottom_navigation.dart';
import 'package:farm_vest/features/admin/presentation/screens/investor_management_screen.dart';
import 'package:farm_vest/features/auth/presentation/widgets/profile_menu_drawer.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() => _selectedIndex = 0);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.white,
        drawer: const ProfileMenuDrawer(),
        body: _buildBody(),
        bottomNavigationBar: AdminBottomNavigation(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
          onTap: () {
            setState(() => _selectedIndex = 0);
          },
          child: Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: AppTheme.darkPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.white, width: 4),
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
                color: AppTheme.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _AdminHomeView(
          onNavigate: (index) => setState(() => _selectedIndex = index),
        );
      case 1:
        return _AdminFarmsView();
      case 2:
        return _AdminGlobalTicketsView(
          onBack: () => setState(() => _selectedIndex = 0),
        );
      case 3:
        return _AdminStaffView(
          onBack: () => setState(() => _selectedIndex = 0),
        );
      case 4:
        return const InvestorManagementScreen();
      default:
        return _AdminHomeView(
          onNavigate: (index) => setState(() => _selectedIndex = index),
        );
    }
  }
}

class _AdminHomeView extends ConsumerWidget {
  final Function(int) onNavigate;

  const _AdminHomeView({required this.onNavigate});

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

  void _showSwitchRoleBottomSheet(BuildContext context, WidgetRef ref) {
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

                            // Navigate to appropriate dashboard
                            if (!context.mounted) return;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.userData;

    String displayName = "Admin";
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
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.white,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              text: 'Hello ',
              style: const TextStyle(color: AppTheme.black, fontSize: 16),
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSwitchRoleBottomSheet(context, ref),
            icon: const Icon(Icons.swap_horiz_rounded, color: AppTheme.black),
            tooltip: 'Switch Role',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Management Operations'),
            const SizedBox(height: 16),
            _buildQuickActionGrid(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildActionItem(
          'Create Farm',
          Icons.add_home_work_rounded,
          Colors.orange,
          () => context.pushNamed('add-farm'),
        ),
        _buildActionItem(
          'Create Sheds',
          Icons.warehouse_rounded,
          Colors.teal,
          () => context.pushNamed('add-shed'),
        ),
        _buildActionItem(
          'Onboard Animals',
          Icons.pets_rounded,
          Colors.indigo,
          () => context.pushNamed('admin-onboard-animal'),
        ),
        _buildActionItem(
          'Allocate Animals',
          Icons.grid_on_rounded,
          Colors.green,
          () => context.push('/buffalo-allocation'),
        ),
        _buildActionItem(
          'Add Employee',
          Icons.person_add_rounded,
          Colors.blue,
          () => context.pushNamed('add-staff'),
        ),

        _buildActionItem(
          'Staff Directory',
          Icons.badge_rounded,
          Colors.blueGrey,
          () => onNavigate(3),
        ),
        _buildActionItem(
          'All Investors',
          Icons.people_alt_rounded,
          Colors.pink,
          () => context.pushNamed('investor-management'),
        ),
        _buildActionItem(
          'Medical Tickets',
          Icons.confirmation_number_rounded,
          Colors.red,
          () => onNavigate(2),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w900,
        color: AppTheme.dark,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _AdminFarmsView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AdminFarmsView> createState() => _AdminFarmsViewState();
}

class _AdminFarmsViewState extends ConsumerState<_AdminFarmsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminProvider.notifier).fetchFarms(page: 1),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _currentPage = 1;
    ref.read(adminProvider.notifier).fetchFarms(query: query, page: 1);
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

                            if (!context.mounted) return;
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

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 50) {
      final state = ref.read(adminProvider);
      if (!state.isLoading) {
        _currentPage++;
        ref
            .read(adminProvider.notifier)
            .fetchFarms(
              page: _currentPage,
              query: _searchController.text.trim(),
            );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final farms = adminState.farms;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search farms...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearch,
              )
            : const Text('Farms Management'),
        actions: [
          if (!_isSearching) // Removed role count check
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
                  _currentPage = 1;
                  ref.read(adminProvider.notifier).fetchFarms(page: 1);
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.add_business),
              onPressed: () => context.pushNamed('add-farm'),
            ),
        ],
      ),
      body: adminState.isLoading && farms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : farms.isEmpty
          ? _buildEmptyState()
          : NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: farms.length + (adminState.isLoading ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == farms.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final farm = farms[index];
                  return _buildFarmCard(farm);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No farms found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            text: 'Create First Farm',
            onPressed: () => context.pushNamed('add-farm'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmCard(Farm farm) {
    // Note: Farm model needs to be updated to include these fields for a complete refactor
    // For now, using fallbacks or zero values to maintain UI layout
    final shedsCount = farm.sheds.length;
    final managerName = farm.farmManager?.name ?? 'Unassigned';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.landscape,
                size: 60,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        farm.farmName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.slate,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      farm.location,
                      style: const TextStyle(
                        color: AppTheme.slate,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppTheme.slate),
                    const SizedBox(width: 4),
                    Text(
                      'Manager: $managerName',
                      style: const TextStyle(
                        color: AppTheme.slate,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFarmMiniStat(
                      Icons.pets,
                      '${farm.totalBuffaloesCount}',
                      'Animals',
                    ),
                    _buildFarmMiniStat(
                      Icons.warehouse,
                      '$shedsCount',
                      'Sheds',
                      onTap: () {
                        context.push(
                          '/farm-sheds',
                          extra: {'farmId': farm.id, 'farmName': farm.farmName},
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmMiniStat(
    IconData icon,
    String val,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppTheme.primary),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppTheme.slate),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminGlobalTicketsView extends StatelessWidget {
  final VoidCallback? onBack;
  const _AdminGlobalTicketsView({this.onBack});

  @override
  Widget build(BuildContext context) {
    return TicketManagementScreen(onBackPressed: onBack);
  }
}

class _AdminStaffView extends StatelessWidget {
  final VoidCallback? onBack;

  const _AdminStaffView({this.onBack});

  @override
  Widget build(BuildContext context) {
    return StaffManagementScreen(onBackPressed: onBack);
  }
}
