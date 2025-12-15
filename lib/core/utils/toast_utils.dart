import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_theme.dart';

/// Utility class for displaying toast messages using fluttertoast package
class ToastUtils {
  /// Show a success toast message
  static void showSuccess(BuildContext context, String message) {
    _showToast(message, AppTheme.successGreen, Colors.white);
  }

  /// Show an error toast message
  static void showError(BuildContext context, String message) {
    _showToast(message, AppTheme.errorRed, Colors.white);
  }

  /// Show a warning toast message
  static void showWarning(BuildContext context, String message) {
    _showToast(message, AppTheme.warningOrange, Colors.white);
  }

  /// Show an info toast message
  static void showInfo(BuildContext context, String message) {
    _showToast(message, AppTheme.primary, Colors.white);
  }

  /// Internal method to show toast using Fluttertoast
  static void _showToast(
    String message,
    Color backgroundColor,
    Color textColor,
  ) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
