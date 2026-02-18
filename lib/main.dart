import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/auth_api_services.dart';
import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/services/sheds_api_services.dart';
import 'package:farm_vest/core/services/tickets_api_services.dart';
import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/services/notification_service.dart';
import 'package:farm_vest/core/router/app_router.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/theme/theme_provider.dart';
import 'package:farm_vest/core/widgets/biometric_lock_screen.dart';

import 'package:farm_vest/core/services/remote_config_service.dart';
import 'package:farm_vest/core/services/localization_service.dart';
import 'package:farm_vest/core/providers/environment_provider.dart';
import 'package:farm_vest/core/providers/locale_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart'; // Commented out - package not in pubspec.yaml

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  // Badge functionality commented out until flutter_app_badger is added to pubspec.yaml
  // if (message.data['badge'] != null) {
  //   final badgeCount = int.tryParse(message.data['badge'].toString());
  //   if (badgeCount != null) {
  //     FlutterAppBadger.updateBadgeCount(badgeCount);
  //   }
  // }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConstants.initialize();

  ApiServices.onUnauthorized = () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('mobile_number');
    await prefs.remove('user_roles');
    await prefs.remove('active_role');
    await prefs.remove('user_data');
    print('here we logout unauthorised');
    AppRouter.router.go('/login');
  };

  AuthApiServices.onUnauthorized = ApiServices.onUnauthorized;
  AnimalApiServices.onUnauthorized = ApiServices.onUnauthorized;
  ShedsApiServices.onUnauthorized = ApiServices.onUnauthorized;
  TicketsApiServices.onUnauthorized = ApiServices.onUnauthorized;

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

  // Register background message handler before FCM init
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM after Firebase
  try {
    await NotificationService().initializeFCM();
  } catch (e) {
    debugPrint("FCM initialization failed: $e");
  }

  // Initialize Remote Config (URLs & Version)
  await RemoteConfigService.initialize();

  // Initialize Localization
  await LocalizationService.init();

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const FarmVestApp(),
      ),
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
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'FarmVest - Smart Dairy Farm Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context), // Add this line
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('te', 'IN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Wrap with DevicePreview builder first
        final childWithPreview = DevicePreview.appBuilder(context, child);

        final built = childWithPreview!;
        final isStaging = ref.watch(isStagingProvider);

        if (isStaging) {
          return BiometricLockScreen(
            child: Material(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.orange,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      bottom: 2,
                    ),
                    child: const Center(
                      child: Text(
                        'DEV MODE - STAGING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: built),
                ],
              ),
            ),
          );
        }
        return BiometricLockScreen(child: built);
      },
    );
  }
}
