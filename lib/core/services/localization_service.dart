import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static final Map<String, Map<String, String>> _localizedStrings = {};
  static String _currentLanguage = 'en';

  static const List<String> supportedLanguages = ['en', 'hi', 'te'];

  static Future<void> init() async {
    for (final lang in supportedLanguages) {
      try {
        final jsonString = await rootBundle.loadString('assets/lang/$lang.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        _localizedStrings[lang] = jsonMap.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      } catch (e) {
        debugPrint('Failed to load $lang.json: $e');
      }
    }
  }

  static void setLanguage(String code) {
    if (supportedLanguages.contains(code)) {
      _currentLanguage = code;
    }
  }

  static String get currentLanguage => _currentLanguage;

  static String translate(String key, {Map<String, String>? params}) {
    String value = _localizedStrings[_currentLanguage]?[key] ??
        _localizedStrings['en']?[key] ??
        key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('@$paramKey', paramValue);
      });
    }

    return value;
  }
}
