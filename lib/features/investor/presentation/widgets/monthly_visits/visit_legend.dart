import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class VisitLegend extends StatelessWidget {
  const VisitLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            "Available",
            AppTheme.white,
            borderColor: AppTheme.successGreen.withOpacity(0.5),
          ),
          _buildLegendItem("Selected", AppTheme.successGreen),
          _buildLegendItem(
            "Expired",
            Colors.grey.shade600,
            borderColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
