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
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white12
              : Colors.grey.shade300,
        ),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          _cardHeader(context),

          _cardBody(context),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : AppTheme.grey1,
          ),
          _cardBottom(context),
        ],
      ),
    );
  }

  Widget _cardHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : AppTheme.darkPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppTheme.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            timeAgo,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).hintColor
                  : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : AppTheme.grey1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _iconText(context, Icons.remove_red_eye, "View Profile"),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: onActionTap,
                child: _iconText(
                  context,
                  isVaccination
                      ? Icons.vaccines_outlined
                      : Icons.medical_services_outlined,
                  isVaccination ? "Add Vaccine" : "Treatment",
                ),
              ),
              const Spacer(),
              _statusChip(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBottom(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onViewDetailsTap,
            child: _iconText(
              context,
              Icons.confirmation_num_outlined,
              "Ticket Details",
            ),
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
              child: Text(
                "Assign",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
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

  Widget _iconText(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.onSurface
              : AppTheme.darkPrimary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onSurface
                : AppTheme.darkPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
