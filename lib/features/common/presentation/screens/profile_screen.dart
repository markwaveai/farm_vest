import 'dart:io';
import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:farm_vest/features/common/presentation/widgets/profile/profile_action_list.dart';
import 'package:farm_vest/features/common/presentation/widgets/profile/profile_header.dart';
import 'package:farm_vest/features/common/presentation/widgets/profile/profile_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _CommonProfileScreenState();
}

class _CommonProfileScreenState extends ConsumerState<ProfileScreen> {
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
      // Only refresh investor summary if current role is customer (investor)
      if (ref.read(authProvider).role == UserType.customer) {
        ref.invalidate(investorSummaryProvider);
      }
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
                SnackBar(
                  content: Text("Profile updated successfully".tr),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text("Failed to update profile".tr),
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
    final userRole = authState.role;

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

    // Only handle investor summary if user is a customer
    if (userRole == UserType.customer) {
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
    }

    DateTime? membershipSince;
    UserModel? summaryUser;

    if (userRole == UserType.customer) {
      final summaryAsync = ref.watch(investorSummaryProvider);
      summaryAsync.whenData((summary) {
        if (summary != null) {
          final details = summary.data.profileDetails;

          if (details.memberSince.isNotEmpty) {
            membershipSince = DateTime.tryParse(details.memberSince);
          }

          if (userData != null) {
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
    }

    final effectiveUser = summaryUser ?? userData;

    final formattedDate =
        (userRole == UserType.customer && membershipSince != null)
        ? '${membershipSince!.day}/${membershipSince!.month}/${membershipSince!.year}'
        : '';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('My Profile'.tr),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isSaving ? null : _toggleEdit,
            tooltip: _isEditing ? 'Save Changes'.tr : 'Edit Profile'.tr,
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
