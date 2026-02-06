import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/doctors/providers/doctors_provider.dart';
import 'package:farm_vest/features/doctors/screens/profile_menu.dart';
import 'package:farm_vest/features/doctors/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dashboard_stat_card.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  int _currentIndex = 4;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(doctorsProvider.notifier).fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(doctorsProvider);
    final healthCounts = healthState.healthCounts;
    final vaccinationCounts = healthState.vaccinationCounts;

    final authState = ref.watch(authProvider);
    final user = authState.userData;

    String displayName = "Dr. ";
    if (user != null &&
        (user.firstName.isNotEmpty || user.lastName.isNotEmpty)) {
      final fname = user.firstName.isNotEmpty
          ? user.firstName[0].toUpperCase() + user.firstName.substring(1)
          : "";
      final lname = user.lastName.isNotEmpty
          ? user.lastName[0].toUpperCase() + user.lastName.substring(1)
          : "";
      displayName += "$fname $lname".trim();
    } else if (user != null && user.name.isNotEmpty) {
      displayName += user.name;
    } else {
      displayName += "Sankar"; // Fallback/Default
    }

    // Trailing comma for the text span
    displayName = "$displayName,";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.white,
      drawer: const ProfileMenuScreen(),
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppTheme.black,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              context.go('/admin-dashboard');
            }
          },
        ),

        actions: [
          if (ref.watch(authProvider).availableRoles.length > 1)
            IconButton(
              onPressed: () => _showSwitchRoleBottomSheet(),
              icon: const Icon(Icons.swap_horiz_rounded, color: AppTheme.black),
              tooltip: 'Switch Role',
            ),
          IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.black),

            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(doctorsProvider.notifier).fetchTickets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                title: 'Buffalo Health Tickets',
                ticketType: 'HEALTH',
              ),

              // _sectionHeader(title: 'Buffalo Health Tickets'),
              const SizedBox(height: 12),
              _grid([
                DashboardStatCard(
                  title: 'Total Tickets',
                  value: healthCounts['total'].toString().padLeft(2, '0'),
                  iconWidget: Image.asset(
                    'assets/icons/buffalo_head.png',
                    width: 24,
                    height: 28,
                  ),
                  backgroundColor: AppTheme.primary,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'All', 'type': 'HEALTH'},
                  ),
                ),
                DashboardStatCard(
                  title: 'Pending Tickets',
                  value: healthCounts['pending'].toString().padLeft(2, '0'),
                  iconWidget: Image.asset(
                    'assets/icons/buffalo_head.png',
                    width: 24,
                    height: 24,
                    color: AppTheme.white,
                  ),
                  backgroundColor: AppTheme.orange,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'Pending', 'type': 'HEALTH'},
                  ),
                ),
                DashboardStatCard(
                  title: 'In Progress Tickets',
                  value: healthCounts['inProgress'].toString().padLeft(2, '0'),
                  iconWidget: Image.asset(
                    'assets/icons/buffalo_head.png',
                    width: 24,
                    height: 24,
                    color: AppTheme.white,
                  ),
                  backgroundColor: AppTheme.lightPrimary,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'In progress', 'type': 'HEALTH'},
                  ),
                ),
                DashboardStatCard(
                  title: 'Completed Tickets',
                  value: healthCounts['completed'].toString().padLeft(2, '0'),
                  iconWidget: Image.asset(
                    'assets/icons/buffalo_head.png',
                    width: 24,
                    height: 24,
                    color: AppTheme.white,
                  ),
                  backgroundColor: AppTheme.lightGreen,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'Completed', 'type': 'HEALTH'},
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _sectionHeader(
                title: 'Vaccination Tickets',
                ticketType: 'VACCINATION',
              ),

              // _sectionHeader(title: 'Vaccination Tickets'),
              const SizedBox(height: 12),
              _grid([
                DashboardStatCard(
                  title: 'Total Tickets',
                  value: vaccinationCounts['total'].toString().padLeft(2, '0'),
                  iconWidget: Image.asset(
                    'assets/icons/injection.png',
                    width: 24,
                    height: 24,
                  ),
                  backgroundColor: AppTheme.successGreen,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'All', 'type': 'VACCINATION'},
                  ),
                ),
                DashboardStatCard(
                  title: 'Pending Tickets',
                  value: vaccinationCounts['pending'].toString().padLeft(
                    2,
                    '0',
                  ),
                  iconWidget: Image.asset(
                    'assets/icons/injection.png',
                    width: 24,
                    height: 24,
                  ),
                  backgroundColor: AppTheme.orange,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'Pending', 'type': 'VACCINATION'},
                  ),
                ),
                DashboardStatCard(
                  title: 'In Progress Tickets',
                  value: vaccinationCounts['inProgress'].toString().padLeft(
                    2,
                    '0',
                  ),
                  iconWidget: Image.asset(
                    'assets/icons/injection.png',
                    width: 24,
                    height: 24,
                  ),
                  backgroundColor: AppTheme.lightPrimary,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'In progress', 'type': 'VACCINATION'},
                  ),
                ),
                DashboardStatCard(
                  title: 'Completed Tickets',
                  value: vaccinationCounts['completed'].toString().padLeft(
                    2,
                    '0',
                  ),
                  iconWidget: Image.asset(
                    'assets/icons/injection.png',
                    width: 28,
                    height: 28,
                    color: AppTheme.white,
                  ),
                  backgroundColor: AppTheme.lightGreen,
                  isLoading: healthState.isLoading,
                  onTap: () => context.push(
                    '/all-health-tickets',
                    extra: {'filter': 'Completed', 'type': 'VACCINATION'},
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            context.push(
              '/all-health-tickets',
              extra: {'filter': 'All', 'type': 'HEALTH'},
            );
          } else if (index == 1) {
            context.push('/vaccination-screen');
          } else if (index == 3) {
            context.push('/buffalo-profile');
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = 4);
          context.go('/doctor-dashboard');
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
            child: Image.asset('assets/icons/home.png', color: AppTheme.white),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    String? badge,
    required String ticketType,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            if (ticketType == 'VACCINATION') {
              context.push('/vaccination-screen');
            } else {
              context.push(
                '/all-health-tickets',
                extra: {'filter': 'All', 'type': 'HEALTH'},
              );
            }
          },

          style: TextButton.styleFrom(
            backgroundColor: AppTheme.darkPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'View All Tickets',
            style: TextStyle(color: AppTheme.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _grid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: children,
    );
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
                        color: isSelected ? role.color : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected ? role.color.withOpacity(0.05) : null,
                    leading: CircleAvatar(
                      backgroundColor: role.color.withOpacity(0.1),
                      child: Icon(role.icon, color: role.color),
                    ),
                    title: Text(
                      role.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: role.color)
                        : const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
