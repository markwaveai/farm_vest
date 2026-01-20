import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:farm_vest/features/employee/presentation/screens/check_inventory_screen.dart';
import 'package:farm_vest/features/employee/presentation/screens/search_history_screen.dart';
import 'package:farm_vest/features/employee/presentation/widgets/doctor_dashboard/log_routine_visit_dialog.dart';
import 'package:farm_vest/features/employee/presentation/widgets/doctor_dashboard/treat_prescribe_dialog.dart';
import 'package:farm_vest/features/employee/presentation/widgets/doctor_dashboard/view_history_dialog.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button.dart';

class DoctorDashboardNewscreen extends StatefulWidget {
  const DoctorDashboardNewscreen({super.key});

  @override
  State<DoctorDashboardNewscreen> createState() =>
      _DoctorDashboardNewscreenState();
}

class _DoctorDashboardNewscreenState extends State<DoctorDashboardNewscreen> {
  bool _showAllPriority = false;
  List<CustomCard> _buildPriorityCards() {
    return [
      CustomCard(
        type: DashboardCardType.priority,
        child: _DashboardPriorityContent(
          ticketId: 'TKT-101',
          buffaloId: 'BUF-089',
          issue: 'High Fever & Reduced Appetite',
          time: 'Today, 09:30\nAM',
          onViewHistory: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const ViewHistoryDialog(buffaloId: 'BUF-089'),
            );
          },
          onTreatPrescribe: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const TreatPrescribeDialog(buffaloId: 'BUF-089'),
            );
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
          onViewHistory: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const ViewHistoryDialog(buffaloId: 'BUF-142'),
            );
          },
          onTreatPrescribe: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const TreatPrescribeDialog(buffaloId: 'BUF-142'),
            );
          },
        ),
      ),
      CustomCard(
        type: DashboardCardType.priority,
        child: _DashboardPriorityContent(
          ticketId: 'TKT-103',
          buffaloId: 'BUF-203',
          issue: 'Not standing properly',
          time: 'Yesterday, 11:00\nAM',
          onViewHistory: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const ViewHistoryDialog(buffaloId: 'BUF-203'),
            );
          },
          onTreatPrescribe: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const TreatPrescribeDialog(buffaloId: 'BUF-203'),
            );
          },
        ),
      ),
      CustomCard(
        type: DashboardCardType.priority,
        child: _DashboardPriorityContent(
          ticketId: 'TKT-104',
          buffaloId: 'BUF-405',
          issue: 'Not standing properly',
          time: 'Yesterday, 1:00\nPM',
          onViewHistory: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const ViewHistoryDialog(buffaloId: 'BUF-405'),
            );
          },
          onTreatPrescribe: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const TreatPrescribeDialog(buffaloId: 'BUF-405'),
            );
          },
        ),
      ),
      CustomCard(
        type: DashboardCardType.priority,
        child: _DashboardPriorityContent(
          ticketId: 'TKT-105',
          buffaloId: 'BUF-206',
          issue: 'Not standing properly',
          time: 'Yesterday, 4:00\nPM',
          onViewHistory: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const ViewHistoryDialog(buffaloId: 'BUF-206'),
            );
          },
          onTreatPrescribe: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const TreatPrescribeDialog(buffaloId: 'BUF-206'),
            );
          },
        ),
      ),
      CustomCard(
        type: DashboardCardType.priority,
        child: _DashboardPriorityContent(
          ticketId: 'TKT-107',
          buffaloId: 'BUF-210',
          issue: 'Not standing properly',
          time: 'Yesterday, 7:00\nPM',
          onViewHistory: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const ViewHistoryDialog(buffaloId: 'BUF-210'),
            );
          },
          onTreatPrescribe: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const TreatPrescribeDialog(buffaloId: 'BUF-210'),
            );
          },
        ),
      ),
    ];
  }

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

  // Widget _buildPriorityAttentionSection() {
  //   final priorityCards = [
  //     CustomCard(
  //       type: DashboardCardType.priority,
  //       child: _DashboardPriorityContent(
  //         ticketId: 'TKT-101',
  //         buffaloId: 'BUF-089',
  //         issue: 'High Fever & Reduced Appetite',
  //         time: 'Today, 09:30\nAM',
  //         onViewHistory: () {},
  //         onTreatPrescribe: () {
  //           _showPrescribeMedicineDialog(context, buffaloId: 'BUF-089');
  //         },
  //       ),
  //     ),
  //     CustomCard(
  //       type: DashboardCardType.priority,
  //       child: _DashboardPriorityContent(
  //         ticketId: 'TKT-102',
  //         buffaloId: 'BUF-142',
  //         issue: 'Limping on left hind leg',
  //         time: 'Yesterday, 04:15\nPM',
  //         onViewHistory: () {},
  //         onTreatPrescribe: () {
  //           _showPrescribeMedicineDialog(context, buffaloId: 'BUF-142');
  //         },
  //       ),
  //     ),
  //   ];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [

  //           const Text(
  //             'Priority Attention Needed',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: AppTheme.dark,
  //             ),
  //           ),
  //           TextButton(onPressed: (){

  //           }, child: Text("View All"))
  //         ],
  //       ),
  //       const SizedBox(height: AppConstants.spacingM),
  //       Column(
  //         children: priorityCards
  //             .map(
  //               (card) => Padding(
  //                 padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
  //                 child: card,
  //               ),
  //             )
  //             .toList(),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildPriorityAttentionSection() {
    final allCards = _buildPriorityCards();
    final visibleCards = _showAllPriority
        ? allCards
        : allCards.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Priority Attention Needed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.dark,
              ),
            ),

            Row(
              children: [
                if (!_showAllPriority)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllPriority = true;
                      });
                    },
                    child: const Text("View All"),
                  ),

                if (_showAllPriority)
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: "Hide",
                    onPressed: () {
                      setState(() {
                        _showAllPriority = false;
                      });
                    },
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppConstants.spacingM),

        Column(
          children: visibleCards
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
              // child:
              //  GestureDetector(
              //   onTap: () {
              //     showDialog(
              //       context: context,
              //       barrierDismissible: false,
              //       builder: (context) => const LogRoutineVisitDialog(),
              //     );
              //   },
              child: CustomCard(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const LogRoutineVisitDialog(),
                  );
                },
                type: DashboardCardType.quickAction,
                child: _DashboardQuickActionContent(
                  icon: Icons.assignment,
                  label: 'Log Routine Visit',
                  color: Colors.blue,
                ),
              ),
              //),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              //   child:
              //  GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const CheckInventoryScreen(),
              //       ),
              //     );
              //   },
              child: CustomCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckInventoryScreen(),
                    ),
                  );
                },
                type: DashboardCardType.quickAction,
                child: _DashboardQuickActionContent(
                  icon: Icons.inventory_2,
                  label: 'Check Inventory',
                  color: Colors.green,
                ),
              ),
            ),
            // ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              // child: InkWell(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const SearchHistoryScreen(),
              //       ),
              //     );
              //   },
              child: CustomCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchHistoryScreen(),
                    ),
                  );
                },
                type: DashboardCardType.quickAction,
                child: _DashboardQuickActionContent(
                  icon: Icons.search,
                  label: 'Search History',
                  color: Colors.orange,
                ),
              ),
            ),
            //),
          ],
        ),
      ],
    );
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
              child: Text('View History'),
              onPressed: onViewHistory,
              color: Colors.green[800]!,
              variant: ButtonVariant.outlined,
            ),
            const SizedBox(width: 10),
            CustomActionButton(
              child: Text(
                'Treat & Prescribe',
                style: TextStyle(color: Colors.white),
              ),
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
}
