import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BuffaloGridScreen extends ConsumerStatefulWidget {
  const BuffaloGridScreen({super.key});

  @override
  ConsumerState<BuffaloGridScreen> createState() => _BuffaloGridScreenState();
}

class _BuffaloGridScreenState extends ConsumerState<BuffaloGridScreen> {
  // In a real app, this would come from a provider.
  // Naming changed from C1R1 to A1, B1, etc. ('C1R2' -> 'A2', 'C3R5' -> 'C5', 'C4R10' -> 'D10')
  final Set<String> _disabledLocations = {'A2', 'C5', 'D10'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beige,
      appBar: AppBar(
        title: const Text('Buffalo Shed A'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.8, // Adjust as needed
        ),
        itemCount: 300,
        itemBuilder: (context, index) {
          final column = index % 4;
          final row = index ~/ 4;

          final columnLetters = ['A', 'B', 'C', 'D'];
          final columnLetter = columnLetters[column];
          final location = '$columnLetter${row + 1}';

          final isEnabled = !_disabledLocations.contains(location);

          return InkWell(
            onTap: isEnabled
                ? () {
                    context.go('/buffalo-details/$location');
                  }
                : null,
            child: Card(
              elevation: 2.0,
              color: isEnabled ? Colors.white : Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/buf_icon.png", // Placeholder for buffalo icon
                      width: 45,
                      height: 45,
                      color: isEnabled ? AppTheme.primary : Colors.grey,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      location,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
