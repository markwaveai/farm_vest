import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';

class BuffaloCard extends StatelessWidget {
  final InvestorAnimal animal;
  final bool isGridView;
  final bool showLiveButton;
  final VoidCallback? onTap;
  final VoidCallback? onCalvesTap;
  final VoidCallback? onInvoiceTap;

  // Sample Murrah buffalo images
  // static const List<String> murrahImages = [
  //   'assets/images/buffalo4.jpeg',
  //   'assets/images/murrah1.jpg',
  //   'assets/images/murrah1.jpg',
  //];

  const BuffaloCard({
    super.key,
    required this.animal,
    this.isGridView = true,
    this.showLiveButton = true,
    this.onTap,
    this.onCalvesTap,
    this.onInvoiceTap,
  });

  // static String getStableImage(String id) {
  //   final index = id.hashCode.abs() % murrahImages.length;
  //   return murrahImages[index];
  // }

  bool get isCalf => animal.animalType?.toLowerCase().contains('calf') ?? false;

  @override
  Widget build(BuildContext context) {
    // Prioritize passed imageUrl, then fallback to stable asset image
    final displayImageUrl = (animal.images.isNotEmpty)
        ? animal.images.first
        : 'assets/images/buffalo4.jpeg';

    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = AppConstants.smallphoneheight < 600;
    final isMediumPhone =
        AppConstants.mediumphoneheight >= AppConstants.smallphoneheight &&
        screenHeight < 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
            isDark
                ? theme.colorScheme.surface.withValues(alpha: 0.8)
                : theme.colorScheme.surface,
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
          color: AppTheme.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildImageSection(
                    displayImageUrl,
                    context,
                    isSmallPhone: isSmallPhone,
                    isMediumPhone: isMediumPhone,
                  ),
                ),

