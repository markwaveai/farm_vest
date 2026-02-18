import 'package:farm_vest/core/services/localization_service.dart';

extension StringLocalization on String {
  String get tr => LocalizationService.translate(this);

  String trParams(Map<String, String> params) =>
      LocalizationService.translate(this, params: params);
}
