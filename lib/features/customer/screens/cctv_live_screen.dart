import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CCTVLiveScreen extends StatefulWidget {
  const CCTVLiveScreen({super.key});

  @override
  State<CCTVLiveScreen> createState() => _CCTVLiveScreenState();
}

class _CCTVLiveScreenState extends State<CCTVLiveScreen> {
  bool _isFullScreen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text('Live CCTV'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => NavigationHelper.safePopOrNavigate(
                  context,
                  fallbackRoute: '/customer-dashboard',
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
      body: Column(
        children: [
          // Video Feed Container
          Expanded(
            flex: _isFullScreen ? 1 : 3,
            child: Container(
              width: double.infinity,
              margin: _isFullScreen
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: _isFullScreen
                    ? BorderRadius.zero
                    : BorderRadius.circular(AppConstants.radiusL),
              ),
              child: Stack(
                children: [
                  // Video placeholder
                  Center(
                    child: _isLoading
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppTheme.white),
                              SizedBox(height: AppConstants.spacingM),
                              Text(
                                'Connecting to camera...',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[800]!, Colors.grey[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam,
                                    size: 80,
                                    color: AppTheme.white,
                                  ),
                                  SizedBox(height: AppConstants.spacingM),
                                  Text(
                                    'Live Feed - Unit BUF-001',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: AppConstants.spacingS),
                                  Text(
                                    'Camera 1 - Main Area',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),

                  // Control overlay
                  if (!_isLoading)
                    Positioned(
                      bottom: AppConstants.spacingM,
                      left: AppConstants.spacingM,
                      right: AppConstants.spacingM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingM,
                          vertical: AppConstants.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildControlButton(
                              Icons.camera_alt,
                              'Screenshot',
                              _takeScreenshot,
                            ),
                            _buildControlButton(
                              Icons.refresh,
                              'Refresh',
                              _refreshFeed,
                            ),
                            _buildControlButton(
                              _isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              _isFullScreen ? 'Exit' : 'Fullscreen',
                              _toggleFullScreen,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Live indicator
                  if (!_isLoading)
                    Positioned(
                      top: AppConstants.spacingM,
                      left: AppConstants.spacingM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: AppConstants.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusS,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingXS),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Camera info and controls (hidden in fullscreen)
          if (!_isFullScreen) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Camera Information',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      child: Column(
                        children: [
                          _buildInfoRow('Camera ID', 'CAM-001'),
                          _buildInfoRow('Location', 'Main Feeding Area'),
                          _buildInfoRow(
                            'Status',
                            'Online',
                            color: AppTheme.successGreen,
                          ),
                          _buildInfoRow('Quality', '1080p HD'),
                          _buildInfoRow('Last Update', 'Live'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),

                  // Camera selection
                  const Text('Available Cameras', style: AppTheme.headingSmall),
                  const SizedBox(height: AppConstants.spacingS),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCameraOption('Camera 1', 'Main Area', true),
                        _buildCameraOption('Camera 2', 'Feeding Zone', false),
                        _buildCameraOption('Camera 3', 'Rest Area', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.white, size: AppConstants.iconM),
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            label,
            style: const TextStyle(color: AppTheme.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGrey),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraOption(String name, String location, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: AppConstants.spacingS),
      child: Card(
        color: isActive ? AppTheme.primary : AppTheme.white,
        child: InkWell(
          onTap: () {
            // Switch camera
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              children: [
                Icon(
                  Icons.videocam,
                  color: isActive ? AppTheme.white : AppTheme.primary,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  name,
                  style: TextStyle(
                    color: isActive ? AppTheme.white : AppTheme.darkGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: isActive ? AppTheme.white : AppTheme.mediumGrey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _takeScreenshot() {
    ToastUtils.showSuccess(context, 'Screenshot saved to gallery');
  }

  void _refreshFeed() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}
