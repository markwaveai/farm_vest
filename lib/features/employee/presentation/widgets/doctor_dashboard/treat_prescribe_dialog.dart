import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';

import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class TreatPrescribeDialog extends ConsumerStatefulWidget {
  final String buffaloId;

  TreatPrescribeDialog({super.key, required this.buffaloId});

  @override
  State<TreatPrescribeDialog> createState() => _TreatPrescribeDialogState();
}

class _TreatPrescribeDialogState extends ConsumerState<TreatPrescribeDialog> {
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
              Text(
                'Prescribe Medicine'.tr(ref),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Buffalo ID (read-only)
          CustomTextField(
            initialValue: widget.buffaloId,
            enabled: false,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),

          SizedBox(height: 12),

          // Medicine name
          CustomTextField(
            hint: 'Medicine Name',
            controller: _medicineController,
          ),

          SizedBox(height: 12),

          // Dosage
          CustomTextField(
            hint: 'Dosage (e.g. 10ml twice daily)',
            controller: _dosageController,
          ),

          SizedBox(height: 16),

          Text(
            'Diagnosis Notes:'.tr(ref),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 8),

          // Diagnosis notes
          CustomTextField(
            hint: 'Enter diagnosis details...',
            maxLines: 3,
            controller: _notesController,
          ),

          SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: CustomActionButton(
              child: Text(
                'Submit Prescription'.tr(ref),
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
