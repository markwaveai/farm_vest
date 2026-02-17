import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/data/models/buffalo_telemetry_model.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/buffalo_telemetry_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class BuffaloDeviceDetailsScreen extends ConsumerWidget {
  final String animalId;
  final String? rfid;
  final String? tagNumber;
  final String beltId;

  final String? age;
  final String? breed;
  final String? weight;
  final String? status;
  final InvestorAnimal? animal;

  BuffaloDeviceDetailsScreen({
    super.key,
    required this.animalId,
    required this.beltId,
    this.rfid,
    this.tagNumber,
    this.age,
    this.breed,
    this.weight,
    this.animal,
    this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryAsync = ref.watch(buffaloTelemetryProvider(beltId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Color(0xFFF0F4F0),
      body: Stack(
        children: [
          // Dynamic Background Elements
          _buildBackgroundDecorations(theme, isDark),

          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, theme, isDark),
              SliverToBoxAdapter(
                child: telemetryAsync.when(
                  data: (data) =>
                      _buildBody(context, ref, data, theme, isDark, animal),
                  loading: () => SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  error: (err, stack) => _buildErrorState(err, theme),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(ThemeData theme, bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(
                isDark ? 0.03 : 0.05,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Positioned(
        //   bottom: 100,
        //   left: -50,
        //   child: Opacity(
        //     opacity: isDark ? 0.01 : 0.03,
        //     child: Image.asset('assets/icons/sitting.png', width: 400),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.colorScheme.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Buffalo Fit Insight'.tr(ref),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1,
        ),
      ),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    BuffaloTelemetry data,
    ThemeData theme,
    bool isDark,
    InvestorAnimal? animal,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 25),
          _buildProfileHero(data, theme, isDark, animal),
          const SizedBox(height: 25),
          _buildAlertSection(data, theme, isDark),
          SizedBox(height: 30),
          _buildSectionHeader(context, ref, 'Live Behavioral Data', theme),
          SizedBox(height: 16),
          _buildMetricsGrid(data, theme, isDark),
          SizedBox(height: 30),
          _buildActivitySummaryCard(data, theme, isDark),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHero(
    BuffaloTelemetry data,
    ThemeData theme,
    bool isDark,
    InvestorAnimal? animal, // Optional in case it's not passed
  ) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(isDark ? 0.05 : 0.06),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/icons/Murrah_buffalo icon.png',
                    fit: BoxFit.contain,
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tag Number: ',
                                style: TextStyle(
                                  fontSize: 12, // smaller size
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              TextSpan(
                                text: tagNumber ?? 'Buffalo Unit',
                                style: TextStyle(
                                  fontSize: 20, // Reduced from 22
                                  fontWeight:
                                      FontWeight.w700, // Reduced from w900
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'BELT ID: $beltId',
                      style: TextStyle(
                        color: theme.colorScheme.primary.withOpacity(0.6),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.battery_5_bar, color: Colors.green, size: 24),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernStat(
                'STATUS',
                status ?? animal?.status ?? 'N/A',
                '',
                theme,
              ),
              Container(
                width: 1,
                height: 30,
                color: theme.dividerColor.withOpacity(0.2),
              ),
              _buildModernStat(
                'AGE',
                animal?.age?.toString() ?? age ?? 'N/A',
                'M',
                theme,
              ),
              Container(
                width: 1,
                height: 30,
                color: theme.dividerColor.withOpacity(0.2),
              ),
              _buildModernStat(
                'BREED',
                animal?.breed ?? breed ?? 'N/A',
                '',
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStat(
    String label,
    String value,
    String unit,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.normal, // Reduced from bold
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSection(
    BuffaloTelemetry data,
    ThemeData theme,
    bool isDark,
  ) {
    final bool isHeat = data.heatAlert.toLowerCase() == 'yes';
    final bool isHealth = data.healthAlert.toLowerCase() == 'yes';

    return Row(
      children: [
        Expanded(
          child: _buildGlassAlert(
            'HEAT',
            data.heatAlert,
            isHeat,
            'assets/buffalofit_icons/heatt.png',
            Colors.orange,
            theme,
            isDark,
            isSvg: false,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildGlassAlert(
            'HEALTH',
            data.healthAlert,
            isHealth,
            'assets/buffalofit_icons/Hert_alert.svg',
            Colors.red,
            theme,
            isDark,
            isSvg: true,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassAlert(
    String label,
    String value,
    bool active,
    String asset,
    Color color,
    ThemeData theme,
    bool isDark, {
    bool isSvg = false,
  }) {
    final Color displayColor = active ? color : theme.colorScheme.primary;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: active
            ? displayColor.withOpacity(0.12)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: active
              ? displayColor.withOpacity(0.3)
              : theme.colorScheme.onSurface.withOpacity(0.04),
          width: 1.5,
        ),
        boxShadow: [
          if (!active)
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: isSvg
                ? SvgPicture.asset(
                    asset,
                    colorFilter: ColorFilter.mode(
                      displayColor,
                      BlendMode.srcIn,
                    ),
                  )
                : Image.asset(asset, color: displayColor),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: displayColor.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: displayColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    WidgetRef ref,
    String title,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: Colors.grey, size: 22),
          onPressed: () {
            // Trigger haptic feedback if available (optional but good for modern feel)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Refreshing telemetry data...'.tr(ref)),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
            ref.invalidate(buffaloTelemetryProvider(beltId));
          },
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(
    BuffaloTelemetry data,
    ThemeData theme,
    bool isDark,
  ) {
    final metrics = [
      {
        'label': 'Chewing',
        'value': '${data.chewing}h',
        'asset': 'assets/buffalofit_icons/chewing.png',
        'color': Color(0xFFFF9800),
        'bg': Color(0xFFFFF3E0),
      },
      {
        'label': 'Rumination',
        'value': '${data.rumination}h',
        'asset': 'assets/buffalofit_icons/rumination.png',
        'color': Color(0xFF4CAF50),
        'bg': Color(0xFFE8F5E9),
      },
      {
        'label': 'Sitting',
        'value': '${data.sitting}h',
        'asset': 'assets/buffalofit_icons/sitting.png',
        'color': Color(0xFF2196F3),
        'bg': Color(0xFFE3F2FD),
      },
      {
        'label': 'Standing',
        'value': '${data.standing}h',
        'asset': 'assets/buffalofit_icons/chewing.png',
        'color': Color(0xFF009688),
        'bg': Color(0xFFE0F2F1),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 1.05,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final m = metrics[index];
        final Color mColor = m['color'] as Color;
        final Color mBg = m['bg'] as Color;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: mColor.withOpacity(0.08), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: mColor.withOpacity(isDark ? 0.08 : 0.04),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Mirror Ghost Icon in background
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Opacity(
                    opacity: 0.05,
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: (m['isSvg'] == true)
                          ? SvgPicture.asset(
                              m['asset'] as String,
                              colorFilter: ColorFilter.mode(
                                mColor,
                                BlendMode.srcIn,
                              ),
                            )
                          : Image.asset(m['asset'] as String, color: mColor),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: (m['isSvg'] == true)
                              ? SvgPicture.asset(
                                  m['asset'] as String,
                                  colorFilter: ColorFilter.mode(
                                    mColor,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : Image.asset(
                                  m['asset'] as String,
                                  color: mColor,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['label'] as String,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            m['value'] as String,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitySummaryCard(
    BuffaloTelemetry data,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Color(0xFF1B301B),
        borderRadius: BorderRadius.circular(40),
        border: isDark
            ? Border.all(color: theme.colorScheme.primary.withOpacity(0.2))
            : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? theme.colorScheme.primary : Color(0xFF1B301B))
                .withOpacity(0.3),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Analysis'.tr(ref),
                      style: TextStyle(
                        color: isDark
                            ? theme.colorScheme.onSurface
                            : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Optimized Movement Tracking'.tr(ref),
                      style: TextStyle(
                        color: isDark
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${data.activity}',
                  style: TextStyle(
                    color: isDark ? theme.colorScheme.primary : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDarkPoint(
                'IDLE TIME',
                '${data.idle}h',
                Icons.query_builder,
                theme,
                isDark,
              ),
              _buildDarkPoint(
                'REST SCORE',
                '96%',
                Icons.auto_awesome,
                theme,
                isDark,
              ),
              _buildDarkPoint('METABOLIC', 'Active', Icons.bolt, theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkPoint(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? theme.colorScheme.onSurface.withOpacity(0.4)
                : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? theme.colorScheme.onSurface : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object err, ThemeData theme) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.red, size: 60),
          SizedBox(height: 16),
          Text(
            'Sync Interrupted'.tr(ref),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            err.toString(),
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