                if (isGridView)
                  Expanded(
                    child: Container(
                      color: isDark
                          ? theme.colorScheme.surfaceVariant
                          : Colors.grey[100],
                      child: _buildInfoSection(
                        context,
                        isSmallPhone: isSmallPhone,
                        isMediumPhone: isMediumPhone,
                        applyColor:
                            false, // Pass flag to not apply color inside
                      ),
                    ),
                  )
                else
                  _buildInfoSection(
                    context,
                    isSmallPhone: isSmallPhone,
                    isMediumPhone: isMediumPhone,
                    applyColor: true,
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
    final overlayPadding = isSmallPhone ? 6.0 : 8.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Main Image
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.onSurface.withValues(alpha: 0.05),
                theme.colorScheme.surfaceVariant,
              ],
            ),
          ),
          child: imageUrl.contains('http')
              ? Image.network(
                  imageUrl,

                  key: ValueKey(imageUrl),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppTheme.primary.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/buffalo4.jpeg',
                      fit: BoxFit.contain,
                    );
                    // Container(
                    //   color: AppTheme.lightGrey,
                    //   child: Center(
                    //     child: Icon(
                    //       Icons.pets,
                    //       size: 48,
                    //       color: AppTheme.slate.withOpacity(0.3),
                    //     ),
                    //   ),
                    // );
                  },
                )
              : Image.asset(
                  imageUrl,
                  key: ValueKey(imageUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark
                          ? theme.colorScheme.surfaceVariant
                          : AppTheme.lightGrey,
                      child: Center(
                        child: Icon(
                          Icons.pets,
                          size: 48,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1)],
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

        // Bottom Left: Calves Button (Hide for calves)
        if (onCalvesTap != null && !isCalf)
          Positioned(
            bottom: overlayPadding,
            left: overlayPadding,
            child: _buildCalvesButton(
              isSmallPhone: isSmallPhone,
              isMediumPhone: isMediumPhone,
            ),
          ),

        // Bottom Right: Live Button (Hide for calves)
        if (showLiveButton && !isCalf)
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
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required bool isSmallPhone,
    required bool isMediumPhone,
    bool applyColor = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final paddingH = isSmallPhone ? 8.0 : 10.0;
    final paddingV = isSmallPhone ? 4.0 : (isMediumPhone ? 5.0 : 6.0);
    final fontSize = isSmallPhone ? 9.0 : 10.0;
    //final fontSize = isSmallPhone ? 14.0 : 16.0;
    //final fontSize = isSmallPhone ? 12.0 : 14.0;

    final rowGap = isSmallPhone ? 2.0 : 3.0;
    //final rowGap = isSmallPhone ? 4.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      color: applyColor
          ? (isDark
                ? Colors.transparent
                : theme.colorScheme.surfaceVariant.withValues(alpha: 0.3))
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RFID
          // if (rfid.isNotEmpty) ...[
          _buildInfoRow(
            'RFID',
            (animal.rfid?.isNotEmpty ?? false)
                ? animal.rfid!.toUpperCase()
                : kHyphen,
            isDark: isDark,
            fontSize: fontSize,
          ),
          SizedBox(height: rowGap),
          // ],

          // Neck Band ID
          // if (neckBandId.isNotEmpty) ...[
          _buildInfoRow(
            'Neck Band ID',
            (animal.neckBandId?.isNotEmpty ?? false)
                ? animal.neckBandId!.toUpperCase()
                : kHyphen,
            isDark: isDark,
            fontSize: fontSize,
          ),
          SizedBox(height: rowGap),
          // ],
          _buildInfoRow(
            'Ear Tag',
            (animal.earTagId?.isNotEmpty ?? false)
                ? animal.earTagId!.toUpperCase()
                : kHyphen,
            isDark: isDark,
            fontSize: fontSize,
          ),
          // SizedBox(height: rowGap),
          //  Age nonths)
          // _buildInfoRow(
          //   'Age (Months)',
          //   (animal.age != null) ? animal.age.toString() : kHyphen,
          //   isDark: isDark,
          //   fontSize: fontSize,
          // ),
          SizedBox(height: rowGap),

          // _buildInfoRow(
          //   'Breed',
          //   (breed.isNotEmpty && breed.toLowerCase() != 'null') ? breed : '-',
          //   isDark: isDark,
          //   fontSize: fontSize,
          // ),
          // SizedBox(height: rowGap),

          // Farm
          _buildInfoRow(
            'Farm',
            (animal.farmName?.isNotEmpty ?? false) ? animal.farmName! : kHyphen,
            isDark: isDark,
            fontSize: fontSize,
          ),
          SizedBox(height: rowGap),

          // Shed
          _buildInfoRow(
            'Shed',
            (animal.shedName?.isNotEmpty ?? false) ? animal.shedName! : kHyphen,
            isDark: isDark,
            fontSize: fontSize,
          ),
          SizedBox(height: rowGap),
          //PARKING SLOT
          _buildInfoRow(
            'Parking Slot',
            (animal.parkingId?.isNotEmpty ?? false)
                ? animal.parkingId!.toUpperCase()
                : kHyphen,
            isDark: isDark,
            fontSize: fontSize,
          ),
          SizedBox(height: rowGap),
          // Location
          _buildInfoRow(
            'Location',
            (animal.farmLocation?.isNotEmpty ?? false)
                ? animal.farmLocation!.toUpperCase()
                : kHyphen,
            isDark: isDark,
            fontSize: fontSize,
          ),

          // Onboarded At
          // if (onboardedAt != null) ...[
          //   SizedBox(height: rowGap),
          //   _buildInfoRow(
          //     'Onboarded',
          //     DateFormat('dd MMM yyyy').format(onboardedAt!),
          //     isDark: isDark,
          //     fontSize: fontSize,
          //   ),
          //],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isDark = false,
    double fontSize = 3,
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
        //Flexible(
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: isDark
                  ? const Color.fromARGB(255, 237, 230, 230)
                  : AppTheme.dark,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
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
    final rfid = animal.rfid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: rfid.toUpperCase()));
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
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.85),
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
                'RFID',
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
                rfid.toUpperCase(),
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
    final status = animal.healthStatus;
    if (status.toLowerCase().contains('warning')) {
      statusColor = AppTheme.warningOrange;
    } else if (status.toLowerCase().contains('critical')) {
      statusColor = AppTheme.errorRed;
    }

    final fontSize = isSmallPhone ? 9.0 : 10.0;
    //final fontSize = isSmallPhone ? 14.0 : 16.0;

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
        status,
        style: TextStyle(
          color: AppTheme.white,
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
          color: AppTheme.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: iconSize, color: AppTheme.white),
            SizedBox(width: isSmallPhone ? 3 : 4),
            Text(
              'Calves',
              style: TextStyle(
                color: AppTheme.white,
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
        context.push('/cctv-live', extra: {'buffaloId': animal.animalId});
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
            Icon(Icons.videocam, size: iconSize, color: AppTheme.white),
            SizedBox(width: isSmallPhone ? 3 : 4),
            Text(
              'Live',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
