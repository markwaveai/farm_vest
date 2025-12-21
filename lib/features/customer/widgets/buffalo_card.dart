import 'dart:math';

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
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkSurface
                : AppTheme.beige.withValues(alpha: 0.3),
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkSurfaceVariant
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
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageSection(
                  imageUrl,
                  context,
                  isSmallPhone: isSmallPhone,
                ),
                _buildInfoSection(context, isSmallPhone: isSmallPhone),
                const Spacer(),
                _buildFooter(isSmallPhone: isSmallPhone),
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
  }) {
    final imageHeight = 140.0;

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
          Positioned(top: 8, right: 8, child: _buildStatusChip()),

          // Bottom Left: Calves Button
          if (onCalvesTap != null)
            Positioned(bottom: 8, left: 8, child: _buildCalvesButton()),

          // Bottom Right: Live Button
          if (showLiveButton)
            Positioned(bottom: 8, right: 8, child: _buildLiveButton(context)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {required bool isSmallPhone}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: isDark
          ? Colors.transparent
          : AppTheme.beige.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Au Id (formerly Breed)
          _buildInfoRow('Au Id', breed.toUpperCase(), isDark: isDark),
          const SizedBox(height: 4),

          // Site Name (formerly Purchase)
          _buildInfoRow('Site Name', farmName, isDark: isDark),
          const SizedBox(height: 4),

          // Location
          _buildInfoRow('Location', location.toUpperCase(), isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isDark = false}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : AppTheme.slate,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
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

  Widget _buildFooter({required bool isSmallPhone}) {
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'ID',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ID Value
            Expanded(
              child: Text(
                breed.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            // Copy Icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.copy, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor = AppTheme.successGreen;
    if (healthStatus.toLowerCase().contains('warning')) {
      statusColor = AppTheme.warningOrange;
    } else if (healthStatus.toLowerCase().contains('critical')) {
      statusColor = AppTheme.errorRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCalvesButton() {
    return GestureDetector(
      onTap: onCalvesTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
            const Icon(Icons.pets, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            const Text(
              'Calves',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/cctv-live', extra: {'buffaloId': id});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
            const Icon(Icons.videocam, size: 12, color: Colors.white),
            const SizedBox(width: 4),
            const Text(
              'Live',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
