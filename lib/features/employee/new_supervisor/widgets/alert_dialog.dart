import 'dart:io';
import 'package:farm_vest/core/widgets/custom_textfield.dart';

import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';

enum QuickActionType { milkEntry, healthTicket, transferRequest, locateAnimal }

const Map<QuickActionType, String> buttonLabels = {
  QuickActionType.milkEntry: 'Submit Entry',
  QuickActionType.healthTicket: 'Raise Health Ticket',
  QuickActionType.transferRequest: 'Submit Transfer',
  QuickActionType.locateAnimal: 'Search',
};

const Map<QuickActionType, Color> buttonBackgroundColors = {
  QuickActionType.milkEntry: AppTheme.lightPrimary,
  QuickActionType.healthTicket: Color.fromARGB(255, 244, 81, 69),
  QuickActionType.transferRequest: AppTheme.slate,
  QuickActionType.locateAnimal: AppTheme.lightPrimary,
};

Future<void> showQuickActionDialog({
  required BuildContext context,
  required QuickActionType type,
  required WidgetRef ref,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _QuickActionDialogContent(type: type),
  );
}

class _QuickActionDialogContent extends ConsumerStatefulWidget {
  final QuickActionType type;
  const _QuickActionDialogContent({required this.type});

  @override
  ConsumerState<_QuickActionDialogContent> createState() =>
      _QuickActionDialogContentState();
}

