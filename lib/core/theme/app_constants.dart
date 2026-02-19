// App constants

import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

const String kHyphen = '--';

class AppConstants {
  static const String appName = 'FarmVest';
  static const String deleteAccountUrl =
      'https://dashboard.farmvest.in/farmvest/account-deletion';

  static String stagingUrl =
      'https://farmvest-stagging-services-612299373064.asia-south1.run.app/api';
  static String liveUrl =
      'https://farmvest-live-apis-jn6cma3vvq-el.a.run.app/api';

  static String localUrl =
      'http://127.0.0.1:8000/api'; // For ADB Reverse / iOS Sim
  // static String localUrl = 'http://10.0.2.2:8000/api'; // For Android Emulator
  // static String localUrl = 'http://192.168.0.226:8000/api'; // For Physical Device (Your IP)

  static String animalKartStagingApiUrl =
      'https://animalkart-stagging-612299373064.asia-south1.run.app';
  static String animalKartLiveApiUrl =
      'https://animalkart-live-apis-jn6cma3vvq-el.a.run.app';

  static String animalKartApiUrl = animalKartLiveApiUrl;

  static String appLiveUrl = liveUrl; // Default to Live
  static String visitApiUrl = appLiveUrl;

  static bool _isStaging = false;
  static bool get isStaging => _isStaging;

  static String get profilePicsPath =>
      isStaging ? 'farmvest/stagingUserPics' : 'farmvest/userpics';

  static String get buffaloOnboardingPath => isStaging
      ? 'farmvest/stagingbuffaloesonboarding'
      : 'farmvest/buffaloesonboarding';

  static const String authApiKey =
      'bWFya3dhdmUtZmFybXZlc3QtdGVzdHRpbmctYXBpa2V5';

  static void useLocal() {
    _isStaging = true;
    appLiveUrl = localUrl;
    visitApiUrl = localUrl;
    animalKartApiUrl = animalKartStagingApiUrl; // Usually staging for local dev
  }

  static void useStaging() {
    _isStaging = true;
    appLiveUrl = stagingUrl;
    visitApiUrl = stagingUrl;
    animalKartApiUrl = animalKartStagingApiUrl;
  }

  static void useLive() {
    _isStaging = false;
    appLiveUrl = liveUrl;
    visitApiUrl = liveUrl;
    animalKartApiUrl = animalKartLiveApiUrl;
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to Live (false) if not found
    final bool useStagingPref = prefs.getBool('use_staging') ?? false;

    if (useStagingPref) {
      useStaging();
    } else {
      useLive();
    }
  }

  static String storageBucketName = 'gs://markwave-481315.firebasestorage.app';
  static const String poweredBy = 'Powered by MarkWave';
  static Duration kToastAnimDuration = Duration(milliseconds: 600);
  static Duration kToastDuration = Duration(milliseconds: 1800);
  static const double tabletMaxheight = 900;
  static const double smallphoneheight = 600;
  static const double mediumphoneheight = 800;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Headers
  static const String applicationJson = 'application/json';
  static String formatIndianCurrencyShort(dynamic value) {
    if (value == null) return '₹0';

    num? amount;
    if (value is num) {
      amount = value;
    } else {
      final raw = value.toString();
      final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
      amount = num.tryParse(cleaned);
    }

    if (amount == null) return '₹0';

    final isNegative = amount < 0;
    final amt = amount.abs().round();

    final cr = amt ~/ 10000000;
    final afterCr = amt % 10000000;
    final l = afterCr ~/ 100000;
    final afterL = afterCr % 100000;
    final k = afterL ~/ 1000;
    final rem = afterL % 1000;

    final parts = <String>[];
    if (cr > 0) parts.add('${cr}Cr');
    if (l > 0) parts.add('${l}L');
    if (k > 0) parts.add('${k}K');
    if (rem > 0 || parts.isEmpty) parts.add('$rem');

    final text = '₹${parts.join(' ')}';
    return isNegative ? '-$text' : text;
  }

  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final year = dt.year;
      final month = dt.month.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');

      int hour = dt.hour;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      final minute = dt.minute.toString().padLeft(2, '0');

      return '$year-$month-$day $hour:$minute $amPm';
    } catch (_) {
      return isoString;
    }
  }
}

class FormatUtils {
  static const double halfUnitCost =
      175000; // cost per 0.5 unit (1 buffalo + 1 calf)
  static const double cpfPerUnit = 15000; // CPF per half unit
  static String formatAmount(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: 'Rs:').format(amount);
  }
}
