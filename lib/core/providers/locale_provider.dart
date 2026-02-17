import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// StateNotifier for managing the current locale
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(const Locale('en', 'US')) {
    _loadSavedLocale();
  }

  final SharedPreferences _prefs;
  static const String _localeKey = 'app_locale';

  // Load saved locale from SharedPreferences
  void _loadSavedLocale() {
    final savedLocaleCode = _prefs.getString(_localeKey);
    if (savedLocaleCode != null) {
      state = _getLocaleFromCode(savedLocaleCode);
    }
  }

  // Change the current locale
  Future<void> setLocale(String languageCode) async {
    final newLocale = _getLocaleFromCode(languageCode);
    state = newLocale;
    await _prefs.setString(_localeKey, languageCode);
  }

  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case 'hi':
        return const Locale('hi', 'IN');
      case 'te':
        return const Locale('te', 'IN');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }
}

// Provider for the current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

// Provider for available locales
final availableLocalesProvider = Provider<List<Locale>>((ref) {
  return const [Locale('en', 'US'), Locale('hi', 'IN'), Locale('te', 'IN')];
});
