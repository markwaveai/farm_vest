import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final UserModel? user;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final bool isEditing;
  final bool isDark;
  final String membershipDate;

  const ProfileInfoCard({
    super.key,
    required this.formKey,
    required this.user,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.isEditing,
    required this.isDark,
    required this.membershipDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField(
            theme: theme,
            isDark: isDark,
            label: 'Full Name',
            controller: nameController,
            icon: Icons.person,
            enabled: isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            theme: theme,
            isDark: isDark,
            label: 'Email',
            controller: emailController,
            icon: Icons.email,
            enabled: isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            theme: theme,
            isDark: isDark,
            label: 'Phone',
            controller: phoneController,
            icon: Icons.phone,
            enabled: false,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            theme: theme,
            isDark: isDark,
            label: 'Address',
            controller: addressController,
            icon: Icons.location_on,
            maxLines: 2,
            enabled: isEditing,
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Read-only fields
          _buildReadOnlyField(
            theme: theme,
            isDark: isDark,
            label: 'Membership Since',
            value: membershipDate,
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
    required bool isDark,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.grey.shade600,
        ),
        prefixIcon: Icon(icon, color: AppTheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surface
            : theme.colorScheme.onSurface.withValues(alpha: 0.03),
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
    required ThemeData theme,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppTheme.mediumGrey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.grey.shade400,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
