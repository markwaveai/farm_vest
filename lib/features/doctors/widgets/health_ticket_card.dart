import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HealthTicketCard extends StatelessWidget {
  final String ticketId;
  final String description;
  final String timeAgo;
  final String status;
  final VoidCallback? onAssignTap;
  final VoidCallback? onViewDetailsTap;
  final VoidCallback? onActionTap; // For "Treatment" or "Add Vaccine"
  final bool isVaccination; // To toggle between Treatment and Add Vaccine

  const HealthTicketCard({
    super.key,
    required this.ticketId,
    required this.description,
    required this.timeAgo,
    required this.status,
    this.onAssignTap,
    this.onViewDetailsTap,
    this.onActionTap,
    this.isVaccination = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        children: [
          _cardHeader(),

          _cardBody(),
          Divider(thickness: 0.5, color: AppTheme.grey1),
          _cardBottom(),
        ],
      ),
    );
  }

  Widget _cardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.darkPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.pets, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ticketId,
              style: const TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(timeAgo, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _cardBody() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: TextStyle(color: AppTheme.mediumGrey)),
          Divider(thickness: 0.5, color: AppTheme.grey1),
          const SizedBox(height: 12),
          Row(
            children: [
              _iconText(Icons.remove_red_eye, "View Profile"),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: onActionTap,
                child: _iconText(
                  isVaccination
                      ? Icons.vaccines_outlined
                      : Icons.medical_services_outlined,
                  isVaccination ? "Add Vaccine" : "Treatment",
                ),
              ),
              const Spacer(),
              _statusChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBottom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onViewDetailsTap,
            child: _iconText(Icons.confirmation_num_outlined, "Ticket Details"),
          ),
          // const Spacer(),
          if (onAssignTap != null) ...[
            SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: onAssignTap,
              child: const Text("Assign"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip() {
    Color bgColor;
    Color textColor = Colors.white;
    bool isSolid = false;

    switch (status.toLowerCase()) {
      case "approved":
        bgColor = Colors.green;
        isSolid = true;
        break;
      case "completed":
        bgColor = Colors.green;
        break;
      case "pending":
        bgColor = Colors.orange;
        isSolid = true; // Make pending solid based on design
        break;
      case "in progress":
        bgColor = Colors.amber;
        isSolid = true;
        break;
      default:
        bgColor = Colors.grey;
    }

    // Adapt to existing style vs design style
    // Design has solid chips. Existing has transparent bg with colored text.
    // We will use solid if isVaccination is true to match design preference, or mix.

    // Using the 'design' style for the specified statuses
    if (isSolid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: bgColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.darkPrimary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.darkPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
