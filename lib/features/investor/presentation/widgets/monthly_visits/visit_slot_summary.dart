import 'package:farm_vest/core/services/localization_service.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/features/investor/data/models/visit_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VisitSlotSummary extends StatelessWidget {
  final AsyncValue<VisitAvailability> asyncData;
  final bool hasBooked;
  final DateTime selectedDate;

  const VisitSlotSummary({
    super.key,
    required this.asyncData,
    required this.hasBooked,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    int totalAvailable = 0;
    asyncData.whenData((data) {
      totalAvailable = data.availableSlots.length;
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary.withOpacity(0.10), Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insights,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Slots Summary'.tr,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat(
                            'MMMM d, yyyy',
                            LocalizationService.currentLanguage,
                          ).format(selectedDate),
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryPill(
                        title: 'Available Slots'.tr,
                        value: totalAvailable.toString(),
                        color: Colors.green,
                        icon: Icons.event_available,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (hasBooked)
                      Expanded(
                        child: _buildSummaryPill(
                          title: 'Status'.tr,
                          value: 'Booked'.tr,
                          color: AppTheme.primary,
                          icon: Icons.check_circle,
                        ),
                      )
                    else
                      Expanded(
                        child: _buildSummaryPill(
                          title: 'Status'.tr,
                          value: 'Open'.tr,
                          color: Colors.orange,
                          icon: Icons.event,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
