import 'package:flutter/material.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

/// Displays a standardized error snackbar.
///
/// [context] is the BuildContext from which to show the snackbar.
/// [message] is the error message to display.
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.errorRed,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
