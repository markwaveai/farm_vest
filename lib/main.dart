import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/biometric_lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyC88x_wjf5oBRmTxyXUwXV_UY2N73kl82c",
    appId: "1:612299373064:android:5985b830becec8cd0eefbd",
    messagingSenderId: "612299373064",
    projectId: "markwave-481315",
    storageBucket: "markwave-481315.firebasestorage.app",
  ),
);

  runApp(
    DevicePreview(
     enabled: !kReleaseMode,
     builder: (context) => const 
      ProviderScope(child: FarmVestApp()),
   ),
  );
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
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        final built = DevicePreview.appBuilder(context, child);
        return BiometricLockScreen(child: built);
      },
    );
  }
}
