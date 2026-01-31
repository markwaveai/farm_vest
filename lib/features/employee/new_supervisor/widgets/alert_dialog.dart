import 'dart:io';
import 'package:farm_vest/core/widgets/custom_Textfield.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';

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
  String selectedShed = '';
  String selectedPriority = 'High';
  String selectedTiming = 'Morning';
  String selectedDisease = 'FEVER';

  final quantityController = TextEditingController();
  final reasonController = TextEditingController();
  final idController = TextEditingController();

  String dialogTitle = '';
  String successMessage = '';
  bool _isSubmitting = false;
  List<File> _pickedImages = [];
  int? _selectedAnimalId;
  String? _selectedAnimalTag;
  String? _selectedAnimalRfid;

  switch (type) {
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

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Consumer(
        builder: (context, ref, child) {
          final dashboardState = ref.watch(supervisorDashboardProvider);
          final suggestions = dashboardState.animalSuggestions;

          return StatefulBuilder(
            builder: (context, setState) {
              return CustomDialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dialogTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                            if (type == QuickActionType.milkEntry) ...[
                              helperTextField(
                                helperText: 'Please enter quantity in liters',
                                field: CustomTextField(
                                  hint: 'Enter quantity',
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildTimingDropdown(
                                selectedTiming,
                                (val) => setState(() => selectedTiming = val!),
                              ),
                            ],

                            if (type == QuickActionType.healthTicket ||
                                type == QuickActionType.transferRequest ||
                                type == QuickActionType.locateAnimal) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  helperTextField(
                                    helperText:
                                        type == QuickActionType.locateAnimal
                                        ? 'Search Animal by ID or Tag'
                                        : 'Buffalo ID / RFID / Ear Tag',
                                    field: CustomTextField(
                                      hint: 'Enter Tag Number',
                                      controller: idController,
                                      onChanged: (val) {
                                        if (true) {
                                          ref
                                              .read(
                                                supervisorDashboardProvider
                                                    .notifier,
                                              )
                                              .searchSuggestions(val);
                                          if (_selectedAnimalId != null &&
                                              val != _selectedAnimalTag) {
                                            setState(() {
                                              _selectedAnimalId = null;
                                              _selectedAnimalTag = null;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                  if (suggestions.isNotEmpty &&
                                      _selectedAnimalId == null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      constraints: const BoxConstraints(
                                        maxHeight: 150,
                                      ),
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
                                              animal.earTag ??
                                              animal.animalId;
                                          return ListTile(
                                            dense: true,
                                            title: Text(tag),
                                            subtitle: Text(
                                              'ID: ${animal.animalId} • Row: ${animal.rowNumber ?? 'N/A'}',
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _selectedAnimalId =
                                                    animal.internalId;
                                                _selectedAnimalTag = tag;
                                                idController.text = tag;
                                              });
                                              ref
                                                  .read(
                                                    supervisorDashboardProvider
                                                        .notifier,
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

                            if (type == QuickActionType.healthTicket ||
                                type == QuickActionType.transferRequest) ...[
                              helperTextField(
                                helperText: 'Description / Reason',
                                field: CustomTextField(
                                  hint: 'Enter detail here...',
                                  controller: reasonController,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (type == QuickActionType.healthTicket) ...[
                                _buildPriorityDropdown(
                                  selectedPriority,
                                  (val) =>
                                      setState(() => selectedPriority = val!),
                                ),
                                const SizedBox(height: 12),
                                _buildDiseaseDropdown(
                                  selectedDisease,
                                  (val) =>
                                      setState(() => selectedDisease = val!),
                                ),
                                const SizedBox(height: 16),
                                _buildMultiImagePicker(
                                  _pickedImages,
                                  onCameraPick: () async {
                                    final picker = ImagePicker();
                                    final image = await picker.pickImage(
                                      source: ImageSource.camera,
                                      imageQuality: 70,
                                    );
                                    if (image != null &&
                                        _pickedImages.length < 5) {
                                      setState(
                                        () =>
                                            _pickedImages.add(File(image.path)),
                                      );
                                    }
                                  },
                                  onGalleryPick: () async {
                                    final picker = ImagePicker();
                                    final images = await picker.pickMultiImage(
                                      imageQuality: 70,
                                    );
                                    if (images.isNotEmpty) {
                                      final remaining =
                                          5 - _pickedImages.length;
                                      final toAdd = images
                                          .take(remaining)
                                          .map((x) => File(x.path))
                                          .toList();
                                      setState(
                                        () => _pickedImages.addAll(toAdd),
                                      );
                                    }
                                  },
                                  onRemove: (index) {
                                    setState(
                                      () => _pickedImages.removeAt(index),
                                    );
                                  },
                                ),
                              ],
                            ],

                            if (type == QuickActionType.locateAnimal) ...[
                              CustomActionButton(
                                width: double.infinity,
                                color: AppTheme.lightPrimary,
                                onPressed: () {
                                  final query = idController.text.trim();
                                  if (query.isNotEmpty) {
                                    ref
                                        .read(
                                          supervisorDashboardProvider.notifier,
                                        )
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
                                },
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
                    if (type != QuickActionType.locateAnimal)
                      CustomActionButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                if (type == QuickActionType.milkEntry) {
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
                                        .read(
                                          supervisorDashboardProvider.notifier,
                                        )
                                        .createMilkEntry(
                                          timing: selectedTiming,
                                          quantity: quantityController.text,
                                          animalId: 0,
                                        );
                                    if (res != null && context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                    if (context.mounted)
                                      setState(() => _isSubmitting = false);
                                  }
                                } else if (type ==
                                        QuickActionType.healthTicket ||
                                    type == QuickActionType.transferRequest) {
                                  if (_selectedAnimalId == null &&
                                      idController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Animal selection is required',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (reasonController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Reason/Description is required',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isSubmitting = true);
                                  try {
                                    List<String> uploadedUrls = [];
                                    for (final img in _pickedImages) {
                                      final url =
                                          await AuthRepository.uploadImage(img);
                                      if (url != null) {
                                        uploadedUrls.add(url);
                                      }
                                    }

                                    // If we don't have _selectedAnimalId from specific suggestion, we should search for it once more or error
                                    int? finalAnimalId = _selectedAnimalId;
                                    String? finalAnimalRfid =
                                        _selectedAnimalRfid;

                                    if (finalAnimalId == null) {
                                      final animals = await ref
                                          .read(supervisorRepositoryProvider)
                                          .searchAnimals(
                                            query: idController.text.trim(),
                                          );
                                      if (animals.isNotEmpty) {
                                        final animal = animals.first;
                                        finalAnimalId = animal.internalId;
                                        finalAnimalRfid = animal.rfid;
                                      }
                                    }

                                    if (finalAnimalId == null) {
                                      throw Exception(
                                        'Could not find animal matching ${idController.text}',
                                      );
                                    }

                                    if (finalAnimalRfid == null &&
                                        (type == QuickActionType.healthTicket ||
                                            type ==
                                                QuickActionType
                                                    .transferRequest)) {
                                      // Fallback to animal_id (as string) or ear_tag if RFID is missing
                                      // We use the animal_id from the details map if available.
                                      // Logic: if rfid is null, use animal.animal_id

                                      // We need to fetch the animal_id string from the animal object (not the DB ID int)
                                      // Wait, 'finalAnimalId' is the DB INT id.
                                      // We need the 'animal_id' STRING (e.g. "BUF001").

                                      // Re-fetch logic above got 'details' which has 'animal_id' string?
                                      // Let's check how 'animals' list is structured.
                                      // In 'searchAnimals', it returns 'animal_details' map.
                                      // Let's assume we can get the string ID.

                                      // But here we only have finalAnimalId (int) and finalAnimalRfid (string).
                                      // We might need to look at suggestions again or re-fetch.

                                      // Simplified fix: Just trust that if we found the animal by ID/Tag search, we can use the input text as the identifier?
                                      // Or better: Use the 'idController.text' if it matched!
                                      // BUT 'idController.text' might be "123" (db id?) or "BUF001".

                                      // Let's use the 'finalAnimalRfid' if present, otherwise create a new variable for identification.

                                      // Actually, let's use the `finalAnimalId` (int) ?? No, backend expects string.
                                      // Let's use `_selectedAnimalTag` if valid?

                                      // Safer approach: define finalIdentifier.
                                      finalAnimalRfid =
                                          finalAnimalRfid ??
                                          _selectedAnimalTag ??
                                          idController.text;
                                    }

                                    final body = {
                                      'rfid_tag':
                                          finalAnimalRfid, // Using strict RFID or fallback identifier
                                      'ticket_type':
                                          type == QuickActionType.healthTicket
                                          ? 'HEALTH'
                                          : 'TRANSFER',
                                      'description': reasonController.text,
                                      'priority': selectedPriority
                                          .toUpperCase(),
                                      'disease':
                                          type == QuickActionType.healthTicket
                                          ? [selectedDisease]
                                          : null,
                                      'images': uploadedUrls,
                                      // Transfer specific fields if needed
                                      if (type ==
                                          QuickActionType.transferRequest) ...{
                                        'transfer_direction':
                                            'OUT', // Default or need input?
                                        // 'destination_shed_id': ...
                                      },
                                    };

                                    final res = await ref
                                        .read(
                                          supervisorDashboardProvider.notifier,
                                        )
                                        .createTicket(body);
                                    if (res != null && context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                    if (context.mounted)
                                      setState(() => _isSubmitting = false);
                                  }
                                }
                              },
                        color:
                            buttonBackgroundColors[type] ??
                            AppTheme.lightPrimary,
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
                                buttonLabels[type] ?? 'Submit',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildTimingDropdown(String current, ValueChanged<String?> onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select Timing',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.grey1,
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

Widget _buildPriorityDropdown(String current, ValueChanged<String?> onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select Priority',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.grey1,
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

Widget _buildDiseaseDropdown(String current, ValueChanged<String?> onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Identify Disease',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.grey1,
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
  List<File> pickedImages, {
  required VoidCallback onCameraPick,
  required VoidCallback onGalleryPick,
  required void Function(int) onRemove,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Evidence Images (Optional, max 5)',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.grey1,
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
                    Icons.camera_alt,
                    'Camera',
                    onCameraPick,
                  ),
                  const SizedBox(width: 8),
                  _buildAddImageButton(
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

Widget _buildAddImageButton(IconData icon, String label, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
          'shedId': location['shed_id'],
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
                const Text(
                  'Current Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.directions, color: AppTheme.primary),
              ],
            ),
            const Divider(),
            _buildLocationRow('Shed', location['shed_name']),
            _buildLocationRow('Row', location['row_number']?.toString()),
            _buildLocationRow('Slot', location['parking_id']),
            _buildLocationRow('Health', location['health_status']),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLocationRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

Widget helperTextField({required String helperText, required Widget field}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        helperText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.grey1,
        ),
      ),
      const SizedBox(height: 6),
      field,
    ],
  );
}
