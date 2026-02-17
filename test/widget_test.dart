// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:farm_vest/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  testWidgets('FarmVest app smoke test', (WidgetTester tester) async {
    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // 2. Ensure GetX is reset
    Get.reset();

    // 3. Pump the app
    await tester.pumpWidget(ProviderScope(child: FarmVestApp()));

    // 4. Wait for splash screen (and ensure timer completes)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 5. Verify that we can find the FarmVest text (likely in Login screen now)
    // Note: Splash screen has "FarmVest", Login might have it too.
    // If localization is working, 'FarmVest' key should map to 'FarmVest' in English (default)
    expect(find.text('FarmVest'), findsOneWidget);
  });
}
