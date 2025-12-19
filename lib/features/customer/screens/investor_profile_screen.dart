// lib/features/customer/screens/profile_screen.dart
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/auth/models/user_model.dart';
import 'package:farm_vest/features/auth/providers/auth_provider.dart';
import 'package:farm_vest/features/customer/providers/buffalo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/customer/models/unit_response.dart';
import 'package:go_router/go_router.dart';

class InvestorProfileScreen extends ConsumerStatefulWidget {
  const InvestorProfileScreen({super.key});

  @override
  ConsumerState<InvestorProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<InvestorProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).userData;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _phoneController = TextEditingController(text: user?.mobile ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      // Save logic
      if (_formKey.currentState!.validate()) {
        setState(() => _isSaving = true);
        final authNotifier = ref.read(authProvider.notifier);
        final user = ref.read(authProvider).userData;

        if (user != null) {
          final updatedUser = await authNotifier.updateUserdata(
            userId: user.mobile,
            extraFields: {
              'name': _nameController.text,
              'email': _emailController.text,
              'address': _addressController.text,
            },
          );

          if (updatedUser != null) {
            authNotifier.updateLocalUserData(updatedUser);
            if (mounted) {
              setState(() => _isEditing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update profile')),
              );
            }
          }
        }
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userData = authState.userData;
    final unitResponse = ref.watch(unitResponseProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEdit,
              tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(userData),
            const SizedBox(height: AppConstants.spacingL),

            // Profile Details
            _buildProfileForm(userData, unitResponse),

            const SizedBox(height: AppConstants.spacingL),

            // Account Actions
            _buildAccountActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? userData) {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            if (_isEditing)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(userData?.name ?? '', style: AppTheme.headingMedium),
        Text(
          userData?.email ?? '',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGrey),
        ),
      ],
    );
  }

  Widget _buildProfileForm(UserModel? userData, UnitResponse? unitResponse) {
    DateTime? membershipSince;
    if (unitResponse?.orders?.isNotEmpty ?? false) {
      final dates = unitResponse!.orders!
          .where((o) => o.placedAt != null)
          .map(
            (o) => o.placedAt != null && o.placedAt!.isNotEmpty
                ? DateTime.parse(o.placedAt!)
                : DateTime.now(),
          )
          .toList();
      if (dates.isNotEmpty) {
        membershipSince = dates.reduce((a, b) => a.isBefore(b) ? a : b);
      }
    }

    final formattedDate = membershipSince != null
        ? '${membershipSince.day}/${membershipSince.month}/${membershipSince.year}'
        : 'N/A';
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            label: 'Phone',
            controller: _phoneController,
            icon: Icons.phone,
            enabled: false,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            label: 'Address',
            controller: _addressController,
            icon: Icons.location_on,
            maxLines: 2,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Read-only fields
          _buildReadOnlyField(
            label: 'Membership Since',
            value: formattedDate,
            icon: Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool enabled = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled
            ? Colors.white
            : AppTheme.lightGrey.withValues(alpha: 0.3),
      ),
      maxLines: maxLines,
      readOnly: !enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGrey),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(value, style: AppTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: Colors.grey.shade50,
          leading: const Icon(Icons.help_outline, color: AppTheme.primary),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.go('/support'),
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: Colors.grey.shade50,
          leading: const Icon(Icons.logout, color: AppTheme.errorRed),
          title: const Text(
            'Logout',
            style: TextStyle(color: AppTheme.errorRed),
          ),
          onTap: _showLogoutDialog,
        ),
      ],
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
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
