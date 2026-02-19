import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/employee_bottom_navigation.dart';
import 'package:farm_vest/core/widgets/notification_bell_button.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/features/doctors/widgets/buffalo_profile_view.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/alert_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:shimmer/shimmer.dart';

import 'package:farm_vest/features/employee/new_supervisor/widgets/supervisor_views.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/onboard_animal_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/providers/farm_manager_provider.dart';

class NewSupervisorDashboard extends ConsumerStatefulWidget {
  const NewSupervisorDashboard({super.key});

  @override
  ConsumerState<NewSupervisorDashboard> createState() =>
      _NewSupervisorDashboardState();
}

class _NewSupervisorDashboardState
    extends ConsumerState<NewSupervisorDashboard> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dashboardState = ref.watch(supervisorDashboardProvider);

    final authState = ref.watch(authProvider);
    final user = authState.userData;

    final farmName = user?.farmName ?? "Farm";
    final shedName = user?.shedName ?? "Shed";
    final farmLocation = user?.farmLocation ?? "Location";
    final displayName = user?.firstName ?? "Supervisor";

    String appBarTitle = 'Dashboard';
    bool showProfileInfo = _currentIndex == 4;

    switch (_currentIndex) {
      case 0:
        appBarTitle = 'Milk Entry';
        break;
      case 1:
        appBarTitle = 'Alerts';
        break;
      case 2:
        appBarTitle = 'Buffalo Onboarding';
        break;
      case 3:
        appBarTitle = 'Buffalo Profile';
        break;
      case 4:
        appBarTitle = "Hello, $displayName";
        break;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        toolbarHeight: showProfileInfo ? screenWidth * 0.22 : 64,
        automaticallyImplyLeading: false,
        leading: _currentIndex != 4
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  if (_currentIndex == 2) {
                    final currentOrder = ref
                        .read(farmManagerProvider)
                        .currentOrder;
                    if (currentOrder != null) {
                      ref.read(farmManagerProvider.notifier).clearOrder();
                      return;
                    }
                  }
                  setState(() => _currentIndex = 4);
                },
              )
            : null,
        centerTitle: false,
        title: showProfileInfo
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appBarTitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$farmName • $shedName",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Location: $farmLocation",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              )
            : Text(
                appBarTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          if (authState.availableRoles.length > 1)
            IconButton(
              onPressed: () => _showSwitchRoleBottomSheet(context, ref),
              icon: const Icon(
                Icons.swap_horiz_rounded,
                color: AppTheme.primary,
              ),
              tooltip: 'Switch Role',
            ),
          NotificationBellButton(
            fallbackRoute: '/supervisor-dashboard',
            iconColor: AppTheme.primary,
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const BulkMilkEntryView(), // 0
          const SupervisorAlertsView(), // 1
          const OnboardAnimalScreen(hideAppBar: true), // 2
          const BuffaloProfileView(), // 3
          _buildDashboardContent(dashboardState, screenWidth, user), // 4
        ],
      ),
      bottomNavigationBar: EmployeeBottomNavigation(
        role: UserType.supervisor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = 4);
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

  Widget _buildDashboardContent(
    SupervisorDashboardState dashboardState,
    double screenWidth,
    dynamic user,
  ) {
    if (dashboardState.isLoading) {
      return _buildLoadingShimmer(context);
    }

    if (dashboardState.error != null) {
      return Center(child: Text(dashboardState.error!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CustomCard(
                color: AppTheme.primary,
                type: DashboardCardType.priority,
                onTap: () {
                  setState(() => _currentIndex = 3);
                },
                child: _buildStatContent(
                  context,
                  Icons.pets,
                  dashboardState.stats.totalAnimals,
                  'Total Animals',
                  AppTheme.primary,
                ),
              ),
              CustomCard(
                color: AppTheme.lightSecondary,
                //color: AppTheme.errorRed,
                type: DashboardCardType.priority,
                child: _buildStatContent(
                  context,
                  Icons.water_drop,
                  dashboardState.stats.milkToday,
                  'Milk Today',
                  AppTheme.lightSecondary,
                ),
              ),

              CustomCard(
                color: AppTheme.errorRed,
                //color: AppTheme.warningOrange,
                // color: AppTheme.darkGrey,
                //color: Colors.pink,
                type: DashboardCardType.priority,
                onTap: () {
                  final shedId = int.tryParse(user?.shedId ?? '');
                  if (shedId != null) {
                    context.push(
                      '/buffalo-allocation',
                      extra: {'shedId': shedId},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No shed assigned to your profile'),
                      ),
                    );
                  }
                },
                child: _buildStatContent(
                  context,
                  Icons.hourglass_empty_rounded,
                  dashboardState.stats.pendingAllocations,
                  'Pending Allocation',
                  AppTheme.errorRed,
                  // AppTheme.darkGrey
                  //Colors.pink,
                ),
              ),
              CustomCard(
                color: Colors.purple,
                type: DashboardCardType.priority,
                onTap: () => context.push(
                  '/all-health-tickets',
                  extra: {'showActions': false},
                ),
                child: _buildStatContent(
                  context,
                  Icons.confirmation_number_outlined,
                  dashboardState.stats.allTicketsCount,
                  'Total Tickets',
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (dashboardState.unallocatedAnimals.isNotEmpty) ...[
            Text(
              "Unallocated Animals",
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dashboardState.unallocatedAnimals.length,
                itemBuilder: (context, index) {
                  final animal = dashboardState.unallocatedAnimals[index];
                  return _buildUnallocatedAnimalCard(
                    context,
                    animal,
                    user?.shedId,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CustomCard(
                type: DashboardCardType.quickAction,
                onTap: () => setState(() => _currentIndex = 0),
                child: _buildQuickActionContent(
                  context,
                  Icons.water_drop,
                  'Milk Entry',
                  Colors.orange,
                ),
              ),
              CustomCard(
                type: DashboardCardType.quickAction,
                onTap: () => showQuickActionDialog(
                  context: context,
                  type: QuickActionType.healthTicket,
                  ref: ref,
                ),
                child: _buildQuickActionContent(
                  context,
                  Icons.medical_services,
                  'Health ticket',
                  AppTheme.primary,
                ),
              ),
              CustomCard(
                type: DashboardCardType.quickAction,
                onTap: () => setState(() => _currentIndex = 1),
                child: _buildQuickActionContent(
                  context,
                  Icons.notification_important_rounded,
                  'Alerts & Issues',
                  AppTheme.warningOrange,
                ),
              ),
              CustomCard(
                type: DashboardCardType.quickAction,
                onTap: () => showQuickActionDialog(
                  context: context,
                  type: QuickActionType.locateAnimal,
                  ref: ref,
                ),
                child: _buildQuickActionContent(
                  context,
                  Icons.search,
                  'Locate Animal',
                  Colors.orange,
                ),
              ),
              CustomCard(
                type: DashboardCardType.quickAction,
                onTap: () {
                  final shedId = int.tryParse(user?.shedId ?? '');
                  if (shedId != null) {
                    context.push(
                      '/buffalo-allocation',
                      extra: {'shedId': shedId},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No shed assigned to your profile'),
                      ),
                    );
                  }
                },
                child: _buildQuickActionContent(
                  context,
                  Icons.grid_view_rounded,
                  'Shed Allocation',
                  AppTheme.primary,
                ),
              ),
              CustomCard(
                type: DashboardCardType.quickAction,
                onTap: () => context.push('/onboard-animal'),
                child: _buildQuickActionContent(
                  context,
                  Icons.add_business_rounded,
                  'Buffalo Onboarding',
                  AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: List.generate(4, (index) => const ShimmerCard()),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Shimmer.fromColors(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!
                : Colors.grey[300]!,
            highlightColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[100]!,
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width - 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: List.generate(4, (index) => const ShimmerCard()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatContent(
    BuildContext context,
    IconData icon,
    String subtitle,
    String title,
    Color iconColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.055;
    final subtitleFontSize = screenWidth * 0.038;
    final titleFontSize = screenWidth * 0.028;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionContent(
    BuildContext context,
    IconData icon,
    String label,
    Color iconColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;
    final textSize = screenWidth * 0.032;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: textSize,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
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
              Text(
                'Switch Active Role',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose which portal you want to access',
                style: TextStyle(color: Theme.of(context).hintColor),
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

                            if (!context.mounted) return;
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
                            ? role.color
                            : Theme.of(context).dividerColor,
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
                        color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildUnallocatedAnimalCard(
    BuildContext context,
    Map<String, dynamic> animal,
    String? currentShedId,
  ) {
    final rfid = animal['rfid'] ?? 'No RFID';
    final investor = animal['investor_name'] ?? 'Unknown';

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final shedId = int.tryParse(currentShedId ?? '');
            if (shedId != null) {
              context.push(
                '/buffalo-allocation',
                extra: {'shedId': shedId, 'animalId': animal['rfid']},
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No shed assigned to your profile'),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).dividerColor
                    : AppTheme.errorRed.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'UNALLOCATED',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorRed,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rfid,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  investor,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).hintColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
