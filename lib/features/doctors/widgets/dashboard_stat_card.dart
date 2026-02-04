import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/loading_dots_wave.dart';
import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget iconWidget;
  // final IconData icon;
  final Widget? topIcon;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconWidget,
    this.topIcon,
    // required this.icon,
    required this.backgroundColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            isLoading
                ? const SizedBox(
                    height: 30, // Keep height consistent
                    width: 50, // Slightly wider for the dots
                    child: Center(
                      child: LoadingDotsWave(color: Colors.white, size: 8),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 6),
            Align(alignment: Alignment.bottomRight, child: iconWidget),
          ],
        ),
      ),
    );
  }
}
