import 'package:dotted_border/dotted_border.dart';
import 'package:farm_vest/core/widgets/custom_Textfield.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';

import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum QuickActionType {
  onboardAnimal,
  milkEntry,
  healthTicket,
  transferRequest,
  locateAnimal,
}

const Map<QuickActionType, String> buttonLabels = {
  QuickActionType.onboardAnimal: 'Submit',
  QuickActionType.milkEntry: 'Submit Entry',
  QuickActionType.healthTicket: 'Raise Critical Ticket',
  QuickActionType.transferRequest: 'Submit',
  QuickActionType.locateAnimal: 'Search',
};
const Map<QuickActionType, Color> buttonBackgroundColors = {
  QuickActionType.onboardAnimal: AppTheme.lightPrimary,
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
  Map<String, dynamic>? locateResult;
  String selectedPriority = 'Critical';
  String selectedTiming = 'Morning';
  int selectedSlot = 5;
  List<XFile> selectedImages = [];
  //final picker = ImagePicker();

  final rfidController = TextEditingController();
  final shedController = TextEditingController();
  final breedController = TextEditingController();
  final quantityController = TextEditingController();
  final buffaloIdController = TextEditingController();
  final reasonController = TextEditingController();
  final idController = TextEditingController();
  final requestController = TextEditingController();
  final rowController = TextEditingController();

  final Map<String, Map<String, String>> animalData = {
    'R': {
      'shed': 'Shed C',
      'row': 'Row-04',
      'slot': 'Slot-12',
      'health': 'Healthy',
      'investor': 'aparna',
    },
    'A': {
      'shed': 'Shed B',
      'row': 'Row-01',
      'slot': 'Slot-03',
      'health': 'Sick',
      'investor': 'pradeep',
    },
  };

  String dialogTitle = '';
  bool showShedButtons = false;
  bool showImagePicker = false;
  String successMessage = '';
  List<Widget> fields = [];
  List<TextEditingController> controllers = [];

  switch (type) {
    case QuickActionType.onboardAnimal:
      dialogTitle = 'Onboard Animal';
      showImagePicker = true;
      successMessage = 'Animal onboarded successfully!';

      controllers = [shedController, breedController, rowController];
      fields = [
        helperTextField(
          helperText: 'Please enter shed number',
          field: CustomTextField(
            hint: 'Enter shed',
            controller: shedController,
          ),
        ),
        helperTextField(
          helperText: 'Please enter breed & age',
          field: CustomTextField(
            hint: 'Enter breed & age',
            controller: breedController,
          ),
        ),
        helperTextField(
          helperText: 'Please enter row number',
          field: CustomTextField(
            hint: 'Enter Row No',
            controller: rowController,
          ),
        ),
      ];

      break;

    case QuickActionType.milkEntry:
      dialogTitle = 'Milk Entry';
      showShedButtons = true;
      successMessage = 'Milk data recorded successfully!';
      controllers = [quantityController];
      fields = [
        helperTextField(
          helperText: 'Please enter quantity in liters',
          field: CustomTextField(
            hint: 'Enter quantity',
            controller: quantityController,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a timing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey1,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedTiming,
              items: const [
                DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                DropdownMenuItem(value: 'Afternoon', child: Text('Afternoon')),
                DropdownMenuItem(value: 'Evening', child: Text('Evening')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedTiming = value;
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ];

      break;

    case QuickActionType.healthTicket:
      dialogTitle = 'Report Health Ticket';
      successMessage = 'Health ticket raised successfully!';

      controllers = [reasonController, buffaloIdController];

      fields = [
        helperTextField(
          helperText: 'Please enter Buffalo ID / RFID',
          field: CustomTextField(
            hint: 'Buffalo ID / RFID',
            controller: reasonController,
          ),
        ),
        helperTextField(
          helperText: 'Please describe the issue',
          field: CustomTextField(
            hint: 'Enter issue',
            controller: buffaloIdController,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Priority',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.grey1,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedPriority,
              items: const [
                DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                DropdownMenuItem(value: 'High', child: Text('High')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Low', child: Text('Low')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedPriority = value;
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ];
      break;

    case QuickActionType.transferRequest:
      dialogTitle = 'Transfer Request';
      showShedButtons = true;
      successMessage = 'Transfer request submitted!';

      controllers = [idController, requestController];
      fields = [
        helperTextField(
          helperText: 'Please enter ID',
          field: CustomTextField(
            hint: 'Enter buffalo ID/RFID',
            controller: idController,
          ),
        ),
        helperTextField(
          helperText: 'Please enter reason ',
          field: CustomTextField(
            hint: 'Enter reason',
            controller: requestController,
          ),
        ),
      ];
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

          void showImageSourceDialog() {
            showDialog(
              context: context,
              builder: (context) {
                return CustomDialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select Image Source',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: AppTheme.grey1.withValues(alpha: 0.5)),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Camera'),
                        onTap: () async {
                          Navigator.pop(context);
                          await ref
                              .read(supervisorDashboardProvider.notifier)
                              .pickFromCamera();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Gallery'),
                        onTap: () async {
                          Navigator.pop(context);
                          await ref
                              .read(supervisorDashboardProvider.notifier)
                              .pickFromGallery();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }

          final screenWidth = MediaQuery.of(context).size.width;
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      if (type != QuickActionType.locateAnimal)
                        ...fields.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: f,
                          ),
                        ),
                      if (showImagePicker) ...[
                        const SizedBox(height: 12),

                        /// Upload button
                        DottedBorder(
                          radius: const Radius.circular(10),
                          color: AppTheme.lightPrimary,
                          dashPattern: const [6, 4],
                          strokeWidth: 1,
                          child: InkWell(
                            // onTap: pickImages,
                            onTap: showImageSourceDialog,
                            child: SizedBox(
                              height: 60,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.upload_file,
                                      color: AppTheme.lightPrimary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Upload Buffalo Image',
                                      style: TextStyle(
                                        color: AppTheme.lightPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        if (dashboardState.images.isNotEmpty)
                          Container(
                            height: 110,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.grey1.withValues(alpha: 0.3),
                              ),
                            ),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              itemCount: dashboardState.images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final image = dashboardState.images[index];

                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildImage(image),
                                    ),
                                    if (image.isUploading)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black26,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (image.hasError)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black26,
                                          child: const Center(
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(
                                                supervisorDashboardProvider
                                                    .notifier,
                                              )
                                              .removeImageAt(index);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                        // if (imageNotifier.selectedImages.isNotEmpty)
                        // Container(
                        //   height: 110,
                        //   padding: const EdgeInsets.symmetric(vertical: 8),
                        //   decoration: BoxDecoration(
                        //     color: AppTheme.white,
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //       color: AppTheme.grey1.withOpacity(0.3),
                        //     ),
                        //   ),
                        //   child: ListView.separated(
                        //     scrollDirection: Axis.horizontal,
                        //     padding: const EdgeInsets.symmetric(horizontal: 8),
                        //     itemCount: imageNotifier.selectedImages.length,
                        //     separatorBuilder: (_, __) => const SizedBox(width: 8),
                        //     itemBuilder: (context, index) {
                        //       final image = imageNotifier.selectedImages[index];

                        //       return Stack(
                        //         children: [
                        //           FutureBuilder<Uint8List>(
                        //             future: image.readAsBytes(),
                        //             builder: (context, snapshot) {
                        //               if (!snapshot.hasData) {
                        //                 return const SizedBox(
                        //                   width: 90,
                        //                   height: 90,
                        //                   child: Center(
                        //                     child: CircularProgressIndicator(strokeWidth: 2),
                        //                   ),
                        //                 );
                        //               }

                        //               return ClipRRect(
                        //                 borderRadius: BorderRadius.circular(10),
                        //                 child: Image.memory(
                        //                   snapshot.data!,
                        //                   width: 90,
                        //                   height: 90,
                        //                   fit: BoxFit.cover,
                        //                 ),
                        //               );
                        //             },
                        //           ),
                        //           Positioned(
                        //             top: 4,
                        //             right: 4,
                        //             child: GestureDetector(
                        //               onTap: () {
                        //                 ref.read(imagePickerProvider).removeAt(index);
                        //               },
                        //               child: Container(
                        //                 padding: const EdgeInsets.all(2),
                        //                 decoration: const BoxDecoration(
                        //                   color: Colors.white,
                        //                   shape: BoxShape.circle,
                        //                 ),
                        //                 child: const Icon(
                        //                   Icons.close,
                        //                   size: 16,
                        //                   color: Colors.red,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       );
                        //     },
                        //   ),
                        // ),

                        //  if (selectedImages.isNotEmpty)
                        // Container(
                        //   height: 110,
                        //   padding: const EdgeInsets.symmetric(vertical: 8),
                        //   decoration: BoxDecoration(
                        //     color: AppTheme.white,
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //       color: AppTheme.grey1.withOpacity(0.3),
                        //     ),
                        //   ),
                        //   child: ListView.separated(
                        //     scrollDirection: Axis.horizontal,
                        //     padding: const EdgeInsets.symmetric(horizontal: 8),
                        //     itemCount: selectedImages.length,
                        //     separatorBuilder: (_, __) => const SizedBox(width: 8),
                        //     itemBuilder: (context, index) {
                        //       return Stack(
                        //         children: [
                        //           FutureBuilder<Uint8List>(
                        //             future: selectedImages[index].readAsBytes(),
                        //             builder: (context, snapshot) {
                        //               if (!snapshot.hasData) {
                        //                 return const SizedBox(
                        //                   width: 90,
                        //                   height: 90,
                        //                   child: Center(
                        //                     child: CircularProgressIndicator(strokeWidth: 2),
                        //                   ),
                        //                 );
                        //               }

                        //               return ClipRRect(
                        //                 borderRadius: BorderRadius.circular(10),
                        //                 child: Image.memory(
                        //                   snapshot.data!,
                        //                   width: 90,
                        //                   height: 90,
                        //                   fit: BoxFit.cover,
                        //                 ),
                        //               );
                        //             },
                        //           ),
                        //           Positioned(
                        //             top: 4,
                        //             right: 4,
                        //             child: GestureDetector(
                        //               onTap: (){
                        //                 ref.read(imagePickerProvider).removeAt(index);
                        //               },
                        //               // onTap: () {
                        //               //   setStateDialog(() {
                        //               //     selectedImages.removeAt(index);
                        //               //   });
                        //               // },
                        //               child: Container(
                        //                 padding: const EdgeInsets.all(2),
                        //                 decoration: const BoxDecoration(
                        //                   color: Colors.white,
                        //                   shape: BoxShape.circle,
                        //                 ),
                        //                 child: const Icon(
                        //                   Icons.close,
                        //                   size: 16,
                        //                   color: Colors.red,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                      if (showShedButtons) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Select Target Shed:',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.grey1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Shed A', 'Shed B', 'Shed C'].map((shed) {
                            final selected = selectedShed == shed;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: CustomActionButton(
                                  child: Text(shed),
                                  height: 40,
                                  variant: selected
                                      ? ButtonVariant.filled
                                      : ButtonVariant.outlined,
                                  color: AppTheme.darkSecondary,
                                  onPressed: () {
                                    selectedShed = shed;
                                    ref.refresh(supervisorDashboardProvider);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (type == QuickActionType.locateAnimal) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                hint: 'Search Animal',
                                controller: idController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CustomActionButton(
                              width: 48,
                              height: 48,
                              color: AppTheme.lightPrimary,
                              onPressed: () {
                                final key = idController.text.trim();
                                if (key.isEmpty ||
                                    !animalData.containsKey(key)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Buffalo not found'),
                                    ),
                                  );
                                  return;
                                }
                                locateResult = animalData[key];
                                selectedSlot = int.parse(
                                  locateResult!['row'].toString().replaceAll(
                                    'Row-',
                                    '',
                                  ),
                                );
                                ref.refresh(supervisorDashboardProvider);
                              },
                              child: const Center(
                                child: Icon(
                                  Icons.search,
                                  color: AppTheme.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (locateResult != null)
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            color: AppTheme.white,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: AppTheme.lightPrimary,
                                        child: Icon(
                                          Icons.pets,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '#BUF-889',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            'Investor',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.grey1,
                                            ),
                                          ),
                                          Text(
                                            locateResult!['investor'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.grey1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Current Location: ${locateResult!['shed']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.grey1),
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppTheme.white,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          locateResult!['row'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: List.generate(6, (index) {
                                            final boxNumber = index + 1;
                                            final isRowBox =
                                                boxNumber == selectedSlot;

                                            return Container(
                                              width: 36,
                                              height: 36,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isRowBox
                                                    ? AppTheme.lightPrimary
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppTheme.grey1,
                                                ),
                                              ),
                                              child: Text(
                                                '$boxNumber',
                                                style: TextStyle(
                                                  color: isRowBox
                                                      ? AppTheme.white
                                                      : AppTheme.dark,
                                                  fontWeight: isRowBox
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CustomActionButton(
                  onPressed: () async {
                    if (type == QuickActionType.onboardAnimal) {
                      final success = await ref
                          .read(supervisorDashboardProvider.notifier)
                          .onboardAnimal(
                            shed: shedController.text,
                            breed: breedController.text,
                            row: rowController.text,
                          );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(successMessage)));
                      }
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(successMessage)));
                    }
                  },
                  color: buttonBackgroundColors[type] ?? AppTheme.lightPrimary,
                  width: double.infinity,
                  child: Text(
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
}

Widget _buildImage(DashboardImage image) {
  if (image.localFile != null) {
    return Image.file(
      image.localFile!,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
    );
  } else if (image.networkUrl != null) {
    return Image.network(
      image.networkUrl!,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildShimmerPlaceholder();
      },
    );
  }
  return _buildErrorPlaceholder();
}

Widget _buildErrorPlaceholder() {
  return Container(
    width: 90,
    height: 90,
    color: Colors.grey[200],
    child: const Icon(Icons.error_outline),
  );
}

Widget _buildShimmerPlaceholder() {
  return Container(
    width: 90,
    height: 90,
    color: Colors.grey[200],
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
