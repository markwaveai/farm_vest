import 'package:flutter/material.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class BuffaloDetailsScreen extends ConsumerWidget {
  final String location;

  BuffaloDetailsScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Buffalo Details'.tr(ref))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Details for Buffalo at:'.tr(ref),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text(
              location,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            // TODO: Fetch and display more buffalo details here
          ],
        ),
      ),
    );
  }
}
