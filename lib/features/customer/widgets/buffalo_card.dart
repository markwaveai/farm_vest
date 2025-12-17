import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class BuffaloCard extends StatelessWidget {
  final String farmName;
  final String location;
  final String id;
  final String healthStatus;
  final String lastMilking;
  final String age;
  final String breed;
  final bool isGridView;
  final VoidCallback? onTap;
  final VoidCallback? onCalvesTap;

  // Sample Murrah buffalo images
  static const List<String> murrahImages = [
    'assets/images/buffalo4.jpeg',
    'assets/images/murrah1.jpeg',
    'assets/images/murrah1.jpg',
  ];

  const BuffaloCard({
    super.key,
    required this.farmName,
    required this.location,
    required this.id,
    required this.healthStatus,
    required this.lastMilking,
    required this.age,
    required this.breed,
    this.isGridView = true,
    this.onTap,
    this.onCalvesTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use a random image for each buffalo
    final random = Random();
    final imageUrl = murrahImages[random.nextInt(murrahImages.length)];

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenHeight < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.beige.withValues(alpha: 0.3), AppTheme.white],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.slate.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                onTap ??
                () => context.go('/unit-details', extra: {'buffaloId': id}),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final baseScale = isSmallPhone ? 0.86 : 1.0;

                final maxH = constraints.maxHeight;
                final hasTightHeight = maxH.isFinite && maxH > 0;

                final baseTotalHeight = 160.0 + 62.0 + 44.0;
                final heightScale =
                    hasTightHeight ? (maxH / baseTotalHeight).clamp(0.75, 1.0) : 1.0;

                final scale = baseScale < heightScale ? baseScale : heightScale;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageSection(
                      imageUrl,
                      context,
                      isSmallPhone: isSmallPhone,
                      scale: scale,
                    ),
                    _buildInfoSection(isSmallPhone: isSmallPhone, scale: scale),
                    _buildFooter(isSmallPhone: isSmallPhone, scale: scale),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    String imageUrl,
    BuildContext context, {
    required bool isSmallPhone,
    required double scale,
  }) {
    final imageHeight = 160.0 * scale;

    return SizedBox(
      height: imageHeight,
      child: Stack(
        children: [
          // Main Image
          Container(
            height: imageHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.slate.withValues(alpha: 0.1),
                  AppTheme.lightGrey,
                ],
              ),
            ),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.lightGrey,
                  child: Center(
                    child: Icon(
                      Icons.pets,
                      size: 48 * scale,
                      color: AppTheme.slate.withValues(alpha: 0.3),
                    ),
                  ),
                );
              },
            ),
          ),

          // Gradient Overlay
          Container(
            height: imageHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.dark.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),

          // Top Right: Health Status Badge
          Positioned(
            top: isSmallPhone ? 6 : 8,
            right: isSmallPhone ? 6 : 8,
            child: _buildStatusChip(isSmallPhone: isSmallPhone, scale: scale),
          ),

          // Bottom Left: Calves Button
          if (onCalvesTap != null)
            Positioned(
              bottom: isSmallPhone ? 6 : 8,
              left: isSmallPhone ? 6 : 8,
              child: _buildCalvesButton(isSmallPhone: isSmallPhone, scale: scale),
            ),

          // Bottom Right: Live Button
          Positioned(
            bottom: isSmallPhone ? 6 : 8,
            right: isSmallPhone ? 6 : 8,
            child: _buildLiveButton(
              context,
              isSmallPhone: isSmallPhone,
              scale: scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required bool isSmallPhone, required double scale}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 2 * scale,
      ),
      decoration: BoxDecoration(color: AppTheme.beige.withValues(alpha: 0.3)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breed
          _buildInfoRow(
            'Breed',
            breed.toUpperCase(),
            isSmallPhone: isSmallPhone,
            scale: scale,
          ),
          SizedBox(height: 1 * scale),

          // Purchase Date
          _buildInfoRow(
            'Purchase',
            farmName,
            isSmallPhone: isSmallPhone,
            scale: scale,
          ),
          SizedBox(height: 1 * scale),

          // Location
          _buildInfoRow(
            'Location',
            location.toUpperCase(),
            isSmallPhone: isSmallPhone,
            scale: scale,
          ),
          SizedBox(height: 1 * scale),

          // Tree Details
          _buildInfoRow('Age', age, isSmallPhone: isSmallPhone, scale: scale),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    required bool isSmallPhone,
    required double scale,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 10 * scale,
            color: AppTheme.slate,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10 * scale,
              color: AppTheme.dark,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter({required bool isSmallPhone, required double scale}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.85)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // ID Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6 * scale,
              vertical: 3 * scale,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'ID',
              style: TextStyle(
                fontSize: 9 * scale,
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 6 * scale),

          // ID Value
          Expanded(
            child: Text(
              id.toUpperCase(),
              style: TextStyle(
                fontSize: 13 * scale,
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          // Copy Icon
          Container(
            padding: EdgeInsets.all(3 * scale),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              Icons.copy,
              size: 12 * scale,
              color: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({required bool isSmallPhone, required double scale}) {
    Color statusColor = AppTheme.successGreen;
    if (healthStatus.toLowerCase().contains('warning')) {
      statusColor = AppTheme.warningOrange;
    } else if (healthStatus.toLowerCase().contains('critical')) {
      statusColor = AppTheme.errorRed;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7 * scale,
        vertical: 3 * scale,
      ),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        healthStatus,
        style: TextStyle(
          color: AppTheme.white,
          fontSize: 9 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCalvesButton({required bool isSmallPhone, required double scale}) {
    return GestureDetector(
      onTap: onCalvesTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8 * scale,
          vertical: 5 * scale,
        ),
        decoration: BoxDecoration(
          color: AppTheme.dark.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 12 * scale, color: AppTheme.white),
            SizedBox(width: 3 * scale),
            Text(
              'Calves',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 9 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveButton(
    BuildContext context, {
    required bool isSmallPhone,
    required double scale,
  }) {
    return GestureDetector(
      onTap: () {
        context.go('/cctv-live', extra: {'buffaloId': id});
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8 * scale,
          vertical: 5 * scale,
        ),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam,
              size: 12 * scale,
              color: AppTheme.white,
            ),
            SizedBox(width: 2 * scale),
            Text(
              'Live',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 9 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
