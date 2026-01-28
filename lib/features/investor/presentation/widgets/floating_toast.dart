import 'package:oktoast/oktoast.dart';

import 'package:farm_vest/core/theme/app_constants.dart';

/// A utility class for displaying toast messages with queue management.
///
/// This class ensures that only one toast is displayed at a time by maintaining
/// a queue of pending messages. When a toast is dismissed, the next message in
/// the queue is automatically displayed.
///
/// Example usage:
/// ```dart
/// FloatingToast.showSimpleToast('Operation successful');
/// FloatingToast.showSimpleToast('Second message'); // Will queue and show after first
/// ```
class FloatingToast {
  /// Tracks whether a toast is currently being displayed
  static bool _alreadyShowingToast = false;

  /// Queue of pending toast messages
  static List<String> queue = [];

  /// Displays a toast message with optional custom duration.
  ///
  /// If a toast is already being displayed, the new message is added to the queue
  /// and will be shown once the current toast is dismissed.
  ///
  /// Parameters:
  /// - [message]: The text to display in the toast
  /// - [duration]: Optional custom duration (defaults to [AppConstants.kToastDuration])
  static void showSimpleToast(String message, {Duration? duration}) {
    // If a toast is already showing, queue this message
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

  /// Checks the queue and shows the next toast if available.
  ///
  /// This method is called automatically when a toast is dismissed.
  static void _checkAndShowQueueToasts() {
    _alreadyShowingToast = false;

    if (queue.isEmpty) {
      return;
    }

    // Show the next message in queue
    showSimpleToast(queue.removeAt(0));
  }
}
