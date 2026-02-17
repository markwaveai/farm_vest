import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_constants.dart';

/// Provider to track if the app is currently in Staging mode.
/// This allows the UI (like the top banner) to reactively update when the environment is switched.
final isStagingProvider = NotifierProvider<IsStagingNotifier, bool>(
  IsStagingNotifier.new,
);

class IsStagingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return AppConstants.appLiveUrl == AppConstants.stagingUrl;
  }

  set state(bool value) => super.state = value;
}