class _QuickActionDialogContentState
    extends ConsumerState<_QuickActionDialogContent> {
  final quantityController = TextEditingController();
  final reasonController = TextEditingController();
  final idController = TextEditingController();
  final idFocusNode = FocusNode();
  final reasonFocusNode = FocusNode();

  String selectedPriority = 'High';
  String selectedTiming = 'Morning';
  String selectedDisease = 'FEVER';

  bool _isSubmitting = false;
  List<File> _pickedImages = [];
  int? _selectedAnimalId;
  String? _selectedAnimalTag;
  String? _selectedAnimalIdString;
  bool _isSearchEnabled = false;

  @override
  void dispose() {
    quantityController.dispose();
    reasonController.dispose();
    idController.dispose();
    idFocusNode.dispose();
    reasonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dialogTitle = '';
    String successMessage = '';

    switch (widget.type) {
      case QuickActionType.milkEntry:
        dialogTitle = 'Milk Entry';
        break;
      case QuickActionType.healthTicket:
        dialogTitle = 'Report Health Ticket';
        successMessage = 'Health ticket raised successfully!';
        break;
      case QuickActionType.transferRequest:
        dialogTitle = 'Transfer Request';
        successMessage = 'Transfer request submitted!';
        break;
      case QuickActionType.locateAnimal:
        dialogTitle = 'Locate Buffalo Position';
        break;
    }

    final dashboardState = ref.watch(supervisorDashboardProvider);
    final suggestions = dashboardState.animalSuggestions;

    return CustomDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dialogTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref
                      .read(supervisorDashboardProvider.notifier)
                      .clearSuggestions();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.type == QuickActionType.milkEntry) ...[
                    helperTextField(
                      context,
                      helperText: 'Please enter quantity in liters',
                      field: CustomTextField(
                        hint: 'Enter quantity',
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimingDropdown(
                      context,
                      selectedTiming,
                      (val) => setState(() => selectedTiming = val!),
                    ),
                  ],

                  if (widget.type == QuickActionType.healthTicket ||
                      widget.type == QuickActionType.transferRequest ||
                      widget.type == QuickActionType.locateAnimal) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        helperTextField(
                          context,
                          helperText:
                              widget.type == QuickActionType.locateAnimal
                              ? 'Search Animal by ID or Tag'
                              : 'Buffalo ID / RFID / Ear Tag',
                          field: CustomTextField(
                            hint: 'Enter Tag Number',
                            controller: idController,
                            focusNode: idFocusNode,
                            onChanged: (val) {
                              setState(() {}); // Rebuild to update button state
                              ref
                                  .read(supervisorDashboardProvider.notifier)
                                  .searchSuggestions(val);
                              _isSearchEnabled = val.trim().isNotEmpty;

                              if (_selectedAnimalId != null &&
                                  val != _selectedAnimalTag) {
                                setState(() {
                                  _selectedAnimalId = null;
                                  _selectedAnimalTag = null;
                                });
                              }
                            },
                          ),
                        ),
                        if (suggestions.isNotEmpty && _selectedAnimalId == null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: suggestions.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final animal = suggestions[index];
                                final tag =
                                    animal.rfid ??
                                    animal.earTagId ??
                                    animal.animalId;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    tag,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ID: ${animal.animalId} • Row: ${animal.rowNumber ?? 'N/A'}',
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedAnimalId = animal.internalId;
                                      _selectedAnimalTag = tag;
                                      _selectedAnimalIdString = animal.animalId;
                                      idController.text = tag;
                                    });
                                    ref
                                        .read(
                                          supervisorDashboardProvider.notifier,
                                        )
                                        .clearSuggestions();
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (widget.type == QuickActionType.healthTicket ||
                      widget.type == QuickActionType.transferRequest) ...[
                    helperTextField(
                      context,
                      helperText: 'Description / Reason',
                      field: CustomTextField(
                        hint: 'Enter detail here...',
                        controller: reasonController,
                        focusNode: reasonFocusNode,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.type == QuickActionType.healthTicket) ...[
                      _buildPriorityDropdown(
                        context,
                        selectedPriority,
                        (val) => setState(() => selectedPriority = val!),
                      ),
                      const SizedBox(height: 12),
                      _buildDiseaseDropdown(
                        context,
                        selectedDisease,
                        (val) => setState(() => selectedDisease = val!),
                      ),
                      const SizedBox(height: 16),
                      _buildMultiImagePicker(
                        context,
                        _pickedImages,
                        onCameraPick: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 70,
                          );
                          if (image != null && _pickedImages.length < 5) {
                            setState(() => _pickedImages.add(File(image.path)));
                          }
                        },
                        onGalleryPick: () async {
                          final picker = ImagePicker();
                          final images = await picker.pickMultiImage(
                            imageQuality: 70,
                          );
                          if (images.isNotEmpty) {
                            final remaining = 5 - _pickedImages.length;
                            final toAdd = images
                                .take(remaining)
                                .map((x) => File(x.path))
                                .toList();
                            setState(() => _pickedImages.addAll(toAdd));
                          }
                        },
                        onRemove: (index) {
                          setState(() => _pickedImages.removeAt(index));
                        },
                      ),
                    ],
                  ],

                  if (widget.type == QuickActionType.locateAnimal) ...[
                    CustomActionButton(
                      width: double.infinity,
                      color: _isSearchEnabled
                          ? AppTheme.lightPrimary
                          : Colors.grey,
                      onPressed: _isSearchEnabled
                          ? () {
                              final query = idController.text.trim();
                              if (query.isNotEmpty) {
                                ref
                                    .read(supervisorDashboardProvider.notifier)
                                    .locateAnimal(query);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a tag or ID to search',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      child: const Text(
                        'Search',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (dashboardState.isLocatingAnimal)
                      const Center(child: CircularProgressIndicator())
                    else if (dashboardState.error != null)
                      Text(
                        dashboardState.error!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (dashboardState.animalLocation != null)
                      _buildLocationResult(
                        context,
                        dashboardState.animalLocation!,
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.type != QuickActionType.locateAnimal)
            CustomActionButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (widget.type == QuickActionType.milkEntry) {
                        if (quantityController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Quantity is required'),
                            ),
                          );
                          return;
                        }
                        setState(() => _isSubmitting = true);
                        try {
                          final res = await ref
                              .read(supervisorDashboardProvider.notifier)
                              .createMilkEntry(
                                timing: selectedTiming,
                                quantity: quantityController.text,
                                animalId: 0,
                              );
                          if (res != null && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Milk entry added'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isSubmitting = false);
                        }
                      } else if (widget.type == QuickActionType.healthTicket ||
                          widget.type == QuickActionType.transferRequest) {
                        if (_selectedAnimalId == null &&
                            idController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Animal selection is required'),
                            ),
                          );
                          return;
                        }
                        if (reasonController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reason/Description is required'),
                            ),
                          );
                          return;
                        }

                        setState(() => _isSubmitting = true);
                        try {
                          List<String> uploadedUrls = [];
                          for (final img in _pickedImages) {
                            final url = await AuthRepository.uploadImage(img);
                            if (url != null) {
                              uploadedUrls.add(url);
                            }
                          }

                          int? finalAnimalInternalId = _selectedAnimalId;
                          String? finalAnimalIdString = _selectedAnimalIdString;

                          if (finalAnimalInternalId == null) {
                            final animals = await ref
                                .read(supervisorRepositoryProvider)
                                .searchAnimals(query: idController.text.trim());
                            if (animals.isNotEmpty) {
                              final animal = animals.first;
                              finalAnimalInternalId = animal.internalId;
                              finalAnimalIdString = animal.animalId;
                            }
                          }

                          if (finalAnimalInternalId == null &&
                              finalAnimalIdString == null) {
                            finalAnimalIdString = idController.text.trim();
                          }

                          if (finalAnimalIdString == null ||
                              finalAnimalIdString.isEmpty) {
                            throw Exception(
                              'Could not find animal matching ${idController.text}',
                            );
                          }

                          final body = {
                            'animal_id': finalAnimalIdString,
                            'description': reasonController.text,
                            'priority': selectedPriority.toUpperCase(),
                            'disease':
                                widget.type == QuickActionType.healthTicket
                                ? [selectedDisease]
                                : null,
                            'images': uploadedUrls,
                            if (widget.type ==
                                QuickActionType.transferRequest) ...{
                              'transfer_direction': 'OUT',
                            },
                          };

                          final res = await ref
                              .read(supervisorDashboardProvider.notifier)
                              .createTicket(
                                body,
                                ticketType:
                                    widget.type == QuickActionType.healthTicket
                                    ? 'HEALTH'
                                    : 'TRANSFER',
                              );
                          if (res != null && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(successMessage),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isSubmitting = false);
                        }
                      }
                    },
              color:
                  buttonBackgroundColors[widget.type] ?? AppTheme.lightPrimary,
              width: double.infinity,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      buttonLabels[widget.type] ?? 'Submit',
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
        ],
      ),
    );
  }
}

