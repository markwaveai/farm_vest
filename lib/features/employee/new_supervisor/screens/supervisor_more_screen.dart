import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class SupervisorMoreScreen extends ConsumerWidget {
  SupervisorMoreScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'.tr(ref)),
        content: Text('Are you sure you want to logout?'.tr(ref)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(ref)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Dismiss dialog first
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text('Logout'.tr(ref), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'.tr(ref)),
        content: Text('Are you sure you want to delete your account? This action is permanent and will remove all your data. You will be redirected to our website to complete the process.'.tr(ref)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(ref)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchURL(AppConstants.deleteAccountUrl);
            },
            child: Text('Delete'.tr(ref), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).userData;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Menu'.tr(ref))),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child:
                            (user?.imageUrl != null &&
                                user!.imageUrl!.isNotEmpty)
                            ? ClipOval(
                                child: Image.network(
                                  user.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.person,
                                        size: 35,
                                        color: AppTheme.primary,
                                      ),
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 35,
                                color: AppTheme.primary,
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Supervisor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.mobile ?? '',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/profile'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: AppTheme.primary),
                      ),
                      child: Text('View / Edit Profile'.tr(ref)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.add_business_rounded,
              title: 'Buffalo Onboarding'.tr(ref),
              onTap: () => context.go('/onboard-animal'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_active,
              title: 'Notifications'.tr(ref),
              onTap: () => context.go('/notifications'),
            ),
            _buildMenuItem(
              context,
              icon: Icons.security,
              title: 'Security Settings'.tr(ref),
              onTap: () {},
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support'.tr(ref),
              onTap: () {},
            ),
            SizedBox(height: 24),

            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Logout'.tr(ref),
              color: Colors.red,
              onTap: () => _showLogoutDialog(context, ref),
            ),
            _buildMenuItem(
              context,
              icon: Icons.delete,
              title: 'Delete Account'.tr(ref),
              color: Colors.red,
              onTap: () => _showDeleteAccountDialog(context),
            ),

            SizedBox(height: 100), // Spacing for bottom nav
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
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color == Colors.red
                ? Colors.red
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
