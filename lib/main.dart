import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: FarmVestApp()));
}

class FarmVestApp extends StatefulWidget {
  const FarmVestApp({super.key});

  @override
  State<FarmVestApp> createState() => _FarmVestAppState();
}

class _FarmVestAppState extends State<FarmVestApp> {
  @override
  void initState() {
    super.initState();
    _initScreenProtection();
  }

  Future<void> _initScreenProtection() async {
    // Prevent screenshots and screen recording (IOS & Android)
    await ScreenProtector.preventScreenshotOn();
    // Protect data in app switcher (iOS)
    await ScreenProtector.protectDataLeakageWithBlur();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FarmVest - Smart Dairy Management',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
