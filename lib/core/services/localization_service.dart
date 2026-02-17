import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final Map<String, Map<String, String>> _translations = {};
  static bool _isInitialized = false;

  // Initialize and load all language files
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      _translations['en'] = await _loadJson('en');
      _translations['hi'] = await _loadJson('hi');
      _translations['te'] = await _loadJson('te');
      _isInitialized = true;
      print('Localization initialized successfully');
    } catch (e) {
      print('Error initializing localization: $e');
    }
  }

  // Load a single JSON language file
  static Future<Map<String, String>> _loadJson(String langCode) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/lang/$langCode.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('Error loading $langCode.json: $e');
      return {};
    }
  }

  // Get translation for a key in a specific language
  static String translate(String key, String languageCode) {
    if (!_isInitialized) {
      return key;
    }
    return _translations[languageCode]?[key] ?? key;
  }

  // Get all translations for a language
  static Map<String, String>? getTranslations(String languageCode) {
    return _translations[languageCode];
  }
}
