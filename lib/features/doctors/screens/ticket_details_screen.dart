import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/models/ticket_model.dart';
import 'package:farm_vest/features/doctors/screens/treatment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class TicketDetailsScreen extends ConsumerWidget {
  final Ticket ticket;

  TicketDetailsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Health Tickets'.tr(ref),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Tabs (Mock UI for visual consistency with design)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab(context, 'All'.tr(ref), false),
                  SizedBox(width: 8),
                  _buildTab(context, 'Pending'.tr(ref), false),
                  SizedBox(width: 8),
                  _buildTab(
                    context,
                    'Approved'.tr(ref),
                    true,
                  ), // Highlights current status roughly
                  SizedBox(width: 8),
                  _buildTab(context, 'In Progress'.tr(ref), false),
                  SizedBox(width: 8),
                  _buildTab(context, 'Completed'.tr(ref), false),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkPrimary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    width: double.infinity,
                    child: Text(
                      'Buffalo Health Ticket Details'.tr(ref),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          'Buffalo ID :'.tr(ref),
                          ticket.animalId ?? 'Unknown'.tr(ref),
                        ),
                        _buildDetailRow(
                          context,
                          'Request Type :'.tr(ref),
                          ticket.ticketType,
                        ), // 'Health Ticket + Medical Assistance'
                        _buildDetailRow(
                          context,
                          'Reason :'.tr(ref),
                          ticket.description,
                        ), // 'Persistent coughing...'
                        _buildDetailRow(
                          context,
                          'Status :'.tr(ref),
                          ticket.status,
                          isStatus: true,
                        ),
                        _buildDetailRow(
                          context,
                          'Requested By :'.tr(ref),
                          'Supervisor Shed 03', // Mock
                        ), // Mock or metadata
                        _buildDetailRow(
                          context,
                          'Date Of Incident :'.tr(ref),
                          ticket.createdAt?.toString().split(' ')[0] ??
                              'N/A'.tr(ref),
                        ),
                        _buildDetailRow(
                          context,
                          'RFID Tag ID :'.tr(ref),
                          ticket.rfid ?? 'N/A'.tr(ref),
                        ),
                        _buildDetailRow(
                          context,
                          'Photo :'.tr(ref),
                          '',
                          isImage: true,
                        ),
                      ],
                    ),
                  ),

                  // Button
                  Padding(
                    padding: EdgeInsets.all(20),
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
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Mark Status'.tr(ref)),
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

  Widget _buildTab(BuildContext context, String text, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.orange
            : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppTheme.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white12
              : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? AppTheme.white
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey[600]),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isStatus = false,
    bool isImage = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.grey[200],
                          height: 60,
                          width: 80,
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: isStatus
                          ? AppTheme.lightPrimary
                          : Theme.of(context).colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ), // Status color logic can be improved
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
