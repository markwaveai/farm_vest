import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvestorShell extends StatefulWidget {
  final Widget child;

  const InvestorShell({super.key, required this.child});

  @override
  State<InvestorShell> createState() => _InvestorShellState();
}

class _InvestorShellState extends State<InvestorShell> {
  int _currentIndex = 0;

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

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'My Buffaloes';
      case 1:
        return 'Asset Valuation';
      case 2:
        return 'Live CCTV';
      case 3:
        return 'Revenue';
      case 4:
        return 'My Profile';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
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
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipPath(
          clipper: CurvedBottomNavClipper(),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.secondary,
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            elevation: 0,
            items: [
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
                icon: Container(),
                activeIcon: Container(),
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
        ),
      ),
      floatingActionButton: Container(
        height: 65,
        width: 65,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppTheme.errorRed,
              AppTheme.errorRed.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32.5),
            onTap: () => _onItemTapped(2),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _currentIndex == 2 ? Icons.videocam : Icons.videocam_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                    color: AppTheme.white.withOpacity(0.8),
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
              context.pop(); // Close drawer
              context.go('/customer-dashboard');
            },
          ),

          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppTheme.primary),
            title: const Text('Monthly Visits'),
            onTap: () {
              context.pop();
              context.push('/monthly-visits');
            },
          ),

          ListTile(
            leading: const Icon(Icons.videocam, color: AppTheme.primary),
            title: const Text('Live CCTV'),
            onTap: () {
              context.pop();
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
              context.pop();
              context.push('/health-records');
            },
          ),

          ListTile(
            leading: const Icon(Icons.assessment, color: AppTheme.primary),
            title: const Text('Revenue'),
            onTap: () {
              context.pop();
              context.push('/revenue');
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primary,
            ),
            title: const Text('Asset Valuation'),
            onTap: () {
              context.pop();
              context.push('/asset-valuation');
            },
          ),

          const Divider(),

          // Support Section
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppTheme.primary),
            title: const Text('Help & Support'),
            onTap: () {
              context.pop();
              context.push('/support');
            },
          ),

          // Profile Section
          ListTile(
            leading: const Icon(Icons.person, color: AppTheme.primary),
            title: const Text('My Profile'),
            onTap: () {
              context.pop();
              context.push('/customer-profile');
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
              context.pop(); // Close drawer
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop(); // Close dialog
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
