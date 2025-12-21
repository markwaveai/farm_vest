import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: FarmVestApp()));
}

class FarmVestApp extends ConsumerStatefulWidget {
  const FarmVestApp({super.key});

  @override
  ConsumerState<FarmVestApp> createState() => _FarmVestAppState();
}

class _FarmVestAppState extends ConsumerState<FarmVestApp> {
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
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'FarmVest - Smart Dairy Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
