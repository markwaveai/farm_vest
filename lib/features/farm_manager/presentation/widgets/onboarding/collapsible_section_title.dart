import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CollapsibleSectionTitle extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;

  const CollapsibleSectionTitle({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
