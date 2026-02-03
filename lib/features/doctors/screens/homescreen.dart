import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(child: Text('Doctor Home')),
    );
  }
}
