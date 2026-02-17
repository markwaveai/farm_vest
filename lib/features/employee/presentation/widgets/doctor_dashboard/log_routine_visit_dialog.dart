import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';

import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class LogRoutineVisitDialog extends ConsumerStatefulWidget {
  LogRoutineVisitDialog({super.key});

  @override
  State<LogRoutineVisitDialog> createState() => _LogRoutineVisitDialogState();
}

class _LogRoutineVisitDialogState extends ConsumerState<LogRoutineVisitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _buffaloIdController = TextEditingController();
  final _observationController = TextEditingController();
  final _healthStatusController = TextEditingController();
  final _nextVisitDateController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void dispose() {
    _buffaloIdController.dispose();
    _observationController.dispose();
    _healthStatusController.dispose();
    _nextVisitDateController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled =
          _buffaloIdController.text.isNotEmpty &&
          _observationController.text.isNotEmpty &&
          _healthStatusController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Log Routine Visit'.tr(ref),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _buffaloIdController,
              hint: 'Buffalo ID',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Buffalo ID is required';
                }
                return null;
              },
              onChanged: (_) => _validateForm(),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: _observationController,
              hint: 'Visit Observation',
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Observation is required';
                }
                return null;
              },
              onChanged: (_) => _validateForm(),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: _healthStatusController,
              hint: 'Health Status (e.g. Healthy, Sick)',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Health Status is required';
                }
                return null;
              },
              onChanged: (_) => _validateForm(),
            ),
            SizedBox(height: 12),
            CustomTextField(
              controller: _nextVisitDateController,
              hint: 'Next Visit Date (Optional)',
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CustomActionButton(
                child: Text(
                  'Log Visit'.tr(ref),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _isButtonEnabled
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          // TODO: Implement log visit logic
                        }
                      }
                    : null,
                color: _isButtonEnabled ? AppTheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
