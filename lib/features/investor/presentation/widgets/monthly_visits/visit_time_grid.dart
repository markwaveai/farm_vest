import 'package:farm_vest/core/services/localization_service.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VisitTimeGrid extends StatelessWidget {
  final List<String> availableSlots;
  final String? selectedSlotTime;
  final DateTime selectedDate;
  final bool hasBookedThisMonth;
  final bool isDark;
  final ValueChanged<String> onSlotSelected;

  const VisitTimeGrid({
    super.key,
    required this.availableSlots,
    required this.selectedSlotTime,
    required this.selectedDate,
    required this.hasBookedThisMonth,
    required this.isDark,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No slots available".tr,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final time = availableSlots[index];
        bool isSelected = selectedSlotTime == time;
        bool isExpired = false;

        // Parse time to check expiry
        DateTime? slotDateTime;
        try {
          final timeParts = time.split(':');
          if (timeParts.length >= 2) {
            slotDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              int.parse(timeParts[0]), // Hour
              int.parse(timeParts[1]), // Minute
              int.parse(timeParts.length > 2 ? timeParts[2] : '0'), // Second
            );
          }
        } catch (e) {
          // ignore parse error
        }

        if (isToday && slotDateTime != null && slotDateTime.isBefore(now)) {
          isExpired = true;
        }

        // Format time for display (09:00:00 -> 09:00 AM)
        String displayTime = time;
        try {
          final dt = DateFormat("HH:mm:ss").parse(time);
          displayTime = DateFormat(
            "h:mm a",
            LocalizationService.currentLanguage,
          ).format(dt);
        } catch (e) {
          // keep as is
        }

        Color bgColor = isDark ? Colors.grey.shade50 : Colors.transparent;
        Color borderColor = AppTheme.successGreen.withOpacity(0.3);
        Color textColor = isDark ? AppTheme.white : AppTheme.black87;
        if (isExpired) {
          bgColor = isDark ? Colors.grey.shade600 : Colors.grey.shade100;
          borderColor = Colors.transparent;
          textColor = isDark ? AppTheme.white : AppTheme.black87;
        } else if (isSelected) {
          bgColor = AppTheme.successGreen;
          borderColor = AppTheme.successGreen;
          textColor = AppTheme.white;
        } else {
          bgColor = isDark ? AppTheme.white : Colors.transparent;
          borderColor = AppTheme.successGreen.withOpacity(0.3);
          textColor = AppTheme.black;
        }

        return InkWell(
          onTap: (isExpired || hasBookedThisMonth)
              ? (hasBookedThisMonth && !isExpired
                    ? () => ToastUtils.showInfo(
                        context,
                        "You have already booked a slot for this month.".tr,
                      )
                    : null)
              : () {
                  onSlotSelected(time);
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Text(
              displayTime,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}
