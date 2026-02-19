import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/core/utils/svg_utils.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardStatsCard extends ConsumerWidget {
  const DashboardStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenHeight < AppConstants.smallphoneheight;
    final isMediumPhone =
        screenHeight >= AppConstants.smallphoneheight &&
        screenHeight < AppConstants.mediumphoneheight;
    final stats = ref.watch(buffaloStatsProvider);

    return stats.when(
      data: (data) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallPhone ? 0 : (isMediumPhone ? 2 : 12),
          vertical: isSmallPhone ? 12 : (isMediumPhone ? 14 : 16),
        ),
        margin: EdgeInsets.fromLTRB(
          isSmallPhone ? 10 : 16,
          8,
          isSmallPhone ? 10 : 16,
          8,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                value: data['count'] ?? '0',
                label: ('Buffaloes'.tr),
                icon: Icons.pets,
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isCompact: true,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                value: data['calves'] ?? '0',
                label: ('Calves'.tr),
                icon: SvgPicture.string(
                  SvgUtils.calvesSvg,
                  height: 26,
                  width: 26,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isCompact: true,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                value: data['assetValue'] ?? '0',
                label: ('Asset Value'.tr),
                subLabel: ('(till date)'.tr),
                icon: Icons.account_balance,
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isCompact: true,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                value: data['revenue']?.toString() ?? '₹0',
                label: ('Revenue'.tr),
                subLabel: ('(till date)'.tr),
                icon: Icons.trending_up,
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
                isCompact: true,
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            ('Error: @message'.trParams({'message': err.toString()})),
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    String? subLabel,
    required Object icon,
    required bool isSmallPhone,
    required bool isMediumPhone,
    bool isCompact = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double iconSize = isCompact
        ? (isSmallPhone ? 18.0 : (isMediumPhone ? 19.0 : 20.0))
        : 20.0;
    final double padding = isCompact
        ? (isSmallPhone ? 4.0 : (isMediumPhone ? 5.0 : 6.0))
        : 8.0;
    final double gap = isCompact
        ? (isSmallPhone ? 2.0 : (isMediumPhone ? 3.0 : 4.0))
        : 8.0;
    final double valueFontSize = isCompact
        ? (isSmallPhone ? 11.0 : (isMediumPhone ? 12.0 : 13.0))
        : 14.0;
    final double labelFontSize = isCompact
        ? (isSmallPhone ? 9.0 : (isMediumPhone ? 9.5 : 10.0))
        : 12.0;

    final valueStyle =
        (isCompact ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)
            ?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.white : AppTheme.secondary,
              fontSize: isCompact ? valueFontSize : null,
            );

    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: isCompact ? labelFontSize : null,
      color: isDark ? Colors.grey[400] : Colors.grey[600],
    );

    final Widget iconWidget = icon is IconData
        ? Icon(icon, color: AppTheme.secondary, size: iconSize)
        : FittedBox(fit: BoxFit.contain, child: icon as Widget);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.white
                : AppTheme.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: iconWidget,
        ),
        SizedBox(height: gap),
        Text(value, style: valueStyle),
        Text(label, style: labelStyle),
        if (subLabel != null)
          Text(
            subLabel,
            style: labelStyle?.copyWith(
              fontSize: labelFontSize * 0.8,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
      ],
    );
  }
}
