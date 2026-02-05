import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/admin/data/models/ticket_model.dart';
import 'package:flutter/material.dart';

class TreatmentDetailsScreen extends StatefulWidget {
  final Ticket ticket;

  const TreatmentDetailsScreen({super.key, required this.ticket});

  @override
  State<TreatmentDetailsScreen> createState() => _TreatmentDetailsScreenState();
}

class _TreatmentDetailsScreenState extends State<TreatmentDetailsScreen> {
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
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Treatment Details'),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buffalo ID',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildReadOnlyField('', widget.ticket.animalId ?? 'Unknown'),
            const SizedBox(height: 24),
            const Text(
              'Shed Location',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildReadOnlyField('', 'Shed 04'), // Mock or fetch

            const SizedBox(height: 24),
            const Text(
              'Current Vital Signs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildMetricInput(
              'Body Temperature',
              '102.3',
              '°F',
              _tempController,
            ),

            const SizedBox(height: 24),
            const Text(
              'Activity Level',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRadioOption(
                  'Low',
                  'Low',
                  (val) => setState(() => _activityLevel = val!),
                ),
                _buildRadioOption(
                  'Normal',
                  'Normal',
                  (val) => setState(() => _activityLevel = val!),
                ),
                _buildRadioOption(
                  'HyperActive',
                  'HyperActive',
                  (val) => setState(() => _activityLevel = val!),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter treatment notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                _buildActionRadio('Quarantine', 'Quarantine'),
                const SizedBox(width: 20),
                _buildActionRadio('Observation', 'Observation'),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showSuccessDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(color: AppTheme.grey, fontSize: 13),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricInput(
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
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(
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
        Text(label),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildActionRadio(String value, String label) {
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
        Text(label),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: AppTheme.darkPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              width: double.infinity,
              child: const Text(
                'HEALTH SUCCESSFULLY COMPLETED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
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
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.pets,
                          size: 50,
                          color: AppTheme.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Successfully submitted not buffalo treatment details.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 32),
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
                        backgroundColor: AppTheme.darkPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Done'),
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
