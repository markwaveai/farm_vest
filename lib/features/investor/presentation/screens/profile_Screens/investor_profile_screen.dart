// lib/features/customer/screens/profile_screen.dart
import 'dart:io';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:farm_vest/features/investor/presentation/widgets/profile/profile_action_list.dart';
import 'package:farm_vest/features/investor/presentation/widgets/profile/profile_header.dart';
import 'package:farm_vest/features/investor/presentation/widgets/profile/profile_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).userData;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _phoneController = TextEditingController(text: user?.mobile ?? '');

    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshUserData();
      // Also refresh summary to get member since date
      ref.invalidate(investorSummaryProvider);
    });
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

    final summaryAsync = ref.watch(investorSummaryProvider);
    DateTime? membershipSince;

    // Extract membership date from summary provider (instead of unitResponse)
    summaryAsync.whenData((summary) {
      if (summary?.data.profileDetails.memberSince != null &&
          summary!.data.profileDetails.memberSince.isNotEmpty) {
        membershipSince = DateTime.tryParse(
          summary.data.profileDetails.memberSince,
        );
      }
    });

    final formattedDate = membershipSince != null
        ? '${membershipSince!.day}/${membershipSince!.month}/${membershipSince!.year}'
        : 'N/A';

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
                ProfileHeader(
                  user: userData,
                  isEditing: _isEditing,
                  isDark: isDark,
                  currentImageFile: _profileImage,
                  isImageRemoved: _removeProfileImage,
                  onImageSelected: (file) {
                    setState(() {
                      _profileImage = file;
                      _removeProfileImage = false;
                    });
                  },
                  onImageRemoved: () {
                    setState(() {
                      _profileImage = null;
                      _removeProfileImage = true;
                    });
                  },
                ),
                const SizedBox(height: AppConstants.spacingL),

                // Profile Details
                ProfileInfoCard(
                  formKey: _formKey,
                  user: userData,
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  addressController: _addressController,
                  isEditing: _isEditing,
                  isDark: isDark,
                  membershipDate: formattedDate,
                ),

                const SizedBox(height: AppConstants.spacingL),

                // Account Actions
                const ProfileActionList(),
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
}
