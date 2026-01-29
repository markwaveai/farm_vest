import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/utils/app_enums.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvestorShell extends ConsumerStatefulWidget {
  final Widget child;

  const InvestorShell({super.key, required this.child});

  @override
  ConsumerState<InvestorShell> createState() => _InvestorShellState();
}

class _InvestorShellState extends ConsumerState<InvestorShell> {
  int _currentIndex = 0;

  int? _indexForLocation(String location) {
    if (location.startsWith('/customer-dashboard')) return 0;
    if (location.startsWith('/asset-valuation')) return 1;
    if (location.startsWith('/cctv-live')) return 2;
    if (location.startsWith('/revenue')) return 3;
    if (location.startsWith('/customer-profile')) return 4;
    return null;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/customer-dashboard');
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userData = authState.userData;

    final location = GoRouterState.of(context).uri.path;
    final idx = _indexForLocation(location);
    if (idx != null && idx != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _currentIndex = idx);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }

        if (_currentIndex != 0) {
          _onItemTapped(0);
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _currentIndex == 4
            ? null
            : AppBar(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                centerTitle: false, // Move logo to corner (left)
                titleSpacing: 16,
                title: Image.asset(
                  'assets/images/farmvest_logo.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
                actions: [
                  if (ref.watch(authProvider).availableRoles.length > 1)
                    IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded),
                      onPressed: _showSwitchRoleBottomSheet,
                      tooltip: 'Switch Role',
                    ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push(
                      '/notifications',
                      extra: {'fallbackRoute': '/customer-dashboard'},
                    ),
                  ),
                  // Profile icon in top right
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () => context.push('/customer-profile'),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child:
                            userData?.imageUrl != "" &&
                                userData?.imageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  userData!.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 24,
                                      color: AppTheme.primary,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 24,
                                color: AppTheme.primary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
        // drawer: _buildDrawer(userData), // Removed side menu
        body: widget.child,
      ),
    );
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
}

class CurvedBottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = 35.0;
    final notchCenter = size.width / 2;
    final navBarHeight = size.height;

    // Start from top-left corner
    path.moveTo(0, 0);

    // Draw line to the start of the notch
    path.lineTo(notchCenter - notchRadius - 10, 0);

    // Create the notch curve
    path.quadraticBezierTo(
      notchCenter - notchRadius,
      0,
      notchCenter - notchRadius,
      5,
    );

    // Create the bottom curve of the notch
    path.quadraticBezierTo(
      notchCenter - notchRadius,
      notchRadius + 3,
      notchCenter,
      notchRadius + 6,
    );

    path.quadraticBezierTo(
      notchCenter + notchRadius,
      notchRadius + 3,
      notchCenter + notchRadius,
      5,
    );

    // Complete the notch curve
    path.quadraticBezierTo(
      notchCenter + notchRadius,
      0,
      notchCenter + notchRadius + 5,
      0,
    );

    // Draw line to the top-right corner
    path.lineTo(size.width, 0);

    // Draw the rest of the rectangle
    path.lineTo(size.width, navBarHeight);
    path.lineTo(0, navBarHeight);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
