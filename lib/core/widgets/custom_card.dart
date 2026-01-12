import 'package:flutter/material.dart';

enum DashboardCardType { stats, priority, quickAction }

class CustomCard extends StatelessWidget {
  final DashboardCardType type;

  final Color? color;
  final VoidCallback? onTap;
  final Widget? child;

  // Priority specific

  const CustomCard({
    super.key,
    this.type = DashboardCardType.stats,

    this.color,
    this.onTap,

    required this.child,
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
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Bottom ribbon (same pattern as left ribbon)
          Positioned.fill(
            bottom: 2,
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
            // height: null,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),

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
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard() {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 144, 21, 21)),
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
      child: child,
    );
  }
  // Widget _buildPriorityCard() {
  //   return Stack(
  //     children: [
  //       Positioned.fill(
  //         left: 4,
  //         child: Align(
  //           alignment: Alignment.centerLeft,
  //           child: Container(
  //             width: 50,
  //             decoration: const BoxDecoration(
  //               color: AppTheme.errorRed,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(26),
  //                 bottomLeft: Radius.circular(26),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         height: isTablet ? 1000 : null,
  //         margin: const EdgeInsets.only(left: 10),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: const Color.fromARGB(255, 144, 21, 21)),
  //           color: Colors.white,
  //           borderRadius: const BorderRadius.all(Radius.circular(26)),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.1),
  //               blurRadius: 10,
  //               offset: const Offset(0, 4),
  //             ),
  //           ],
  //         ),
  //         padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
  //         child: child,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildQuickActionCard() {
    return GestureDetector(
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
        child: child,
      ),
    );
  }
}
