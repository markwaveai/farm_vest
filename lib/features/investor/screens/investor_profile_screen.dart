// lib/features/customer/screens/profile_screen.dart
import 'dart:io';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/auth/models/user_model.dart';
import 'package:farm_vest/features/auth/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/providers/buffalo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/investor/models/unit_response.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/services/secure_storage_service.dart';

class InvestorProfileScreen extends ConsumerStatefulWidget {
  const InvestorProfileScreen({super.key});

  @override
  ConsumerState<InvestorProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<InvestorProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).userData;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _phoneController = TextEditingController(text: user?.mobile ?? '');

    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    if (!mounted) return;
    setState(() => _isBiometricEnabled = enabled);
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
          content:
              const Text('Are you sure you want to disable fingerprint lock?'),
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
          String? uploadedImageUrl;
          if (_profileImage != null) {
            uploadedImageUrl = await authNotifier.uploadProfileImage(
              userId: user.mobile,
              filePath: _profileImage!.path,
            );
          }

          final updatedUser = await authNotifier.updateUserdata(
            userId: user.mobile,
            extraFields: {
              'name': _nameController.text,
              'email': _emailController.text,
              'address': _addressController.text,
              if (uploadedImageUrl != null) 'image_url': uploadedImageUrl,
            },
          );

          if (updatedUser != null) {
            authNotifier.updateLocalUserData(updatedUser);
            if (mounted) {
              setState(() => _isEditing = false);
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
    final unitResponse = ref.watch(unitResponseProvider).value;
 final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            _buildProfileForm(userData, unitResponse,isDark: isDark,theme: theme),

            const SizedBox(height: AppConstants.spacingL),

            // Account Actions
            _buildAccountActions(isDark: isDark,theme: theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? userData) {
    final remoteImageUrl = userData?.imageUrl;
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primary,
              backgroundImage:
                  _profileImage != null
                      ? FileImage(_profileImage!)
                      : (remoteImageUrl != null && remoteImageUrl.isNotEmpty)
                          ? NetworkImage(remoteImageUrl)
                          : null,
              child: (_profileImage == null) &&
                      (remoteImageUrl == null || remoteImageUrl.isEmpty)
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
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
                      _showImageSourceSheet();
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
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

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      if (!mounted) return;
      setState(() => _profileImage = File(image.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null) return;
      if (!mounted) return;
      setState(() => _profileImage = File(image.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    }
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
                  Navigator.of(ctx).pop();
                  await _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Choose from camera'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileForm(UserModel? userData, UnitResponse? unitResponse, {required bool isDark, required ThemeData theme}) {
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
    required ThemeData theme
  }) {
    
 
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color:theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        labelStyle: TextStyle(
          color: isDark?  Colors.white:Colors.black87,
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
       border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
       focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.primary,
          width: 1.5,
        ),
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
              Text(value, 
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

  Widget _buildAccountActions(
  { required bool isDark,
     required ThemeData theme}) {
    
    
    return Column(
      children: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
         // tileColor: Colors.grey.shade50,
         tileColor: theme.colorScheme.surface,
          leading: const Icon(Icons.help_outline, color: AppTheme.primary),
          title: const Text('Help & Support'
          ),
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
            style: TextStyle(
              color: AppTheme.errorRed),
          
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
