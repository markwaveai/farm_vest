import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const List<_LanguageOption> _languages = [
    _LanguageOption(code: 'en', label: 'English', nativeLabel: 'English'),
    _LanguageOption(code: 'hi', label: 'Hindi', nativeLabel: 'हिन्दी'),
    _LanguageOption(code: 'te', label: 'Telugu', nativeLabel: 'తెలుగు'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentCode = currentLocale.languageCode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _languages.map((lang) {
        final isSelected = currentCode == lang.code;
        return ListTile(
          title: Text(lang.label),
          subtitle: Text(lang.nativeLabel),
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () {
            ref.read(localeProvider.notifier).setLanguageCode(lang.code);
          },
        );
      }).toList(),
    );
  }
}

class _LanguageOption {
  final String code;
  final String label;
  final String nativeLabel;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.nativeLabel,
  });
}
