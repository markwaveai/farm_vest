import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SupervisorMoreScreen extends ConsumerWidget {
  const SupervisorMoreScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userData;

    return Scaffold(
      backgroundColor: AppTheme.grey,
      appBar: AppBar(title: const Text('Menu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Supervisor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.mobile ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.add_business_rounded,
              title: 'Buffalo Onboarding',
              onTap: () => context.go('/onboard-animal'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_active,
              title: 'Notifications',
              onTap: () => context.go('/notifications'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.security,
              title: 'Security Settings',
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 24),

            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red,
              onTap: () => _showLogoutDialog(context, ref),
            ),

            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppTheme.primary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color == Colors.red ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
