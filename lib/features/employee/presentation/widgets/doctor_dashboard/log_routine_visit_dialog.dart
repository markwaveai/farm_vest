import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';

import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';

class LogRoutineVisitDialog extends StatefulWidget {
  const LogRoutineVisitDialog({super.key});

  @override
  State<LogRoutineVisitDialog> createState() => _LogRoutineVisitDialogState();
}

class _LogRoutineVisitDialogState extends State<LogRoutineVisitDialog> {
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
                const Text(
                  'Log Routine Visit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            CustomTextField(
              controller: _nextVisitDateController,
              hint: 'Next Visit Date (Optional)',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CustomActionButton(
                child: const Text(
                  'Log Visit',
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
