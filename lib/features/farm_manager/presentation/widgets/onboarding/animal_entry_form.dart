import 'dart:io';
import 'package:farm_vest/core/services/biometric_service.dart';
import 'package:farm_vest/core/theme/app_constants.dart';

import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:farm_vest/features/farm_manager/data/models/animal_onboarding_entry.dart';
import 'package:farm_vest/features/farm_manager/data/models/farm_manager_dashboard_model.dart';
import 'package:farm_vest/features/farm_manager/presentation/widgets/onboarding/modern_textfield.dart';
import 'package:farm_vest/features/farm_manager/presentation/widgets/onboarding/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AnimalEntryForm extends StatefulWidget {
  final AnimalOnboardingEntry entry;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onUpdate;
  final List<AnimalOnboardingEntry> buffaloEntries;
  final List<AnimalOnboardingEntry> calfEntries;

  const AnimalEntryForm({
    super.key,
    required this.entry,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
    this.buffaloEntries = const [],
    this.calfEntries = const [],
  });

  @override
  State<AnimalEntryForm> createState() => _AnimalEntryFormState();
}

class _AnimalEntryFormState extends State<AnimalEntryForm> {
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
    );
  }

  Future<void> _uploadAndAttachImage(File file) async {
    // Add temporary image with uploading state
    setState(() {
      widget.entry.images = [
        ...widget.entry.images,
        DashboardImage(localFile: file, isUploading: true),
      ];
    });
    widget.onUpdate();

    try {
      final url = await AuthRepository.uploadImage(file);
      if (url != null) {
        if (mounted) {
          setState(() {
            final index = widget.entry.images.indexWhere(
              (img) => img.localFile?.path == file.path,
            );
            if (index != -1) {
              widget.entry.images[index] = DashboardImage(
                localFile: file,
                networkUrl: url,
                isUploading: false,
              );
            }
          });
          widget.onUpdate();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = widget.entry.images.indexWhere(
            (img) => img.localFile?.path == file.path,
          );
          if (index != -1) {
            widget.entry.images[index] = DashboardImage(
              localFile: widget.entry.images[index].localFile,
              networkUrl: widget.entry.images[index].networkUrl,
              isUploading: false,
              hasError: true,
            );
          }
        });
        widget.onUpdate();
        _showError('Failed to upload image');
      }
    }
  }

  void _showImageSourceDialog(Function(File) onImagePicked) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Divider(color: AppTheme.grey1.withValues(alpha: 0.5)),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final XFile? image =
                      await BiometricService.runWithLockSuppressed(() {
                        return picker.pickImage(source: ImageSource.camera);
                      });
                  if (image != null) {
                    onImagePicked(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final XFile? image =
                      await BiometricService.runWithLockSuppressed(() {
                        return picker.pickImage(source: ImageSource.gallery);
                      });
                  if (image != null) {
                    onImagePicked(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.entry;
    final isBuffalo = animal.type.toLowerCase() == 'buffalo';
    final title = isBuffalo ? 'Buffalo' : 'Calf';

    final isComplete =
        animal.rfidTag.trim().isNotEmpty &&
        animal.earTag.trim().isNotEmpty &&
        animal
            .images
            .isNotEmpty; // Make image mandatory for "Complete" status styling

    final cardColor = Colors.white;

    final borderColor = isComplete
        ? AppTheme.successGreen.withValues(alpha: 0.3)
        : AppTheme.primary.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(
                alpha: 0.04,
              ), // Very subtle fill
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightGrey.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                // Icon + Number
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '#${widget.index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (animal.earTag.isNotEmpty)
                        Text(
                          'Tag: ${animal.earTag}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          'Enter details below',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.grey1,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                // Status Pill
                if (isComplete)
                  StatusPill(
                    text: 'Complete',
                    color: AppTheme.successGreen,
                    icon: Icons.check,
                  )
                else
                  StatusPill(
                    text: 'Pending',
                    color: AppTheme.warningOrange,
                    icon: Icons.edit,
                  ),

                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.errorRed,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // Form Body
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: RFID & Ear Tag
                Row(
                  children: [
                    Expanded(
                      child: ModernTextField(
                        label: 'RFID Tag',
                        hint: 'RFID-XXXX',
                        value: animal.rfidTag,
                        icon: Icons.qr_code_scanner_rounded,
                        maxLength: 15,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (val) {
                          setState(() => animal.rfidTag = val);
                          widget.onUpdate();
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ModernTextField(
                        label: 'Ear Tag',
                        hint: 'ET-XXXX',
                        value: animal.earTag,
                        icon: Icons.local_offer_outlined,
                        maxLength: 12,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (val) {
                          setState(() => animal.earTag = val);
                          widget.onUpdate();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Second Row: Age, Breed/Parent
                Row(
                  children: [
                    if (isBuffalo)
                      Expanded(
                        child: ModernTextField(
                          label: 'Breed Name',
                          hint: 'e.g. Murrah',
                          value: animal.breedName,
                          icon: Icons.pets_outlined,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (val) {
                            setState(() => animal.breedName = val);
                            widget.onUpdate();
                          },
                        ),
                      )
                    else if (!isBuffalo) ...[
                      // Age first for calf?
                      // Wait, previous code had Age left, Parent right.
                      // Buffalo code had Breed Left, Age Right.
                    ] else
                      const Spacer(),

                    // Re-structuring to match inputs
                    if (isBuffalo) const SizedBox(width: 20),

                    Expanded(
                      child: ModernTextField(
                        label: 'Age (Months)',
                        hint: '36',
                        value: animal.ageMonths > 0
                            ? animal.ageMonths.toString()
                            : '',
                        icon: Icons.cake_outlined,
                        isNumber: true,
                        maxLength: 3,
                        onChanged: (val) {
                          setState(
                            () => animal.ageMonths = int.tryParse(val) ?? 0,
                          );
                          widget.onUpdate();
                        },
                      ),
                    ),

                    if (!isBuffalo) ...[
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parent Buffalo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGrey.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.transparent),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    'Select Parent Buffalo (RFID)',
                                    style: TextStyle(
                                      color: AppTheme.grey1.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  value: () {
                                    final exists = widget.buffaloEntries
                                        .asMap()
                                        .keys
                                        .any(
                                          (idx) =>
                                              "BUFFALOTEMP_$idx" ==
                                              animal.parentAnimalId,
                                        );
                                    return exists
                                        ? animal.parentAnimalId
                                        : null;
                                  }(),
                                  icon: Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppTheme.grey1,
                                  ),
                                  items: widget.buffaloEntries.asMap().entries.map((
                                    entry,
                                  ) {
                                    final idx = entry.key;
                                    final buff = entry.value;
                                    final buffaloId = "BUFFALOTEMP_$idx";

                                    // Get list of already selected parent IDs (excluding current calf)
                                    final selectedParents = widget.calfEntries
                                        .where(
                                          (c) =>
                                              c != animal &&
                                              c.parentAnimalId.isNotEmpty,
                                        )
                                        .map((c) => c.parentAnimalId)
                                        .toSet();

                                    // Check if this buffalo is already selected
                                    final isAlreadySelected = selectedParents
                                        .contains(buffaloId);

                                    // Show RFID tag in dropdown
                                    final displayRfid = buff.rfidTag.isNotEmpty
                                        ? buff.rfidTag
                                        : 'Not Set';

                                    return DropdownMenuItem(
                                      value: buffaloId,
                                      enabled:
                                          !isAlreadySelected, // Disable if already selected
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Buffalo #${idx + 1} - RFID: $displayRfid",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isAlreadySelected
                                                    ? Colors.grey.withValues(
                                                        alpha: 0.5,
                                                      )
                                                    : Colors.black,
                                                decoration: isAlreadySelected
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          if (isAlreadySelected)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Icon(
                                                Icons.block,
                                                size: 16,
                                                color: Colors.red.withValues(
                                                  alpha: 0.6,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(
                                        () => animal.parentAnimalId = val,
                                      );
                                      widget.onUpdate();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Third Row: Status (Buffalo Only)
                if (isBuffalo) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.grey1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.lightGrey.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: animal.status.isNotEmpty
                                    ? animal.status
                                    : null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  isDense: true,
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'high_yield',
                                    child: Text('High Yield'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'low_yield',
                                    child: Text('Low Yield'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'dry',
                                    child: Text('Dry'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sick',
                                    child: Text('Sick'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sold',
                                    child: Text('Sold'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => animal.status = value);
                                    widget.onUpdate();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Neckband ID (Buffalo Only)
                if (isBuffalo)
                  ModernTextField(
                    label: 'Neckband ID (Optional)',
                    hint: 'e.g. NB-8877',
                    value: animal.neckbandId,
                    icon: Icons.link_rounded,
                    onChanged: (val) {
                      setState(() => animal.neckbandId = val);
                      widget.onUpdate();
                    },
                  ),

                if (isBuffalo) const SizedBox(height: 24),

                // Images Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Photos (${animal.images.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add Button
                          InkWell(
                            onTap: () {
                              _showImageSourceDialog((file) {
                                _uploadAndAttachImage(file);
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_rounded,
                                    color: AppTheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Images
                          ...animal.images.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final img = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: img.localFile != null
                                            ? FileImage(img.localFile!)
                                            : NetworkImage(img.networkUrl ?? '')
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (img.isUploading)
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(
                                          () => animal.images.removeAt(idx),
                                        );
                                        widget.onUpdate();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: AppTheme.errorRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
