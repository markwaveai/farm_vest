import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/data/models/buffalo_telemetry_model.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/buffalo_telemetry_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

class BuffaloDeviceDetailsScreen extends ConsumerWidget {
  final String animalId;
  final String? rfid;
  final String? tagNumber;
  final String beltId;

  const BuffaloDeviceDetailsScreen({
    super.key,
    required this.animalId,
    required this.beltId,
    this.rfid,
    this.tagNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryAsync = ref.watch(buffaloTelemetryProvider(beltId));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: Stack(
        children: [
          // Dynamic Background Elements
          _buildBackgroundDecorations(),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: telemetryAsync.when(
                  data: (data) => _buildBody(context, ref, data),
                  loading: () => const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),
                  error: (err, stack) => _buildErrorState(err),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Opacity(
            opacity: 0.03,
            child: Image.asset('assets/icons/sitting.png', width: 400),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primary,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Buffalo Fit Insight',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1,
        ),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    BuffaloTelemetry data,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 25),
          _buildProfileHero(data),
          const SizedBox(height: 25),
          _buildAlertSection(data),
          const SizedBox(height: 30),
          _buildSectionHeader(context, ref, 'Live Behavioral Data'),
          const SizedBox(height: 16),
          _buildMetricsGrid(data),
          const SizedBox(height: 30),
          _buildActivitySummaryCard(data),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHero(BuffaloTelemetry data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/icons/buffalo_head.png',
                    fit: BoxFit.contain,
                    color: AppTheme.primary.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagNumber ?? 'Buffalo Unit',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B301B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BELT ID: $beltId',
                      style: TextStyle(
                        color: AppTheme.primary.withOpacity(0.6),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.battery_5_bar, color: Colors.green, size: 24),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernStat('WEIGHT', '540', 'kg'),
              Container(width: 1, height: 30, color: Colors.black12),
              _buildModernStat('AGE', '4.2', 'Yrs'),
              Container(width: 1, height: 30, color: Colors.black12),
              _buildModernStat('BREED', 'Murrah', ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: Color(0xFF1B301B),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSection(BuffaloTelemetry data) {
    final bool isHeat = data.heatAlert.toLowerCase() == 'yes';
    final bool isHealth = data.healthAlert.toLowerCase() == 'yes';

    return Row(
      children: [
        Expanded(
          child: _buildGlassAlert(
            'HEAT',
            data.heatAlert,
            isHeat,
            'assets/buffalofit_icons/heat.png',
            Colors.orange,
            isSvg: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassAlert(
            'HEALTH',
            data.healthAlert,
            isHealth,
            'assets/buffalofit_icons/Hert_alert.svg',
            Colors.red,
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
    Color color, {
    bool isSvg = false,
  }) {
    final Color displayColor = active ? color : AppTheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: active ? displayColor.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: active
              ? displayColor.withOpacity(0.3)
              : Colors.black.withOpacity(0.04),
          width: 1.5,
        ),
        boxShadow: [
          if (!active)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
          const SizedBox(width: 12),
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
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B301B),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 22),
          onPressed: () {
            // Trigger haptic feedback if available (optional but good for modern feel)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Refreshing telemetry data...'),
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

  Widget _buildMetricsGrid(BuffaloTelemetry data) {
    final metrics = [
      {
        'label': 'Chewing',
        'value': '${data.chewing}h',
        'asset': 'assets/buffalofit_icons/chewing.png',
        'color': const Color(0xFFFF9800),
        'bg': const Color(0xFFFFF3E0),
      },
      {
        'label': 'Rumination',
        'value': '${data.rumination}h',
        'asset': 'assets/buffalofit_icons/rumination.png',
        'color': const Color(0xFF4CAF50),
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'label': 'Sitting',
        'value': '${data.sitting}h',
        'asset': 'assets/buffalofit_icons/sitting.png',
        'color': const Color(0xFF2196F3),
        'bg': const Color(0xFFE3F2FD),
      },
      {
        'label': 'Standing',
        'value': '${data.standing}h',
        'asset': 'assets/buffalofit_icons/chewing.png',
        'color': const Color(0xFF009688),
        'bg': const Color(0xFFE0F2F1),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: mColor.withOpacity(0.08), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: mColor.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
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
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
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
                          const SizedBox(height: 2),
                          Text(
                            m['value'] as String,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B301B),
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

  Widget _buildActivitySummaryCard(BuffaloTelemetry data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1B301B),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B301B).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Analysis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Optimized Movement Tracking',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${data.activity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDarkPoint(
                'IDLE TIME',
                '${data.idle}h',
                Icons.query_builder,
              ),
              _buildDarkPoint('REST SCORE', '96%', Icons.auto_awesome),
              _buildDarkPoint('METABOLIC', 'Active', Icons.bolt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkPoint(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object err) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Sync Interrupted',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            err.toString(),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
