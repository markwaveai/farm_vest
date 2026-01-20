import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
// import 'package:buffalo_visualizer/main.dart';
// Assuming ControllerPage is exported from main.dart in the package structure.
// If main.dart is not the library file, we might need to import specific files,
// but based on temp_visualizer structure, main.dart contains ControllerPage.

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightGrey,
        appBar: AppBar(
          title: const Text('Admin Dashboard - Buffalo Visualizer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Handle logout logic if needed, or rely on drawer/profile
              },
            ),
          ],
        ),
        // body: const ControllerPage(),
      ),
    );
  }
}
