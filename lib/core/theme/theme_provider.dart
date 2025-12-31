import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Using Notifier (Riverpod 2.0+) which is the modern equivalent/replacement for StateNotifier
// in newer Riverpod versions, ensuring compatibility if StateNotifier is not exported.
class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    Future.microtask(_loadTheme);
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    if (value == null) return;

    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.light,
    );
    state = mode;
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  void toggleTheme() {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = next;
    Future.microtask(() => _saveTheme(next));
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    Future.microtask(() => _saveTheme(mode));
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

// Global provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(),
);
