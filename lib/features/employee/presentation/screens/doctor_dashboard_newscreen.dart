import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_Textfield.dart';
import 'package:farm_vest/core/widgets/custom_button_action.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_Textfield.dart';
import 'package:farm_vest/core/widgets/custom_button_action.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class DoctorDashboardNewscreen extends StatefulWidget {
  const DoctorDashboardNewscreen({super.key});

  @override
  State<DoctorDashboardNewscreen> createState() =>
      _DoctorDashboardNewscreenState();
}

class _DoctorDashboardNewscreenState extends State<DoctorDashboardNewscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppConstants.spacingL),
              _buildStatsSection(),
              const SizedBox(height: AppConstants.spacingL),
              _buildPriorityAttentionSection(),
              const SizedBox(height: AppConstants.spacingL),
              _buildQuickActionsSection(),
              const SizedBox(height: AppConstants.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Dr. Sharma',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.dark,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'On Duty',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: CustomCard(
            color: AppTheme.errorRed,
            child: _DashboardStatContent(
              color: AppTheme.errorRed,
              icon: Icons.local_hospital,
              value: '2',
              label: 'Critical Cases',
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: CustomCard(
            color: AppTheme.warningOrange,
            child: _DashboardStatContent(
              color: AppTheme.warningOrange,
              icon: Icons.calendar_today_rounded,
              value: '14',
              label: 'Routine Due',
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: CustomCard(
            color: Colors.green,
            child: _DashboardStatContent(
              color: Colors.green,
              icon: Icons.assignment,
              value: '45',
              label: 'Total Reports',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityAttentionSection() {
    final priorityCards = [
      CustomCard(
        type: DashboardCardType.priority,
        child: _DashboardPriorityContent(
          ticketId: 'TKT-101',
          buffaloId: 'BUF-089',
          issue: 'High Fever & Reduced Appetite',
          time: 'Today, 09:30\nAM',
          onViewHistory: () {},
          onTreatPrescribe: () {
            _showPrescribeMedicineDialog(context, buffaloId: 'BUF-089');
          },
        ),
      ),
      CustomCard(
        type: DashboardCardType.priority,
        child: _DashboardPriorityContent(
          ticketId: 'TKT-102',
          buffaloId: 'BUF-142',
          issue: 'Limping on left hind leg',
          time: 'Yesterday, 04:15\nPM',
          onViewHistory: () {},
          onTreatPrescribe: () {
            _showPrescribeMedicineDialog(context, buffaloId: 'BUF-142');
          },
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Attention Needed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Column(
          children: priorityCards
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                  child: card,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomCard(
                type: DashboardCardType.quickAction,
                child: _DashboardQuickActionContent(
                  icon: Icons.assignment,
                  label: 'Log Routine Visit',
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: CustomCard(
                type: DashboardCardType.quickAction,
                child: _DashboardQuickActionContent(
                  icon: Icons.inventory_2,
                  label: 'Check Inventory',
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: CustomCard(
                type: DashboardCardType.quickAction,
                child: _DashboardQuickActionContent(
                  icon: Icons.search,
                  label: 'Search History',
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPrescribeMedicineDialog(
    BuildContext context, {
    required String buffaloId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Prescribe Medicine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Buffalo ID (read-only)
                CustomTextField(
                  initialValue: buffaloId,
                  enabled: false,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),

                const SizedBox(height: 12),

                // Medicine name
                CustomTextField(hint: 'Medicine Name'),

                const SizedBox(height: 12),

                // Dosage
                CustomTextField(hint: 'Dosage (e.g. 10ml twice daily)'),

                const SizedBox(height: 16),

                const Text(
                  'Diagnosis Notes:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                // Diagnosis notes
                CustomTextField(
                  hint: 'Enter diagnosis details...',
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: CustomActionButton(
                    label: 'Submit Prescription',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: submit prescription logic
                    },
                    color: Colors.green[800]!,
                    variant: ButtonVariant.filled,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _DashboardStatContent({
  required IconData icon,
  required String value,
  required String label,
  required Color color,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.slate,
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}

Widget _DashboardPriorityContent({
  required String ticketId,
  required String buffaloId,
  required String issue,
  required String time,
  required VoidCallback onViewHistory,
  required VoidCallback onTreatPrescribe,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorRed,
                size: 20,
              ),
              SizedBox(width: 8),
            ],
          ),
          Expanded(
            child: Text(
              '$ticketId • $buffaloId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.dark,
              ),
            ),
          ),
          Text(
            time,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),

      const SizedBox(height: 8),

      /// Issue
      Text(
        issue,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.dark,
        ),
      ),

      const SizedBox(height: 16),

      /// Actions
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomActionButton(
            label: 'View History',
            onPressed: onViewHistory,
            color: Colors.green[800]!,
            variant: ButtonVariant.outlined,
          ),
          const SizedBox(width: 10),
          CustomActionButton(
            label: 'Treat & Prescribe',
            onPressed: onTreatPrescribe,
            color: Colors.green[800]!,
            variant: ButtonVariant.filled,
          ),
        ],
      ),
    ],
  );
}

Widget _DashboardQuickActionContent({
  required IconData icon,
  required String label,
  required Color color,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(height: 12),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.dark,
        ),
      ),
    ],
  );
}
