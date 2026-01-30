import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/router/app_router.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/theme/theme_provider.dart';
import 'package:farm_vest/core/widgets/biometric_lock_screen.dart';

import 'package:farm_vest/core/services/remote_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiServices.onUnauthorized = () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all user data
    print('here we logout unauthorised');
    AppRouter.router.go('/login');
  };

  if (Firebase.apps.isEmpty) {
    try {
      if (kIsWeb) {
        // Add web-specific options here if needed
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyC0XUQqk51NGLazlnaGKsPAgjkNNbgZR-E",
            appId: "1:612299373064:web:5d5ea121566c54b30eefbd",
            messagingSenderId: "612299373064",
            projectId: "markwave-481315",
            storageBucket: "markwave-481315.firebasestorage.app",
            measurementId: "G-F2RTN0NXXD",
          ),
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyC88x_wjf5oBRmTxyXUwXV_UY2N73kl82c",
            appId: "1:612299373064:android:c1d4128de1e099f20eefbd",
            messagingSenderId: "612299373064",
            projectId: "markwave-481315",
            storageBucket: "markwave-481315.firebasestorage.app",
          ),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyD2v698q2fOZTM8oegi2tq962-wBsLGay8",
            appId: "1:612299373064:ios:428bc6097f5171e80eefbd",
            messagingSenderId: "612299373064",
            projectId: "markwave-481315",
            storageBucket: "markwave-481315.firebasestorage.app",
            iosBundleId: "com.markwave.farmvest",
          ),
        );
        debugPrint(
          "Firebase initialized for iOS with bundle ID: com.markwave.farmvest",
        );
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      debugPrint("Firebase initialization failed: $e");
    }
  }

  // One-time setup to create the config document in Firestore
  // await RemoteConfigService.seedDefaultConfig();

  // Initialize Remote Config (URLs & Version)
  // await RemoteConfigService.initialize();

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
    // _initScreenProtection() removed
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
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final built = DevicePreview.appBuilder(context, child);
        return BiometricLockScreen(child: built);
      },
    );
  }
}
