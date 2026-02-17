import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/models/ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class TreatmentDetailsScreen extends ConsumerStatefulWidget {
  final Ticket ticket;

  TreatmentDetailsScreen({super.key, required this.ticket});

  @override
  State<TreatmentDetailsScreen> createState() => _TreatmentDetailsScreenState();
}

class _TreatmentDetailsScreenState extends ConsumerState<TreatmentDetailsScreen> {
  final _tempController = TextEditingController();
  final _notesController = TextEditingController();
  String _activityLevel = 'Normal'; // Low, Normal, HyperActive
  String _status =
      'In Progress'; // Quarantine, Observation, In Progress based on radio/checkbox logic in image?
  // Image shows radio buttons: Low, Normal, HyperActive
  // And below notes: Quarantine, Observation (Radio or Checkbox?) Image shows circles, likely Radio.

  String _actionRequired = 'Observation';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Treatment Details'.tr(ref),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buffalo ID'.tr(ref),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            _buildReadOnlyField(
              context,
              '',
              widget.ticket.animalId ?? 'Unknown',
            ),
            SizedBox(height: 24),
            Text(
              'Shed Location'.tr(ref),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            _buildReadOnlyField(context, '', 'Shed 04'), // Mock or fetch

            SizedBox(height: 24),
            Text(
              'Current Vital Signs'.tr(ref),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12),
            _buildMetricInput(
              context,
              'Body Temperature'.tr(ref),
              '102.3',
              '°F',
              _tempController,
            ),

            SizedBox(height: 24),
            Text(
              'Activity Level'.tr(ref),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                _buildRadioOption(
                  context,
                  'Low'.tr(ref),
                  'Low'.tr(ref),
                  (val) => setState(() => _activityLevel = val!),
                ),
                _buildRadioOption(
                  context,
                  'Normal'.tr(ref),
                  'Normal'.tr(ref),
                  (val) => setState(() => _activityLevel = val!),
                ),
                _buildRadioOption(
                  context,
                  'HyperActive'.tr(ref),
                  'HyperActive'.tr(ref),
                  (val) => setState(() => _activityLevel = val!),
                ),
              ],
            ),

            SizedBox(height: 24),
            Text(
              'Notes'.tr(ref),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter treatment notes...'.tr(ref),
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),
            Row(
              children: [
                _buildActionRadio(context, 'Quarantine', 'Quarantine'.tr(ref)),
                SizedBox(width: 20),
                _buildActionRadio(context, 'Observation', 'Observation'.tr(ref)),
              ],
            ),

            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showSuccessDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Submit'.tr(ref)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(color: AppTheme.grey, fontSize: 13),
          ),
          SizedBox(height: 6),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : Colors.grey.shade200,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricInput(
    BuildContext context,
    String label,
    String hint,
    String suffix,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
            suffixText: suffix,
            suffixStyle: TextStyle(color: Theme.of(context).hintColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white12
                    : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white12
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(
    BuildContext context,
    String value,
    String label,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _activityLevel,
          onChanged: onChanged,
          activeColor: AppTheme.darkPrimary,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _buildActionRadio(BuildContext context, String value, String label) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _actionRequired,
          onChanged: (val) {
            setState(() => _actionRequired = val!);
          },
          activeColor: AppTheme.darkPrimary,
          visualDensity: VisualDensity.compact,
        ),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : AppTheme.darkPrimary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              width: double.infinity,
              child: Text(
                'HEALTH SUCCESSFULLY COMPLETED'.tr(ref),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${'Date'.tr(ref)}: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/buffalo.png',
                      height: 100,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        width: 140,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[200],
                        child: Icon(
                          Icons.pets,
                          size: 50,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Successfully submitted buffalo treatment details.'.tr(ref),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Close dialog
                        Navigator.pop(context);
                        // Return to the tickets list screen
                        // We use popUntil to ensure we go back to the health tickets list
                        Navigator.popUntil(context, (route) {
                          return route.isFirst ||
                              (route.settings.name == '/all-health-tickets');
                        });

                        // If we are not using named routes for the list, we might need a different approach
                        // But since we are likely in a simple push stack now:
                        // Navigator.pop(context); // This would close the treatment screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.05)
                            : AppTheme.darkPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : Colors.transparent,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Done'.tr(ref),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
