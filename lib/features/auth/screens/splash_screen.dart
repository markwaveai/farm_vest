import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/app_enums.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers for different stages
  late AnimationController _dropController;
  late AnimationController _zoomController;
  late AnimationController _expandController;
  late AnimationController _finalController;

  // Animations
  late Animation<double> _dropAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _circleScaleAnimation;
  late Animation<double> _finalIconScaleAnimation;

  // Stage tracking
  int _currentStage = 0; // 0: white, 1: drop, 2: zoom, 3: expand, 4: final

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Stage 1: Drop animation (icon drops from top)
    _dropController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _dropAnimation = Tween<double>(begin: -200.0, end: 0.0).animate(
      CurvedAnimation(parent: _dropController, curve: Curves.bounceOut),
    );

    // Stage 2: Zoom animation (icon grows)
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    // Stage 3: Circle expansion
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _circleScaleAnimation = Tween<double>(begin: 1.0, end: 11.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    // Stage 4: Final icon scale
    _finalController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _finalIconScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _finalController, curve: Curves.elasticOut),
    );
  }

  void _startAnimationSequence() async {
    // Stage 0: White screen (500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Stage 1: Icon drops from top
    setState(() => _currentStage = 1);
    await _dropController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Stage 2: Icon zooms in
    setState(() => _currentStage = 2);
    await _zoomController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Stage 3: Circle expands to fill screen
    setState(() => _currentStage = 3);
    await _expandController.forward();
    // Removed delay here to prevent blank green screen
    if (!mounted) return;

    // Stage 4: Final green screen with large icon (appears immediately)
    setState(() => _currentStage = 4);
    await _finalController.forward();

    // Check login status and navigate
    await _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Check login status
    await ref.read(authProvider.notifier).checkLoginStatus();

    // Additional delay for visual effect
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      final authState = ref.read(authProvider);

      // Check if onboarding has been completed
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;

      if (!onboardingCompleted) {
        // First time user - show onboarding
        context.go('/onboarding');
      } else if (authState.mobileNumber != null) {
        // User is logged in, navigate to role-based dashboard
        if (authState.role == UserType.customer) {
          context.go('/customer-dashboard');
        } else if (authState.role == UserType.supervisor) {
          context.go('/supervisor-dashboard');
        } else if (authState.role == UserType.doctor) {
          context.go('/doctor-dashboard');
        } else if (authState.role == UserType.assistant) {
          context.go('/assistant-dashboard');
        } else if (authState.role == UserType.admin) {
          context.go('/admin-dashboard');
        } else {
          context.go('/customer-dashboard');
        }
      } else {
        // Not logged in - show login
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _dropController.dispose();
    _zoomController.dispose();
    _expandController.dispose();
    _finalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentStage >= 3 ? AppTheme.primary : AppTheme.white,
      body: Stack(
        children: [
          // Stage 0-2: White background with animated icon
          if (_currentStage > 0 && _currentStage < 3)
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_dropController, _zoomController]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _dropAnimation.value),
                    child: Transform.scale(
                      scale: _currentStage >= 2
                          ? _iconScaleAnimation.value
                          : 1.0,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: AppTheme.white,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Stage 3: Circle expansion animation
          if (_currentStage == 3)
            Center(
              child: AnimatedBuilder(
                animation: _expandController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _circleScaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: AppTheme.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Stage 4: Final green screen with large icon
          if (_currentStage == 4)
            Center(
              child: AnimatedBuilder(
                animation: _finalController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _finalIconScaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Large tractor/farm icon
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: AppTheme.white,
                            size: 120,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // App Name
                        const Text(
                          'FarmVest',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.white,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        const Text(
                          'Smart Dairy Farm Management',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
