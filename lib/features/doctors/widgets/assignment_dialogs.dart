import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AssignTicketDialog extends StatefulWidget {
  final String ticketId;
  final String buffaloId;
  final Function(String assistantName) onAssign;

  const AssignTicketDialog({
    super.key,
    required this.ticketId,
    required this.buffaloId,
    required this.onAssign,
  });

  @override
  State<AssignTicketDialog> createState() => _AssignTicketDialogState();
}

class _AssignTicketDialogState extends State<AssignTicketDialog> {
  String? _selectedAssistant;
  final List<String> _assistants = [
    'Dr. Sudheer',
    'Dr. Rajesh',
    'Dr. Priya',
    'Dr. Amit',
  ]; // Mock data

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              'Assigned to Assistant',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Case:', widget.ticketId),
                const SizedBox(height: 8),
                _buildDetailRow('Buffalo:', widget.buffaloId),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedAssistant,
                  decoration: InputDecoration(
                    labelText: 'Assign to',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: _assistants.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedAssistant = newValue;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.darkPrimary,
                          side: const BorderSide(color: AppTheme.darkPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedAssistant != null
                            ? () {
                                final selected = _selectedAssistant!;
                                widget.onAssign(selected);
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AssignmentSuccessDialog(
                                    ticketId: widget.ticketId,
                                    assignedTo: selected,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Assign'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AssignmentSuccessDialog extends StatelessWidget {
  final String ticketId;
  final String assignedTo;

  const AssignmentSuccessDialog({
    super.key,
    required this.ticketId,
    required this.assignedTo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              'Assigned to Assistant',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/buffalo.png', // Evaluate available assets
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.pets,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$ticketId Ticket has been successfully Assigned to $assignedTo',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
    );
  }
}
