// lib/features/customer/screens/profile_screen.dart
import 'dart:io';
import 'package:farm_vest/features/auth/data/models/user_model.dart';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:farm_vest/features/investor/presentation/widgets/profile/profile_action_list.dart';
import 'package:farm_vest/features/investor/presentation/widgets/profile/profile_header.dart';
import 'package:farm_vest/features/investor/presentation/widgets/profile/profile_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            // Set to null for API
            finalImageUrlForApi = null;
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
            finalImageUrlForApi = currentFirebaseImageUrl;
          }

          // Always prepare update data
          final updateData = <String, dynamic>{
            'name': _nameController.text,
            'email': _emailController.text,
            'address': _addressController.text,
          };

          // Always include profile (image URL), even if empty
          updateData['profile'] = finalImageUrlForApi;

          debugPrint('Sending to API - profile: ${updateData['profile']}');

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to update profile"),
                  backgroundColor: Colors.red,
                ),
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

    // Aggressive sync removed to prevent build-phase state modification error.
    // relying on ref.listen to update controllers.

    // Listen for future updates
    ref.listen(authProvider, (previous, next) {
      if (next.userData != null && next.userData != previous?.userData) {
        if (!_isEditing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _nameController.text = next.userData?.name ?? '';
            _emailController.text = next.userData?.email ?? '';
            _addressController.text = next.userData?.address ?? '';
            _phoneController.text = next.userData?.mobile ?? '';
          });
        }
      }
    });

    ref.listen(investorSummaryProvider, (previous, next) {
      next.whenData((summary) {
        if (!_isEditing && summary != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final details = summary.data.profileDetails;
            if (details.fullName.isNotEmpty) {
              _nameController.text = details.fullName;
            }
            if (details.phoneNumber.isNotEmpty) {
              _phoneController.text = details.phoneNumber;
            }
            if (details.email != null && details.email!.isNotEmpty) {
              _emailController.text = details.email!;
            }
            if (details.address != null && details.address!.isNotEmpty) {
              _addressController.text = details.address!;
            }
          });
        }
      });
    });

    final summaryAsync = ref.watch(investorSummaryProvider);
    DateTime? membershipSince;

    // Extract membership date from summary provider (instead of unitResponse)
    // Extract membership date and construct effective user from summary
    UserModel? summaryUser;

    summaryAsync.whenData((summary) {
      if (summary != null) {
        final details = summary.data.profileDetails;

        if (details.memberSince.isNotEmpty) {
          membershipSince = DateTime.tryParse(details.memberSince);
        }

        if (userData != null) {
          summaryUser = userData.copyWith(
            firstName: details.firstName.isNotEmpty ? details.firstName : null,
            lastName: details.lastName.isNotEmpty ? details.lastName : null,
            name: details.fullName.isNotEmpty ? details.fullName : null,
            mobile: details.phoneNumber.isNotEmpty ? details.phoneNumber : null,
            email: details
                .email, // Allow null to fallback to userData in copyWith? No, copyWith takes nullable args to override?
            // UserModel.copyWith usually takes nullable to replace, but if I pass null it keeps old value.
            // If I want to clear it, I might have trouble. But here I want to usage summary if present.
            address: details.address,
          );
          // Manually handle fields that might be null in details but we want to overwrite even if null?
          // Usually profile details from API should be authoritative.
          // However, if details.email is null, we might want to keep userData.email if it exists?
          // The user experience suggests summary is "data coming", so use it.
          // Let's refine copyWith usage.

          summaryUser = userData.copyWith(
            firstName: details.firstName.isNotEmpty
                ? details.firstName
                : userData.firstName,
            lastName: details.lastName.isNotEmpty
                ? details.lastName
                : userData.lastName,
            name: details.fullName.isNotEmpty
                ? details.fullName
                : userData.name,
            mobile: details.phoneNumber.isNotEmpty
                ? details.phoneNumber
                : userData.mobile,
            email: (details.email != null && details.email!.isNotEmpty)
                ? details.email
                : userData.email,
            address: (details.address != null && details.address!.isNotEmpty)
                ? details.address
                : userData.address,
          );
        }
      }
    });

    final effectiveUser = summaryUser ?? userData;

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
                  user: effectiveUser,
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
                  user: effectiveUser,
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
