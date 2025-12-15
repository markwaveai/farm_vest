import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    // Check login status while animation plays
    await ref.read(authProvider.notifier).checkLoginStatus();

    // Additional delay for visual effect
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final authState = ref.read(authProvider);

      if (authState.mobileNumber != null) {
        // User is logged in, navigate to role-based dashboard
        // Since we modified completeLogin to return Role, but here we just have state.
        // We can replicate the switch logic or adding a helper in AuthController.
        // For now, simple switch based on role.
        if (authState.role == UserRole.customer) {
          context.go('/customer-dashboard');
        } else if (authState.role == UserRole.supervisor) {
          context.go(
            '/farm-dashboard',
          ); // Assuming supervisor goes here or create route
        } else if (authState.role == UserRole.doctor) {
          context.go('/health-records'); // Assuming doctor dashboard
        } else if (authState.role == UserRole.assistant) {
          context.go('/farm-dashboard');
        } else {
          context.go('/customer-dashboard');
        }
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // FarmVest Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        size: 60,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingL),

                    // App Name
                    const Text(
                      'FarmVest',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingS),

                    // Subtitle
                    const Text(
                      'Smart Dairy Management',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL * 2),

                    // Loading indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),

                    // Powered by MarkWave
                    const Text(
                      AppConstants.poweredBy,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
