import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';

import 'package:farm_vest/core/utils/app_enums.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final user = ref.read(authProvider).userData;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.mobile ?? '';
    _emailController.text = user?.email ?? '';
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
    final availableRoles = ref.read(authProvider).availableRoles;
    final currentRole = ref.read(authProvider).role;

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentRole = authState.role;
    final roleInfo = _getRoleInfo(currentRole ?? UserType.customer);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              NavigationHelper.safePopOrNavigate(context, fallbackRoute: '/'),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.primary,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: AppTheme.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // Handle profile picture change
                                  ToastUtils.showInfo(
                                    context,
                                    'Profile picture update functionality',
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingM,
                        vertical: AppConstants.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: (roleInfo['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusL,
                        ),
                      ),
                      child: Text(
                        roleInfo['label'] as String,
                        style: TextStyle(
                          color: roleInfo['color'] as Color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Personal Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: AppTheme.headingMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Phone
                      TextFormField(
                        // controller: _phoneController,
                        initialValue: _phoneController.text,
                        enabled: false,
                        readOnly: true,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Work Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Work Information',
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    _buildInfoRow('Employee ID', 'SUP-001'),
                    _buildInfoRow('Department', 'Farm Operations'),
                    _buildInfoRow('Farm Location', 'Section A & B'),
                    _buildInfoRow('Joined Date', 'January 15, 2022'),
                    _buildInfoRow('Reporting Manager', 'Farm Manager'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // MarkWave Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MarkWave Information',
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    _buildInfoRow('Company', 'MarkWave Technologies'),
                    _buildInfoRow('Office Location', 'Bangalore, Karnataka'),
                    _buildInfoRow('Support Email', 'support@markwave.com'),
                    _buildInfoRow('Emergency Contact', '+91 98765 43210'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Statistics',
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Tickets Raised',
                            '47',
                            Icons.report_problem,
                            AppTheme.warningOrange,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: _buildStatCard(
                            'Issues Resolved',
                            '43',
                            Icons.check_circle,
                            AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingM),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Animals Managed',
                            '15',
                            Icons.pets,
                            AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                        Expanded(
                          child: _buildStatCard(
                            'Health Reports',
                            '128',
                            Icons.medical_services,
                            AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Action Buttons
            // Only show switch role option if the user has multiple roles
            if (authState.availableRoles.length > 1) ...[
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.swap_horiz,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Switch Active Role'),
                  subtitle: Text('Currently as ${roleInfo['label']}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showSwitchRoleBottomSheet,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
            ],

            const SizedBox(height: AppConstants.spacingM),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGrey),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppConstants.iconL),
          const SizedBox(height: AppConstants.spacingS),
          Text(value, style: AppTheme.headingMedium.copyWith(color: color)),
          Text(title, style: AppTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = false;
      });

      ToastUtils.showSuccess(context, 'Profile updated successfully!');
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showLogoutDialog() {
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
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Current Password',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ToastUtils.showSuccess(context, 'Password changed successfully!');
          },
          child: const Text('Change'),
        ),
      ],
    );
  }
}
