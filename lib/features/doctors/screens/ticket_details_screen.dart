import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/admin/data/models/ticket_model.dart';
import 'package:farm_vest/features/doctors/screens/treatment_details_screen.dart';
import 'package:flutter/material.dart';

class TicketDetailsScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // F4F6F8
      appBar: AppBar(
        title: const Text('Health Tickets'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Tabs (Mock UI for visual consistency with design)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('All', false),
                  const SizedBox(width: 8),
                  _buildTab('Pending', false),
                  const SizedBox(width: 8),
                  _buildTab(
                    'Approved',
                    true,
                  ), // Highlights current status roughly
                  const SizedBox(width: 8),
                  _buildTab('In Progress', false),
                  const SizedBox(width: 8),
                  _buildTab('Completed', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: AppTheme.darkPrimary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    width: double.infinity,
                    child: const Text(
                      'Buffalo Health Ticket Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Buffalo ID :',
                          ticket.animalId ?? 'Unknown',
                        ),
                        _buildDetailRow(
                          'Request Type :',
                          ticket.ticketType,
                        ), // 'Health Ticket + Medical Assistance'
                        _buildDetailRow(
                          'Reason :',
                          ticket.description,
                        ), // 'Persistent coughing...'
                        _buildDetailRow(
                          'Status :',
                          ticket.status,
                          isStatus: true,
                        ),
                        _buildDetailRow(
                          'Requested By :',
                          'Supervisor Shed 03',
                        ), // Mock or metadata
                        _buildDetailRow(
                          'Date Of Incident :',
                          ticket.createdAt?.toString().split(' ')[0] ?? 'N/A',
                        ),
                        _buildDetailRow('RFID Tag ID :', ticket.rfid ?? 'N/A'),
                        _buildDetailRow('Photo :', '', isImage: true),
                      ],
                    ),
                  ),

                  // Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TreatmentDetailsScreen(ticket: ticket),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Mark Status'),
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

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.orange
            : AppTheme.white, // Colors.transparent or white
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppTheme.white : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isImage = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: isImage
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/buffalo.png',
                        height: 60,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          height: 60,
                          width: 80,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: isStatus
                          ? AppTheme.lightPrimary
                          : Colors
                                .black54, // Status color logic can be improved
                      fontWeight: isStatus
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
