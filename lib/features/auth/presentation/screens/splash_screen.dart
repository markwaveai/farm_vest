import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:farm_vest/core/utils/app_enums.dart';

import 'dart:ui';
// import 'package:shimmer/shimmer.dart';

import 'package:farm_vest/core/localization/translation_helpers.dart';
class SplashScreen extends ConsumerStatefulWidget {
  SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _bgScale;
  late Animation<double> _bgBlur;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _textReveal;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSequence();
  }

  void _initializeAnimations() {
    // 1. Background slow zoom
    _backgroundController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );
    _bgScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    _bgBlur = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // 2. Content (Logo, Text) reveal
    _contentController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Interval(0.1, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Interval(0.1, 0.5, curve: Curves.elasticOut),
      ),
    );

    _textReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startSequence() async {
    _backgroundController.forward();
    await _contentController.forward();
    await _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await ref.read(authProvider.notifier).checkLoginStatus();
    // Keep the splash visible for a minimum time for the "premium" feel
    await Future.delayed(Duration(milliseconds: 500));

    if (!mounted) return;

    final authState = ref.read(authProvider);
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!onboardingCompleted) {
      context.go('/onboarding');
    } else if (authState.mobileNumber != null) {
      _navigateBasedOnRole(authState.role ?? UserType.customer);
    } else {
      context.go('/login');
    }
  }

  void _navigateBasedOnRole(UserType role) {
    switch (role) {
      case UserType.customer:
        context.go('/customer-dashboard');
        break;
      case UserType.supervisor:
        context.go('/supervisor-dashboard');
        break;
      case UserType.doctor:
        context.go('/doctor-dashboard');
        break;
      case UserType.assistant:
        context.go('/assistant-dashboard');
        break;
      case UserType.farmManager:
        context.go('/farm-manager-dashboard');
        break;
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Cinematic Image
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScale.value,
                child: Image.asset(
                  'assets/images/splash_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: AppTheme.primary),
                ),
              );
            },
          ),

          // 2. Dark Overlay & Blur
          AnimatedBuilder(
            animation: _bgBlur,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _bgBlur.value,
                  sigmaY: _bgBlur.value,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        AppTheme.primary.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Horizontal Logo Reveal
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Image.asset(
                            'assets/images/farmvest_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Column(
                                  children: [
                                    Icon(
                                      Icons.agriculture,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      'FarmVest'.tr(ref),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24),

                // Subtitle/Motto Reveal
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textReveal.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _textReveal.value)),
                        child: Column(
                          children: [
                            Container(
                              height: 1.5,
                              width: 60 * _textReveal.value,
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'SMART DAIRY FARM MANAGEMENT'.tr(ref),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                    letterSpacing: 4 * _textReveal.value,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 4. Subtle Bottom Glow
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textReveal,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.5,
                    colors: [
                      AppTheme.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
