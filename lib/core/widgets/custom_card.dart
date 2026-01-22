//import 'package:farm_vest/core/widgets/custom_button_action.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

enum DashboardCardType { stats, priority, quickAction }

class CustomCard extends StatelessWidget {
  final DashboardCardType type;

  final Color? color;
  final VoidCallback? onTap;
  final Widget? child;

  const CustomCard({
    super.key,
    this.type = DashboardCardType.stats,

    this.color,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (type == DashboardCardType.priority) {
      return _buildPriorityCard();
    } else if (type == DashboardCardType.quickAction) {
      return _buildQuickActionCard();
    }
    return _buildStatsCard();
  }

  Widget _buildStatsCard() {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 4,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(26),
                    bottomRight: Radius.circular(26),
                  ),
                ),
              ),
            ),
          ),

          // Main Card (pushed up like left-margin in priority card)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // child: SizedBox.expand(
            //   child: child),
child:SizedBox(
  width: double.infinity,
  height: double.infinity,
  child: child,
)
            // ??
            // Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Icon(icon, color: color, size: 28),
            //         Text(
            //           title ?? '',
            //           style: TextStyle(
            //             fontSize: 24,
            //             fontWeight: FontWeight.bold,
            //             color: color,
            //           ),
            //         ),
            //       ],
            //     ),
            //     const SizedBox(height: 12),
            //     Text(
            //       subtitle ?? '',
            //       style: const TextStyle(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w500,
            //         color: AppTheme.slate,
            //       ),
            //     ),
            //     const SizedBox(height: 12),
            //   ],
            // ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard() {
    return Stack(
      children: [
        Positioned.fill(
          left: 4,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  bottomLeft: Radius.circular(26),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          //child: child,
          child:SizedBox(
  width: double.infinity,
  height: double.infinity,
  child: child,
)

          // child: SizedBox.expand(
          //   child:
         
          // child),

          //  ??
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Row(
          //           children: [
          //             const Icon(
          //               Icons.warning_amber_rounded,
          //               color: AppTheme.errorRed,
          //               size: 20,
          //             ),
          //             const SizedBox(width: 8),
          //             Text(
          //               '${ticketId ?? ''} • ${buffaloId ?? ''}',
          //               style: const TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 14,
          //                 color: AppTheme.dark,
          //               ),
          //             ),
          //           ],
          //         ),
          //         Text(
          //           time ?? '',
          //           style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          //         ),
          //       ],
          //     ),
          //     const SizedBox(height: 8),
          //     Text(
          //       issue ?? '',
          //       style: const TextStyle(
          //         fontSize: 14,
          //         fontWeight: FontWeight.w600,
          //         color: AppTheme.dark,
          //       ),
          //     ),
          //     const SizedBox(height: 16),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         CustomActionButton(
          //           label: 'View History',
          //           onPressed: onViewHistory,
          //           color: Colors.green[800]!,
          //           variant: ButtonVariant.outlined,
          //         ),
          //         const SizedBox(width: 10),
          //         CustomActionButton(
          //           label: 'Treat & Prescribe',
          //           onPressed: onTreatPrescribe,
          //           color: Colors.green[800]!,
          //           variant: ButtonVariant.filled,
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard() {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // child: SizedBox.expand(child:
         
        //   child),
        child:SizedBox(
  width: double.infinity,
  height: double.infinity,
  child: child,
)
       // child: child,
        //??
        // Column(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Container(
        //       padding: const EdgeInsets.all(6),
        //       decoration: BoxDecoration(
        //         color: (color ?? Colors.blue).withOpacity(0.2),
        //         shape: BoxShape.circle,
        //       ),
        //       child: Icon(icon, color: color, size: 24),
        //     ),
        //     const SizedBox(height: 12),
        //     Text(
        //       subtitle ?? '', // Using subtitle for label
        //       textAlign: TextAlign.center,
        //       style: const TextStyle(
        //         fontSize: 12,
        //         fontWeight: FontWeight.w500,
        //         color: AppTheme.dark,
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
