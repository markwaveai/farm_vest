import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';

class UnitDetailsScreen extends StatelessWidget {
  const UnitDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Unit Details'),
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
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightSecondary.withValues(alpha: 0.3),
                      AppTheme.secondary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child:
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          // Icon(
                          //   Icons.pets,
                          //   size: 80,
                          //   color: AppTheme.secondary.withValues(alpha: 0.7),
                          // ),
                          // const SizedBox(height: AppConstants.spacingS),
                          // const Text(
                          //   'Buffalo Image',
                          //   style: AppTheme.bodyMedium,
                          // ),
                          //],
                          //),
                          Image.asset(
                            'assets/images/murrah1.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                    // Quarantine Badge
                    Positioned(
                      top: AppConstants.spacingM,
                      right: AppConstants.spacingM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: AppConstants.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusS,
                          ),
                        ),
                        child: const Text(
                          'Healthy',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
             'Unit Information',
              style: AppTheme.headingMedium.copyWith(
              color: isDark ? Colors.white : Colors.black,
               ),
               ),
            //const Text('Unit Information', style: AppTheme.headingMedium),
            
            const SizedBox(height: AppConstants.spacingM),

            _buildInfoCard([
              _buildInfoRow('Unit ID', 'BUF-001'),
              _buildInfoRow('Age', '4 years 2 months'),
              _buildInfoRow('Breed', 'Murrah Buffalo'),
              _buildInfoRow('Weight', '520 kg'),
              _buildInfoRow('Last Check', '2 days ago'),
            ]),
            const SizedBox(height: AppConstants.spacingL),

            // Health Summary
            Text('Health Summary',
                style: AppTheme.headingMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                  
                )),
          // const Text('Health Summary', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    'Temperature',
                    '101.2°F',
                    isDark ? AppTheme.white : AppTheme.black,
                    Icons.thermostat
             
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildHealthIndicator(
                    'Milk Production',
                    '12L/day',
                   isDark ? AppTheme.white : AppTheme.black,
                    Icons.water_drop
                  
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    'Appetite',
                    'Good',
                   isDark ? AppTheme.white : AppTheme.black,
                    Icons.restaurant
                   
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildHealthIndicator(
                    'Activity',
                    'Normal',isDark? AppTheme.white : AppTheme.black,
                 
                    Icons.directions_walk
                   
                  ),
                ),
              ],
            ),
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

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
            



             color: AppTheme.mediumGrey
              ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(
    String label,
    String value,
    Color color,
    IconData icon,
    
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            Icon(icon, color:  AppTheme.successGreen, size: AppConstants.iconL),
            const SizedBox(height: AppConstants.spacingS),
            Text(label, style: AppTheme.bodySmall.copyWith(
               color: color,
            ), textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
