import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/biometric_lock_screen.dart';

Future<void> main() async {
  ApiServices.onUnauthorized = () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all user data
    print('here we logout unauthorised');
    AppRouter.router.go('/login');
  };
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Add web-specific options here if needed
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC88x_wjf5oBRmTxyXUwXV_UY2N73kl82c",
          appId:
              "1:612299373064:android:5985b830becec8cd0eefbd", // Replace with Web App ID
          messagingSenderId: "612299373064",
          projectId: "markwave-481315",
          storageBucket: "markwave-481315.firebasestorage.app",
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC88x_wjf5oBRmTxyXUwXV_UY2N73kl82c",
          appId: "1:612299373064:android:5985b830becec8cd0eefbd",
          messagingSenderId: "612299373064",
          projectId: "markwave-481315",
          storageBucket: "markwave-481315.firebasestorage.app",
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // TODO: Add your iOS App ID from Firebase Console
      // Using an Android App ID on iOS causes a native crash (NSException).
      /*
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC88x_wjf5oBRmTxyXUwXV_UY2N73kl82c",
          appId: "YOUR_IOS_APP_ID", 
          messagingSenderId: "612299373064",
          projectId: "markwave-481315",
          storageBucket: "markwave-481315.firebasestorage.app",
          iosBundleId: "com.example.farmVest",
        ),
      );
      */
      debugPrint(
        "Firebase initialization skipped for iOS. Please provide a valid iOS App ID.",
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(child: FarmVestApp()),
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
      title: 'FarmVest - Smart Dairy Farm Management',
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
