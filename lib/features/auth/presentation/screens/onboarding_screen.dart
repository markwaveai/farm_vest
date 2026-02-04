import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Smart Asset Management',
      description:
          'Manage your assets in a smart way and get all the information in one place',
      imagePath: 'assets/images/onboarding_asset.png',
      backgroundColor: AppTheme.lightGrey,
    ),
    OnboardingPage(
      title: '24/7 Surveillance',
      description:
          'Keep track and be a virtual eye to your assets with our 24/7 monitoring system',
      imagePath: 'assets/images/onboarding_surveillance.png',
      backgroundColor: AppTheme.lightGrey,
    ),
    OnboardingPage(
      title: 'Doctors Care',
      description:
          'Certified and experienced doctors available for consultation',
      imagePath: 'assets/images/onboarding_doctor.png',
      backgroundColor: AppTheme.lightGrey,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.mediumGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildIndicator(index == _currentPage),
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    final size = MediaQuery.of(context).size;
    final isSmallPhone = size.height < 700;
    final isMediumPhone = size.height < 820;

    return SingleChildScrollView(
      physics: isSmallPhone
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: isSmallPhone ? 16 : 32),

            // Title
            Text(
              page.title,
              style: AppTheme.headingLarge.copyWith(
                fontSize: isSmallPhone ? 22 : 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              page.description,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: isSmallPhone ? 13 : 15,
                height: 1.4,
                color: AppTheme.slate,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isSmallPhone ? 24 : 48),

            // Image container (responsive height)
            Container(
              height: isSmallPhone
                  ? 220
                  : isMediumPhone
                  ? 300
                  : 380,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.white,
                    AppTheme.primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  page.imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Center(
                      child: Icon(
                        _getIconForPage(page.title),
                        size: isSmallPhone ? 120 : 180,
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: isSmallPhone ? 24 : 48),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPage(String title) {
    if (title.contains('Asset')) {
      return Icons.phone_android;
    } else if (title.contains('Surveillance')) {
      return Icons.videocam;
    } else if (title.contains('Doctor')) {
      return Icons.medical_services;
    }
    return Icons.info;
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.mediumGrey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}
