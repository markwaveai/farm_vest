import 'dart:io';
import 'package:farm_vest/core/services/biometric_service.dart';

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
  final AnimalOnboardingEntry? calfEntry;

  const AnimalEntryForm({
    super.key,
    required this.entry,
    required this.index,
    required this.onRemove,
    required this.onUpdate,
    this.buffaloEntries = const [],
    this.calfEntries = const [],
    this.calfEntry,
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
              Divider(color: AppTheme.grey1.withOpacity(0.5)),
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

  void _openCalfDialog() {
    if (widget.calfEntry == null) return;

    // Auto-link to parent
    if (widget.calfEntry!.parentAnimalId.isEmpty) {
      if (widget.buffaloEntries.isNotEmpty &&
          widget.index < widget.buffaloEntries.length &&
          widget.buffaloEntries[widget.index].animalId.isNotEmpty) {
        widget.calfEntry!.parentAnimalId =
            widget.buffaloEntries[widget.index].animalId;
      } else {
        widget.calfEntry!.parentAnimalId = "BUFFALOTEMP_${widget.index}";
      }
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: AnimalEntryForm(
            entry: widget.calfEntry!,
            index: widget.index, // Same index
            onRemove:
                () {}, // Cannot remove calf individually via this view easily (or add remove logic)
            onUpdate: widget.onUpdate,
            buffaloEntries: widget.buffaloEntries,
            calfEntries: widget.calfEntries,
          ),
        ),
      ),
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

    final cardColor = Theme.of(context).cardColor;

    final borderColor = isComplete
        ? AppTheme.successGreen.withValues(alpha: 0.3)
        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.04), // Very subtle fill
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                // Icon + Number
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '#${widget.index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (animal.earTag.isNotEmpty)
                        Text(
                          'Tag: ${animal.earTag}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          'Enter details below',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
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
                // New First Row: Neckband ID & Tag Number (Buffalo only)
                if (isBuffalo) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ModernTextField(
                          label: 'Neckband ID',
                          hint: 'e.g. NB-8877',
                          value: animal.neckbandId,
                          icon: Icons.link_rounded,
                          onChanged: (val) {
                            setState(() => animal.neckbandId = val);
                            widget.onUpdate();
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ModernTextField(
                          label: 'Tag Number',
                          hint: 'e.g. TAG-XXXX',
                          value: animal.tagNumber,
                          icon: Icons.tag_rounded,
                          onChanged: (val) {
                            setState(() => animal.tagNumber = val);
                            widget.onUpdate();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Previous First Row: RFID & Ear Tag
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBuffalo) ...[
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
                      ),
                      const SizedBox(width: 20),
                    ],
                    Expanded(
                      child: ModernTextField(
                        label: 'Age (Months)',
                        hint: isBuffalo ? '36' : '6',
                        value: animal.ageMonths > 0
                            ? animal.ageMonths.toString()
                            : '',
                        icon: Icons.cake_outlined,
                        isNumber: true,
                        maxLength: 3,
                        validator: (val) {
                          if (isBuffalo) {
                            if (val != null && val.isNotEmpty) {
                              final age = int.tryParse(val);
                              if (age != null && age < 36) {
                                return 'Age should be greater than 35 months';
                              }
                            }
                          }
                          return null;
                        },
                        onChanged: (val) {
                          setState(
                            () => animal.ageMonths = int.tryParse(val) ?? 0,
                          );
                          widget.onUpdate();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Third Row: Status (Buffalo Only)
                if (isBuffalo) ...[
                  // Status & Health Status Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBuffalo) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).inputDecorationTheme.fillColor ??
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: animal.status.isNotEmpty
                                      ? animal.status
                                      : null,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
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
                                      value: 'pregnant',
                                      child: Text('Pregnant'),
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
                        const SizedBox(width: 20),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).inputDecorationTheme.fillColor ??
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: animal.healthStatus.isNotEmpty
                                    ? animal.healthStatus.toLowerCase()
                                    : 'healthy',
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'healthy',
                                    child: Text('Healthy'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sick',
                                    child: Text('Sick'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'treatment',
                                    child: Text('Under Treatment'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'recovered',
                                    child: Text('Recovered'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => animal.healthStatus = value
                                          .toUpperCase(),
                                    );
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

                const SizedBox.shrink(),

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
                            color: Theme.of(context).hintColor,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.2),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
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
                                          color: Theme.of(context).cardColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .shadowColor
                                                  .withValues(alpha: 0.1),
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

          if (isBuffalo && widget.calfEntry != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: InkWell(
                onTap: _openCalfDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.child_friendly_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Calf Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.calfEntry!.earTag.isNotEmpty
                                ? "Tag: ${widget.calfEntry!.earTag}"
                                : "Tap to enter calf details",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
