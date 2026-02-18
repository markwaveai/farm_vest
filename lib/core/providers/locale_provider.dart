import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/services/localization_service.dart';

class LocaleNotifier extends Notifier<Locale> {
  static const _localeKey = 'app_locale';

  static const Map<String, Locale> _supportedLocales = {
    'en': Locale('en', 'US'),
    'hi': Locale('hi', 'IN'),
    'te': Locale('te', 'IN'),
  };

  @override
  Locale build() {
    Future.microtask(_loadLocale);
    return const Locale('en', 'US');
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && _supportedLocales.containsKey(code)) {
      LocalizationService.setLanguage(code);
      state = _supportedLocales[code]!;
    }
  }

  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode;
    LocalizationService.setLanguage(code);
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  Future<void> setLanguageCode(String code) async {
    final locale = _supportedLocales[code];
    if (locale != null) {
      await setLocale(locale);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);
