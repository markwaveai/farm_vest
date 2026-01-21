import 'package:farm_vest/core/widgets/custom_Textfield.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QuickActionType {
  milkEntry,
  healthTicket,
  transferRequest,
  locateAnimal,
}

const Map<QuickActionType, String> buttonLabels = {
  QuickActionType.milkEntry: 'Submit Entry',
  QuickActionType.healthTicket: 'Raise Critical Ticket',
  QuickActionType.transferRequest: 'Submit',
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
  String selectedPriority = 'Critical';
  String selectedTiming = 'Morning';

  final quantityController = TextEditingController();
  final reasonController = TextEditingController();
  final idController = TextEditingController();

  String dialogTitle = '';
  bool showShedButtons = false;
  String successMessage = '';
  List<Widget> fields = [];
  bool _isSubmitting = false;

  switch (type) {
    case QuickActionType.milkEntry:
      dialogTitle = 'Milk Entry';
      showShedButtons = true;
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

      fields = [
        helperTextField(
          helperText: 'Please enter Buffalo ID / RFID',
          field: CustomTextField(
            hint: 'Buffalo ID / RFID',
            controller: idController,
          ),
        ),
        helperTextField(
          helperText: 'Please describe the issue',
          field: CustomTextField(
            hint: 'Enter issue',
            controller: reasonController,
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
            controller: reasonController,
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

          return StatefulBuilder(builder: (context, setState) {
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
                        if (showShedButtons) ...[
                          const SizedBox(height: 12),
                          // ... (rest of the shed buttons logic)
                        ],
                        if (type == QuickActionType.locateAnimal) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  hint: 'Search Animal by ID',
                                  controller: idController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomActionButton(
                                width: 48,
                                height: 48,
                                color: AppTheme.lightPrimary,
                                onPressed: () {
                                  final id = int.tryParse(idController.text);
                                  if (id != null) {
                                    ref
                                        .read(supervisorDashboardProvider.notifier)
                                        .locateAnimal(id);
                                  }
                                },
                                child: const Center(
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (dashboardState.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (dashboardState.error != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dashboardState.error!,
                                  style: const TextStyle(color: Colors.red)),
                            )
                          else if (dashboardState.animalLocation != null)
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Location',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Shed:'),
                                        Text(
                                          dashboardState.animalLocation!['shed'] ??
                                              'N/A',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Row:'),
                                        Text(
                                          dashboardState.animalLocation!['row'] ??
                                              'N/A',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Slot:'),
                                        Text(
                                          dashboardState.animalLocation!['slot'] ??
                                              'N/A',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Health:'),
                                        Text(
                                          dashboardState.animalLocation!['health'] ??
                                              'N/A',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  if (type != QuickActionType.locateAnimal)
                  const SizedBox(height: 16),
                  if (type != QuickActionType.locateAnimal)
                  CustomActionButton(
                    onPressed: () async {
                      if (type == QuickActionType.milkEntry) {
                        setState(() {
                          _isSubmitting = true;
                        });

                        String? finalErrorMessage;
                        Map<String, dynamic>? successResponse;

                        try {
                          successResponse = await ref
                              .read(supervisorDashboardProvider.notifier)
                              .createMilkEntry(
                                timing: selectedTiming,
                                quantity: quantityController.text,
                              );
                        } catch (e) {
                          finalErrorMessage = e.toString();
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isSubmitting = false;
                            });
                            Navigator.pop(context);
                          }
                        }

                        if (context.mounted) {
                          if (finalErrorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(finalErrorMessage), backgroundColor: Colors.red));
                          } else if (successResponse != null) {
                            final quantity = successResponse['quantity'];
                            final timing = successResponse['timing'];
                            final successMessage =
                                'Today\'s $timing milk entry of $quantity L has been added successfully.';
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(successMessage), backgroundColor: Colors.green));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to create milk entry. Please try again.'), backgroundColor: Colors.red,));
                          }
                        }
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(successMessage)));
                      }
                    },
                    color: buttonBackgroundColors[type] ?? AppTheme.lightPrimary,
                    width: double.infinity,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            buttonLabels[type] ?? 'Submit',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            );
          });
        },
      );
    },
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
