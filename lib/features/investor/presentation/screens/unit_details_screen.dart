import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';

class UnitDetailsScreen extends StatefulWidget {
  final InvestorAnimal? animal;
  const UnitDetailsScreen({super.key, this.animal});

  @override
  State<UnitDetailsScreen> createState() => _UnitDetailsScreenState();
}

class _UnitDetailsScreenState extends State<UnitDetailsScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        NavigationHelper.safePopOrNavigate(
          context,
          fallbackRoute: '/customer-dashboard',
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Unit Details'.tr),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => NavigationHelper.safePopOrNavigate(
              context,
              fallbackRoute: '/customer-dashboard',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buffalo Image Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (animal?.images.isNotEmpty == true)
                        PageView.builder(
                          itemCount: animal!.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              animal.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/buffalo4.jpeg',
                                  fit: BoxFit.cover,
                                );
                                // Container(
                                //   color: Colors.grey[200],
                                //   child: const Center(
                                //     child: Icon(
                                //       Icons.image_not_supported,
                                //       color: Colors.grey,
                                //     ),
                                //   ),
                                // );
                              },
                            );
                          },
                        )
                      else
                        Image.asset(
                          'assets/images/buffalo4.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/buffalo4.jpeg',
                              fit: BoxFit.cover,
                            );
                            // Container(
                            //   color: Colors.grey[200],
                            //   child: const Center(
                            //     child: Icon(
                            //       Icons.image_not_supported,
                            //       color: Colors.grey,
                            //),
                            //),
                            //);
                          },
                        ),

                      // Gradient Overlay for text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),

                      // Slider Indicators (Dots)
                      if (animal?.images.isNotEmpty == true &&
                          animal!.images.length > 1)
                        Positioned(
                          bottom: AppConstants.spacingM,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              animal.images.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentImageIndex == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == index
                                      ? AppTheme.primary
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Health Badge
                      Positioned(
                        top: AppConstants.spacingM,
                        right: AppConstants.spacingM,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingS,
                            vertical: AppConstants.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (animal?.healthStatus.toLowerCase() ==
                                    'healthy')
                                ? AppTheme.successGreen
                                : AppTheme.warningOrange,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusS,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            animal?.healthStatus.toUpperCase() ?? 'UNKNOWN'.tr,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Unit Information
              Text(
                'Unit Information'.tr,
                style: AppTheme.headingMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              //const Text('Unit Information', style: AppTheme.headingMedium),
              const SizedBox(height: AppConstants.spacingM),

              _buildInfoCard(context, [
                _buildInfoRow(context, 'RFID:'.tr, animal?.rfid ?? kHyphen),
                _buildInfoRow(
                  context,
                  ('Neck Band ID:'.tr),
                  animal?.neckBandId?.isEmpty == true
                      ? kHyphen
                      : animal?.neckBandId ?? kHyphen,
                ),
                _buildInfoRow(
                  context,
                  ('Ear Tag ID:'.tr),
                  animal?.earTagId?.isEmpty == true
                      ? kHyphen
                      : animal?.earTagId ?? kHyphen,
                ),
                _buildInfoRow(
                  context,
                  ('Age:'.tr),
                  animal?.age != null
                      ? '${animal!.age} ${"Months".tr}'
                      : kHyphen,
                ),

                _buildInfoRow(
                  context,
                  ('Breed Type:'.tr),
                  animal?.breed?.isEmpty == true
                      ? kHyphen
                      : animal?.breed ?? kHyphen,
                ),
                _buildInfoRow(
                  context,
                  ('Farm Name:'.tr),
                  animal?.farmName?.isEmpty == true
                      ? kHyphen
                      : animal?.farmName ?? kHyphen,
                ),
                _buildInfoRow(
                  context,
                  ('Shed Name:'.tr),
                  animal?.shedName?.toString() == null
                      ? kHyphen
                      : animal?.shedName.toString() ?? kHyphen,
                ),
                _buildInfoRow(
                  context,
                  ('Parking ID:'.tr),
                  animal?.parkingId?.isEmpty == true
                      ? kHyphen
                      : animal?.parkingId ?? kHyphen,
                ),
                _buildInfoRow(
                  context,
                  ('Location:'.tr),
                  animal?.farmLocation?.isEmpty == true
                      ? kHyphen
                      : animal?.farmLocation ?? kHyphen,
                ),
                if (animal?.onboardedAt != null)
                  _buildInfoRow(
                    context,
                    ('Onboarded At:'.tr),
                    animal?.onboardedAt != null
                        ? DateFormat('dd MMM yyyy').format(animal!.onboardedAt!)
                        : kHyphen,
                  ),
              ]),
              const SizedBox(height: AppConstants.spacingL),

              // Health Summary
              Text(
                ('Health Summary'.tr),
                style: AppTheme.headingMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              // const Text('Health Summary', style: AppTheme.headingMedium),
              const SizedBox(height: AppConstants.spacingM),

              _buildAlertsGrid(context),
              const SizedBox(height: AppConstants.spacingL),

              // Action Buttons
              // const Text('Quick Actions', style: AppTheme.headingMedium),
              // const SizedBox(height: AppConstants.spacingM),

              // Row(
              //   children: [
              //     Expanded(
              //       child: ElevatedButton.icon(
              //         onPressed: () => context.go('/health-records'),
              //         icon: const Icon(Icons.medical_services),
              //         label: const Text('Health Record'),
              //         style: ElevatedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(
              //             vertical: AppConstants.spacingM,
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: AppConstants.spacingM),
              //     Expanded(
              //       child: OutlinedButton.icon(
              //         onPressed: () => context.go('/cctv-live'),
              //         icon: const Icon(Icons.videocam),
              //         label: const Text('View CCTV'),
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(
              //             vertical: AppConstants.spacingM,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: AppConstants.spacingL),

              // // Last Updated
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(AppConstants.spacingM),
              //   decoration: BoxDecoration(
              //     color: AppTheme.lightGrey,
              //     borderRadius: BorderRadius.circular(AppConstants.radiusM),
              //   ),
              //   child: Row(
              //     children: [
              //       const Icon(
              //         Icons.update,
              //         color: AppTheme.mediumGrey,
              //         size: AppConstants.iconS,
              //       ),
              //       const SizedBox(width: AppConstants.spacingS),
              //       const Text('Last updated: ', style: AppTheme.bodySmall),
              //       Text(
              //         'Today at 10:30 AM',
              //         style: AppTheme.bodySmall.copyWith(
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: AppConstants.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: isDark ? Colors.grey[400] : AppTheme.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.dark,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsGrid(BuildContext context) {
    final alerts = [
      {'label': 'Heat Detection'.tr, 'icon': Icons.whatshot, 'isOrange': true},
      {
        'label': 'Posture Alerts'.tr,
        'icon': Icons.accessibility_new,
        'isOrange': false,
      },
      {
        'label': 'Activity Alerts'.tr,
        'icon': Icons.directions_run,
        'isOrange': false,
      },
      {
        'label': 'Rumination Alerts'.tr,
        'icon': Icons.restaurant,
        'isOrange': false,
      },
      {
        'label': 'Health Alerts'.tr,
        'icon': Icons.monitor_heart,
        'isOrange': true,
      },
      {
        'label': 'Temperature Alerts'.tr,
        'icon': Icons.thermostat,
        'isOrange': true,
      },
      {
        'label': 'Vaccination Alerts'.tr,
        'icon': Icons.medical_services,
        'isOrange': false,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacingM,
        mainAxisSpacing: AppConstants.spacingM,
        childAspectRatio: 1.5,
      ),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final item = alerts[index];
        return _buildCategoryCard(
          context,
          item['label'] as String,
          item['icon'] as IconData,
          isOrange: item['isOrange'] as bool,
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String label,
    IconData icon, {
    required bool isOrange,
  }) {
    final baseColor = isOrange ? AppTheme.secondary : AppTheme.primary;
    final gradientColors = isOrange
        ? [AppTheme.secondary, AppTheme.lightSecondary]
        : [AppTheme.primary, AppTheme.lightGreen];

    return Opacity(
      opacity: 0.8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}




///// TODO: After implementing Health Summary features, enable this code for interaction.


//   Widget _buildCategoryCard(
//     BuildContext context,
//     String label,
//     IconData icon, {
//     required bool isOrange,
//   }) {
//     final baseColor = isOrange ? AppTheme.secondary : AppTheme.primary;
//     final gradientColors = isOrange
//         ? [AppTheme.secondary, AppTheme.lightSecondary]
//         : [AppTheme.primary, AppTheme.lightGreen];

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(AppConstants.radiusL),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: gradientColors,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: baseColor.withValues(alpha: 0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(AppConstants.radiusL),
//           onTap: () {},
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.white, size: 32),
//               const SizedBox(height: 8),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
