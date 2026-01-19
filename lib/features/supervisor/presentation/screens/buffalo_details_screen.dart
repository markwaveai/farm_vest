import 'package:flutter/material.dart';

class BuffaloDetailsScreen extends StatelessWidget {
  final String location;

  const BuffaloDetailsScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buffalo Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Details for Buffalo at:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              location,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // TODO: Fetch and display more buffalo details here
          ],
        ),
      ),
    );
  }
}
