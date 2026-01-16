import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/new_supervisor_dashboard.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;

  const CustomDialog({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

}

Future<void> showSuccessDialog(
  BuildContext context,
  String message,
) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return CustomDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),

            const Text(
              'Success',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 24),

            CustomActionButton(
              child: Text('OK',style: TextStyle(color: AppTheme.white),),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => NewSupervisorDashboard(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}




