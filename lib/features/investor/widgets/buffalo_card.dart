import 'dart:math';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final bool showLiveButton; // Add flag to control live button visibility
  final VoidCallback? onTap;
  final VoidCallback? onCalvesTap;
  final VoidCallback? onInvoiceTap;

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
    this.showLiveButton = true, // Default to true
    this.onTap,
    this.onCalvesTap,
    this.onInvoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use a random image for each buffalo
    final random = Random();
    final imageUrl = murrahImages[random.nextInt(murrahImages.length)];

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = AppConstants.smallPhoneHeight<600;
    final isMediumPhone = AppConstants.mediumPhoneHeight >= AppConstants.smallPhoneHeight && screenHeight < 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
isDark                ? AppTheme.darkSurface
                : AppTheme.beige.withValues(alpha: 0.3),
isDark                ? AppTheme.darkSurfaceVariant
                : AppTheme.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(
                  imageUrl,
                  context,
                  isSmallPhone: isSmallPhone,
                  isMediumPhone: isMediumPhone,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                 
                  children: [
                    Expanded(
                      child: _buildInfoSection(
                        context,
                        isSmallPhone: isSmallPhone,
                        isMediumPhone: isMediumPhone,
                      ),
                    ),
                   
                  ],
                ),
                _buildFooter(
                  context: context,
                  isSmallPhone: isSmallPhone,
                  isMediumPhone: isMediumPhone,
                ),
              ],
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
    required bool isMediumPhone,
  }) {
    final imageHeight = isSmallPhone ? 105.0 : (isMediumPhone ? 125.0 : 140.0);
    final overlayPadding = isSmallPhone ? 6.0 : 8.0;

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
                      size: 48,
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
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),

          // Top Right: Health Status Badge
          Positioned(
            top: overlayPadding,
            right: overlayPadding,
            child: _buildStatusChip(
              isSmallPhone: isSmallPhone,
              isMediumPhone: isMediumPhone,
            ),
          ),

          // Bottom Left: Calves Button
          if (onCalvesTap != null)
            Positioned(
              bottom: overlayPadding,
              left: overlayPadding,
              child: _buildCalvesButton(
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
              ),
            ),

          // Bottom Right: Live Button
          if (showLiveButton)
            Positioned(
              bottom: overlayPadding,
              right: overlayPadding,
              child: _buildLiveButton(
                context,
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required bool isSmallPhone,
    required bool isMediumPhone,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paddingH = isSmallPhone ? 8.0 : 10.0;
    final paddingV = isSmallPhone ? 6.0 : (isMediumPhone ? 7.0 : 8.0);
    final fontSize = isSmallPhone ? 10.0 : 11.0;
    final rowGap = isSmallPhone ? 3.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      color: isDark
          ? Colors.transparent
          : AppTheme.beige.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Au Id (formerly Breed)
          _buildInfoRow(
            'Au Id',
            breed.toUpperCase(),
            isDark: isDark,
            fontSize: fontSize,
          ),
          SizedBox(height: rowGap),

          // Site Name (formerly Purchase)
          _buildInfoRow(
            'Site Name',
            farmName,
            isDark: isDark,
            fontSize: fontSize,
          ),
          SizedBox(height: rowGap),

          // Location
          _buildInfoRow(
            'Location',
            location.toUpperCase(),
            isDark: isDark,
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isDark = false,
    double fontSize = 11,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: fontSize,
            color: isDark ? Colors.grey[400] : AppTheme.slate,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: isDark
                  ? const Color.fromARGB(255, 237, 230, 230)
                  : AppTheme.dark,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter({
    required BuildContext context,
    required bool isSmallPhone,
    required bool isMediumPhone,
  }) {
    final paddingH = isSmallPhone ? 8.0 : 10.0;
    final paddingV = isSmallPhone ? 6.0 : (isMediumPhone ? 7.0 : 8.0);
    final badgeFont = isSmallPhone ? 9.0 : 10.0;
    final valueFont = isSmallPhone ? 12.0 : 10.0;

    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: breed.toUpperCase()));
        Fluttertoast.showToast(
          msg: "ID Copied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black.withOpacity(0.8),
          textColor: Colors.white,
          fontSize: 14.0,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withValues(alpha: 0.85),
            ],
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
                horizontal: isSmallPhone ? 5 : 6,
                vertical: isSmallPhone ? 2 : 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ID',
                style: TextStyle(
                  fontSize: badgeFont,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: isSmallPhone ? 6 : 8),

            // ID Value
            Expanded(
              child: Text(
                breed.toUpperCase(),
                style: TextStyle(
                  fontSize: valueFont,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
             // Copy Icon
            // Container(
            //   padding: EdgeInsets.all(isSmallPhone ? 3 : 4),
            //   decoration: BoxDecoration(
            //     color: Colors.white.withValues(alpha: 0.2),
            //     borderRadius: BorderRadius.circular(5),
            //   ),
            //   child: Icon(Icons.copy, size: copyIconSize, color: Colors.white),
            // ),
            if (onInvoiceTap != null)
              _buildInvoiceButton(
                context,
                isSmallPhone: isSmallPhone,
                isMediumPhone: isMediumPhone,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required bool isSmallPhone,
    required bool isMediumPhone,
  }) {
    Color statusColor = AppTheme.successGreen;
    if (healthStatus.toLowerCase().contains('warning')) {
      statusColor = AppTheme.warningOrange;
    } else if (healthStatus.toLowerCase().contains('critical')) {
      statusColor = AppTheme.errorRed;
    }

    final fontSize = isSmallPhone ? 9.0 : 10.0;
    final paddingH = isSmallPhone ? 6.0 : 8.0;
    final paddingV = isSmallPhone ? 3.0 : (isMediumPhone ? 3.5 : 4.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
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
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCalvesButton({
    required bool isSmallPhone,
    required bool isMediumPhone,
  }) {
    final fontSize = isSmallPhone ? 9.0 : 10.0;
    final iconSize = isSmallPhone ? 11.0 : 12.0;
    final paddingH = isSmallPhone ? 6.0 : 8.0;
    final paddingV = isSmallPhone ? 4.0 : (isMediumPhone ? 4.5 : 5.0);

    return GestureDetector(
      onTap: onCalvesTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: iconSize, color: Colors.white),
            SizedBox(width: isSmallPhone ? 3 : 4),
            Text(
              'Calves',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
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
    required bool isMediumPhone,
  }) {
    final fontSize = isSmallPhone ? 9.0 : 10.0;
    final iconSize = isSmallPhone ? 11.0 : 12.0;
    final paddingH = isSmallPhone ? 6.0 : 8.0;
    final paddingV = isSmallPhone ? 4.0 : (isMediumPhone ? 4.5 : 5.0);

    return GestureDetector(
      onTap: () {
        context.go('/cctv-live', extra: {'buffaloId': id});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
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
            Icon(Icons.videocam, size: iconSize, color: Colors.white),
            SizedBox(width: isSmallPhone ? 3 : 4),
            Text(
              'Live',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceButton(
    BuildContext context, {
    required bool isSmallPhone,
    required bool isMediumPhone,
  }) {
    final fontSize = isSmallPhone ? 9.0 : 10.0;
    final iconSize = isSmallPhone ? 11.0 : 13.0;
    final paddingH = isSmallPhone ? 6.0 : 8.0;
    final paddingV = isSmallPhone ? 4.0 : (isMediumPhone ? 4.5 : 5.0);

    return GestureDetector(
      onTap: onInvoiceTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: AppTheme.primary, // Or use a distinct color like purple/indigo
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: iconSize, color: Colors.white),
            // SizedBox(width: isSmallPhone ? 3 : 4),
            // Text(
            //   'Invoice',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: fontSize,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
