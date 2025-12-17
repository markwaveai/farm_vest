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
    'assets/images/murrah1.jpeg'
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section with Overlay Buttons
                _buildImageSection(imageUrl, context),

                // Info Section
                _buildInfoSection(),

                // Footer with ID Badge
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(String imageUrl, BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          // Main Image
          Container(
            height: 160,
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
            height: 160,
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
          Positioned(top: 8, right: 8, child: _buildStatusChip()),

          // Bottom Left: Calves Button
          if (onCalvesTap != null)
            Positioned(bottom: 8, left: 8, child: _buildCalvesButton()),

          // Bottom Right: Live Button
          Positioned(bottom: 8, right: 8, child: _buildLiveButton(context)),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.beige.withValues(alpha: 0.3)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breed
          _buildInfoRow('Breed', breed.toUpperCase()),
          const SizedBox(height: 3),

          // Purchase Date
          _buildInfoRow('Purchase', farmName),
          const SizedBox(height: 3),

          // Location
          _buildInfoRow('Location', location.toUpperCase()),
          const SizedBox(height: 3),

          // Tree Details
          _buildInfoRow('Age', age),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.slate,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 10,
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'ID',
              style: TextStyle(
                fontSize: 9,
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // ID Value
          Expanded(
            child: Text(
              id.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
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
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Icon(Icons.copy, size: 12, color: AppTheme.white),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
          color: AppTheme.white,
          fontSize: 9,
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
          color: AppTheme.dark.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 12, color: AppTheme.white),
            SizedBox(width: 3),
            Text(
              'Calves',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 9,
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, size: 12, color: AppTheme.white),
            SizedBox(width: 2),
            Text(
              'Live',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
