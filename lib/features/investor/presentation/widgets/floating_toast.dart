
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:oktoast/oktoast.dart';

class FloatingToast {
  static bool _alreadyShowingToast = false;
  static List<String> queue = [];
  static void showSimpleToast(String message, {Duration? duration}) {
    ///If we are alrady showing the toast the next message will be added to queue
    ///and once current toast is dismissed then new toast will be shown
    if (_alreadyShowingToast) {
      queue.add(message);
      return;
    }
    _alreadyShowingToast = true;
    showToast(
      message,
      duration: duration ?? AppConstants.kToastDuration,
      animationDuration: AppConstants.kToastAnimDuration,
      position: ToastPosition.bottom,
      onDismiss: _checkAndShowQueueToasts,
    );
  }

  static void _checkAndShowQueueToasts() {
    _alreadyShowingToast = false;
    if (queue.isEmpty) return;
    showSimpleToast(queue.removeAt(0));
  }
}