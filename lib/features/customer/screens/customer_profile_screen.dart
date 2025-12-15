// lib/features/customer/screens/profile_screen.dart
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  // Sample customer data - in a real app, this would come from an API or state management
  final Map<String, String> _customerData = {
    'name': 'Rajesh Kumar',
    'email': 'rajesh.kumar@example.com',
    'phone': '+91 98765 43210',
    'address': '123 Farm Villa, Bangalore, Karnataka - 560001',
    'membershipSince': 'Jan 2023',
    'totalInvested': '₹25,00,000',
    'currentValuation': '₹28,50,000',
  };

  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/customer-dashboard',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: AppConstants.spacingL),

            // Profile Details
            _buildProfileForm(),

            const SizedBox(height: AppConstants.spacingL),

            // Account Actions
            _buildAccountActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(_customerData['name']!, style: AppTheme.headingMedium),
        Text(
          _customerData['email']!,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGrey),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            label: 'Full Name',
            value: _customerData['name']!,
            icon: Icons.person,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            label: 'Email',
            value: _customerData['email']!,
            icon: Icons.email,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            label: 'Phone',
            value: _customerData['phone']!,
            icon: Icons.phone,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            label: 'Address',
            value: _customerData['address']!,
            icon: Icons.location_on,
            maxLines: 2,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Read-only fields
          _buildReadOnlyField(
            label: 'Membership Since',
            value: _customerData['membershipSince']!,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildReadOnlyField(
            label: 'Total Invested',
            value: _customerData['totalInvested']!,
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildReadOnlyField(
            label: 'Current Valuation',
            value: _customerData['currentValuation']!,
            icon: Icons.assessment,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String value,
    required IconData icon,
    int maxLines = 1,
    bool enabled = false,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: AppTheme.lightGrey.withValues(alpha: 0.3),
      ),
      maxLines: maxLines,
      readOnly: !enabled,
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
          leading: const Icon(Icons.lock, color: AppTheme.primary),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showChangePasswordDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline, color: AppTheme.primary),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.go('/support'),
        ),
        ListTile(
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

  void _toggleEdit() {
    if (_isEditing) {
      if (_formKey.currentState!.validate()) {
        // Save changes here
        ToastUtils.showSuccess(context, 'Profile updated successfully');
      } else {
        return;
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
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
              ToastUtils.showSuccess(context, 'Password updated successfully');
            },
            child: const Text('Update Password'),
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              context.go('/login');
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
