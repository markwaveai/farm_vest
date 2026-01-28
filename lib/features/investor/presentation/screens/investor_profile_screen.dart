// lib/features/customer/screens/profile_screen.dart
import 'dart:io';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/presentation/providers/buffalo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/investor/data/models/unit_response.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:farm_vest/core/services/biometric_service.dart';
import 'package:farm_vest/core/services/secure_storage_service.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/theme/theme_provider.dart';

class InvestorProfileScreen extends ConsumerStatefulWidget {
  const InvestorProfileScreen({super.key});

  @override
  ConsumerState<InvestorProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<InvestorProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  bool _removeProfileImage = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).userData;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _phoneController = TextEditingController(text: user?.mobile ?? '');

    _loadBiometricPreference();

    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshUserData();
    });
  }

  Future<void> _loadBiometricPreference() async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    final supported = await BiometricService.isBiometricAvailable();
    if (!mounted) return;
    setState(() {
      _isBiometricEnabled = enabled;
      _isBiometricSupported = supported;
    });
  }

  Future<void> _toggleBiometric(bool newValue) async {
    if (newValue) {
      final success = await BiometricService.authenticate();
      if (!mounted) return;

      if (success) {
        await SecureStorageService.enableBiometric(true);
        setState(() => _isBiometricEnabled = true);
      } else {
        final reason = BiometricService.lastError;
        Fluttertoast.showToast(
          msg: reason == null || reason.isEmpty
              ? 'Authentication failed'
              : 'Authentication failed: $reason',
        );
      }
    } else {
      final shouldDisable = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Disable App Lock'),
          content: const Text(
            'Are you sure you want to disable fingerprint lock?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (shouldDisable == true) {
        await SecureStorageService.enableBiometric(false);
        BiometricService.lock();
        setState(() => _isBiometricEnabled = false);
      }
    }
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
          String? finalImageUrlForApi;

          // Handle image operations
          if (_removeProfileImage) {
            // Delete existing image from Firebase
            final currentImageUrl = user.imageUrl;
            if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
              await authNotifier.deleteProfileImage(
                userId: user.mobile,
                filePath: currentImageUrl,
              );
            }
            // Set to empty for API
            finalImageUrlForApi = '';
          } else if (_profileImage != null) {
            // Upload new image
            final uploadedImageUrl = await authNotifier.uploadProfileImage(
              userId: user.mobile,
              filePath: _profileImage!.path,
            );
            finalImageUrlForApi = uploadedImageUrl;
          } else {
            // User didn't change image - check what's actually in Firebase now
            final currentFirebaseImageUrl = await authNotifier
                .getCurrentFirebaseImageUrl(user.mobile);
            finalImageUrlForApi = currentFirebaseImageUrl ?? '';
          }

          // Always prepare update data
          final updateData = <String, dynamic>{
            'name': _nameController.text,
            'email': _emailController.text,
            'address': _addressController.text,
          };

          // Always include imageUrl, even if empty
          updateData['imageUrl'] = finalImageUrlForApi ?? '';

          debugPrint('Sending to API - imageUrl: ${updateData['imageUrl']}');

          // Update user data via API
          final updatedUser = await authNotifier.updateUserdata(
            userId: user.mobile,
            extraFields: updateData,
          );

          if (updatedUser != null) {
            authNotifier.updateLocalUserData(updatedUser);
            if (mounted) {
              setState(() {
                _profileImage = null;
                _removeProfileImage = false;
                _isEditing = false;
              });
              Fluttertoast.showToast(msg: "Profile updated successfully");
            }
          } else {
            if (mounted) {
              Fluttertoast.showToast(msg: "Failed to update profile");
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

    // Aggressive sync for initial load or when userData arrives
    if (userData != null && !_isEditing) {
      if (_nameController.text.isEmpty && userData.name.isNotEmpty) {
        _nameController.text = userData.name;
      }
      if (_emailController.text.isEmpty && userData.email.isNotEmpty) {
        _emailController.text = userData.email;
      }
      if (_addressController.text.isEmpty &&
          (userData.address?.isNotEmpty ?? false)) {
        _addressController.text = userData.address!;
      }
      if (_phoneController.text.isEmpty && userData.mobile.isNotEmpty) {
        _phoneController.text = userData.mobile;
      }
    }

    // Listen for future updates
    ref.listen(authProvider, (previous, next) {
      if (next.userData != null && next.userData != previous?.userData) {
        if (!_isEditing) {
          _nameController.text = next.userData?.name ?? '';
          _emailController.text = next.userData?.email ?? '';
          _addressController.text = next.userData?.address ?? '';
          _phoneController.text = next.userData?.mobile ?? '';
        }
      }
    });

    final unitResponse = ref.watch(unitResponseProvider).value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isSaving ? null : _toggleEdit,
            tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(userData, isDark: isDark),
                const SizedBox(height: AppConstants.spacingL),

                // Profile Details
                _buildProfileForm(
                  userData,
                  unitResponse,
                  isDark: isDark,
                  theme: theme,
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Account Actions
                _buildAccountActions(isDark: isDark, theme: theme),
              ],
            ),
          ),
          if (_isSaving) ...[
            const ModalBarrier(dismissible: false, color: Colors.black26),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? userData, {required bool isDark}) {
    final remoteImageUrl = _removeProfileImage ? null : userData?.imageUrl;
    final hasImage =
        _profileImage != null ||
        (remoteImageUrl != null && remoteImageUrl.isNotEmpty);
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ClipOval(
                child: Container(
                  color: AppTheme.primary,
                  child: _profileImage != null
                      ? Image.file(_profileImage!, fit: BoxFit.cover)
                      : (remoteImageUrl != null && remoteImageUrl.isNotEmpty)
                      ? Image.network(
                          remoteImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Image not supported',
                                style: AppTheme.bodySmall,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
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
                  child: InkWell(
                    onTap: () {
                      if (hasImage) {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove Profile Photo'),
                            content: const Text(
                              'Are you sure you want to remove your profile photo?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _profileImage = null;
                                    _removeProfileImage = true;
                                  });
                                  // Don't call API here - wait for Save button
                                },
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        _showImageSourceSheet();
                      }
                    },
                    child: Icon(
                      hasImage ? Icons.delete_outline : Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          userData?.name ?? '',
          style: AppTheme.headingMedium.copyWith(
            color: isDark ? AppTheme.white : AppTheme.secondary,
          ),
        ),
        Text(
          userData?.email ?? '',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGrey),
        ),
      ],
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(ctx);

                  final file = await ref
                      .read(authProvider.notifier)
                      .pickProfileImage(source: ImageSource.gallery);

                  if (file != null && mounted) {
                    setState(() {
                      _profileImage = file;
                      _removeProfileImage = false;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Choose from camera'),
                onTap: () async {
                  Navigator.pop(ctx);

                  final file = await ref
                      .read(authProvider.notifier)
                      .pickProfileImage(source: ImageSource.camera);

                  if (file != null && mounted) {
                    setState(() {
                      _profileImage = file;
                      _removeProfileImage = false;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileForm(
    UserModel? userData,
    UnitResponse? unitResponse, {
    required bool isDark,
    required ThemeData theme,
  }) {
    DateTime? membershipSince;
    if (unitResponse?.overallStats?.memberSince != null) {
      membershipSince = DateTime.tryParse(
        unitResponse!.overallStats!.memberSince!,
      );
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
            theme: theme,
            isDark: isDark,
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            theme: theme,
            isDark: isDark,
            label: 'Email',
            controller: _emailController,
            icon: Icons.email,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            theme: theme,
            isDark: isDark,
            label: 'Phone',
            controller: _phoneController,
            icon: Icons.phone,
            enabled: false,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _buildFormField(
            theme: theme,
            isDark: isDark,
            label: 'Address',
            controller: _addressController,
            icon: Icons.location_on,
            maxLines: 2,
            enabled: _isEditing,
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Read-only fields
          _buildReadOnlyField(
            theme: theme,
            isDark: isDark,
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
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,

          //theme.colorScheme.onSurface.withValues(
          //alpha:  0.7,
          //),
        ),
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
        //border: const OutlineInputBorder(),
        //filled: !enabled,
        filled: true,
        // fillColor: enabled
        //     ? Colors.white
        //     : AppTheme.lightGrey.withValues(alpha: 0.3),
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
          //  AppTheme.bodySmall.copyWith(
          //   color: AppTheme.mediumGrey
          //   ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            //color: AppTheme.lightGrey.withValues(alpha: 0.3),
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.grey.shade400,
              // color: Colors.grey.shade400
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
                //style: AppTheme.bodyMedium
              ),
            ],
          ),
        ),
      ],
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

                            // Navigate to appropriate dashboard
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

  Widget _buildAccountActions({
    required bool isDark,
    required ThemeData theme,
  }) {
    final authState = ref.watch(authProvider);
    return Column(
      children: [
        if (authState.availableRoles.length > 1) ...[
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: theme.colorScheme.surface,
            leading: const Icon(Icons.swap_horiz, color: AppTheme.primary),
            title: const Text('Switch Role'),
            subtitle: Text(
              'Currently as ${_getRoleInfo(authState.role ?? UserType.customer)['label']}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showSwitchRoleBottomSheet,
          ),
          const SizedBox(height: 8),
        ],
        if (_isBiometricSupported)
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: theme.colorScheme.surface,
            leading: const Icon(Icons.fingerprint, color: AppTheme.primary),
            title: const Text('App Lock'),
            subtitle: const Text('Use biometric to unlock the app'),
            trailing: Switch(
              value: _isBiometricEnabled,
              onChanged: _toggleBiometric,
            ),
          ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: theme.colorScheme.surface,
          leading: Icon(
            theme.brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: AppTheme.primary,
          ),
          title: const Text('Dark Mode'),
          subtitle: Text(
            theme.brightness == Brightness.dark ? 'Enabled' : 'Disabled',
          ),
          trailing: Switch(
            value: theme.brightness == Brightness.dark,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          // tileColor: Colors.grey.shade50,
          tileColor: theme.colorScheme.surface,
          leading: const Icon(Icons.help_outline, color: AppTheme.primary),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => context.go('/support'),
        ),
        const SizedBox(height: 8),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //tileColor: Colors.grey.shade50,
          tileColor: theme.colorScheme.surface,
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