Widget _buildTimingDropdown(
  BuildContext context,
  String current,
  ValueChanged<String?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Select Timing',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
      ),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: current,
        items: [
          'Morning',
          'Afternoon',
          'Evening',
        ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    ],
  );
}

Widget _buildPriorityDropdown(
  BuildContext context,
  String current,
  ValueChanged<String?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Select Priority',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
      ),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: current,
        items: [
          'High',
          'Medium',
          'Low',
        ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    ],
  );
}

Widget _buildDiseaseDropdown(
  BuildContext context,
  String current,
  ValueChanged<String?> onChanged,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Identify Disease',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
      ),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: current,
        items: [
          'FEVER',
          'MASTITIS',
          'DIARRHEA',
          'FOOT_ROT',
          'ANEMIA',
          'BLOAT',
          'HEAT_STRESS',
        ].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    ],
  );
}

Widget _buildMultiImagePicker(
  BuildContext context,
  List<File> pickedImages, {
  required VoidCallback onCameraPick,
  required VoidCallback onGalleryPick,
  required void Function(int) onRemove,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Evidence Images (Optional, max 5)',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...pickedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => onRemove(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (pickedImages.length < 5)
              Row(
                children: [
                  _buildAddImageButton(
                    context,
                    Icons.camera_alt,
                    'Camera',
                    onCameraPick,
                  ),
                  const SizedBox(width: 8),
                  _buildAddImageButton(
                    context,
                    Icons.photo_library,
                    'Gallery',
                    onGalleryPick,
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildAddImageButton(
  BuildContext context,
  IconData icon,
  String label,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).dividerColor.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.primary),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLocationResult(
  BuildContext context,
  Map<String, dynamic> location,
) {
  return InkWell(
    onTap: () {
      Navigator.pop(context);
      context.go(
        '/buffalo-allocation',
        extra: {
          'shedId': location['sheds.id'],
          'parkingId': location['parking_id'],
        },
      );
    },
    borderRadius: BorderRadius.circular(12),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Icon(Icons.directions, color: Theme.of(context).primaryColor),
              ],
            ),
            const Divider(),
            _buildLocationRow(context, 'Shed', location['shed_name']),
            _buildLocationRow(
              context,
              'Row',
              location['row_number']?.toString(),
            ),
            _buildLocationRow(context, 'Slot', location['parking_id']),
            _buildLocationRow(context, 'Health', location['health_status']),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLocationRow(BuildContext context, String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
        Text(
          value ?? 'N/A',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ),
  );
}

Widget helperTextField(
  BuildContext context, {
  required String helperText,
  required Widget field,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        helperText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).hintColor,
        ),
      ),
      const SizedBox(height: 6),
      field,
    ],
  );
}
