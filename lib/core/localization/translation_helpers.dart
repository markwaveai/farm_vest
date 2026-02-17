import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/services/localization_service.dart';
import 'package:farm_vest/core/providers/locale_provider.dart';

// Extension on String for easy translation
extension StringTranslation on String {
  String tr(WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return LocalizationService.translate(this, locale.languageCode);
  }
}

// Global helper function for translation (for non-widget contexts)
String tr(String key, WidgetRef ref) {
  final locale = ref.read(localeProvider);
  return LocalizationService.translate(key, locale.languageCode);
}

// Get translation without watching (doesn't rebuild on locale change)
String trStatic(String key, WidgetRef ref) {
  final locale = ref.read(localeProvider);
  return LocalizationService.translate(key, locale.languageCode);
}
