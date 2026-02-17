import 'dart:io';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/auth/data/models/user_model.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class ProfileHeader extends ConsumerStatefulWidget {
  final UserModel? user;
  final bool isEditing;
  final bool isDark;
  final File? currentImageFile;
  final bool isImageRemoved;
  final Function(File) onImageSelected;
  final Function() onImageRemoved;

  ProfileHeader({
    super.key,
    required this.user,
    required this.isEditing,
    required this.isDark,
    this.currentImageFile,
    this.isImageRemoved = false,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  void _showImageSourceSheet(bool hasImage) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'.tr(ref)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await ref
                      .read(authProvider.notifier)
                      .pickProfileImage(source: ImageSource.gallery);
                  if (file != null && mounted) {
                    widget.onImageSelected(file);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a photo'.tr(ref)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await ref
                      .read(authProvider.notifier)
                      .pickProfileImage(source: ImageSource.camera);
                  if (file != null && mounted) {
                    widget.onImageSelected(file);
                  }
                },
              ),
              if (hasImage)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Remove photo'.tr(ref),
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmRemove();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRemove() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Profile Photo'.tr(ref)),
        content: Text(
          'Are you sure you want to remove your profile photo?'.tr(ref),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(ref)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onImageRemoved();
            },
            child: Text('Remove'.tr(ref)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteImageUrl = widget.isImageRemoved ? null : widget.user?.imageUrl;
    final hasImage =
        widget.currentImageFile != null ||
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
                  child: widget.currentImageFile != null
                      ? Image.file(widget.currentImageFile!, fit: BoxFit.cover)
                      : (remoteImageUrl != null && remoteImageUrl.isNotEmpty)
                      ? Image.network(
                          remoteImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
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
                            debugPrint(
                              'Image load error for $remoteImageUrl: $error',
                            );
                            return Center(
                              child: Text(
                                'Image not supported'.tr(ref),
                                style: AppTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            if (widget.isEditing)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () => _showImageSourceSheet(hasImage),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppConstants.spacingM),
        Text(
          widget.user?.name ?? '',
          style: AppTheme.headingMedium.copyWith(
            color: widget.isDark ? AppTheme.white : AppTheme.secondary,
          ),
        ),
        Text(
          widget.user?.email ?? '',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGrey),
        ),
      ],
    );
  }
}
