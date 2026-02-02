import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';

import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';

class TreatPrescribeDialog extends StatefulWidget {
  final String buffaloId;

  const TreatPrescribeDialog({super.key, required this.buffaloId});

  @override
  State<TreatPrescribeDialog> createState() => _TreatPrescribeDialogState();
}

class _TreatPrescribeDialogState extends State<TreatPrescribeDialog> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _medicineController.addListener(_validateForm);
    _dosageController.addListener(_validateForm);
    _notesController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _medicineController.text.trim().isNotEmpty &&
          _dosageController.text.trim().isNotEmpty &&
          _notesController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensure it wraps content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prescribe Medicine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Buffalo ID (read-only)
          CustomTextField(
            initialValue: widget.buffaloId,
            enabled: false,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),

          const SizedBox(height: 12),

          // Medicine name
          CustomTextField(
            hint: 'Medicine Name',
            controller: _medicineController,
          ),

          const SizedBox(height: 12),

          // Dosage
          CustomTextField(
            hint: 'Dosage (e.g. 10ml twice daily)',
            controller: _dosageController,
          ),

          const SizedBox(height: 16),

          const Text(
            'Diagnosis Notes:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          // Diagnosis notes
          CustomTextField(
            hint: 'Enter diagnosis details...',
            maxLines: 3,
            controller: _notesController,
          ),

          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: CustomActionButton(
              child: const Text(
                'Submit Prescription',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _isFormValid
                  ? () {
                      Navigator.pop(context);
                      // TODO: submit prescription logic
                    }
                  : null, // Disable if invalid
              color: _isFormValid ? Colors.green[800]! : Colors.grey,
              variant: ButtonVariant.filled,
            ),
          ),
        ],
      ),
    );
  }
}
