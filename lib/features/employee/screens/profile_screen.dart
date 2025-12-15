import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/navigation_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    // Load existing profile data
    _nameController.text = 'Uma Sankar';
    _phoneController.text = '+91 6305447441';
    _emailController.text = 'umaSankar@farmvest.com';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/supervisor-dashboard',
          ),
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
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
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
                        color: AppTheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusL,
                        ),
                      ),
                      child: const Text(
                        'Supervisor',
                        style: TextStyle(
                          color: AppTheme.primary,
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
                        controller: _phoneController,
                        enabled: _isEditing,
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
            if (!_isEditing) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle password change
                    _showChangePasswordDialog();
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text('Change Password'),
                ),
              ),
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
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: confirmPasswordController,
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
      ),
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
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
