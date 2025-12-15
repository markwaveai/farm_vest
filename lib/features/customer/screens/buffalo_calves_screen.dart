import 'package:flutter/material.dart';
import '../models/unit_response.dart';
import '../widgets/buffalo_card.dart';

class BuffaloCalvesScreen extends StatelessWidget {
  final List<Animal> calves;
  final String parentId;

  const BuffaloCalvesScreen({
    super.key,
    required this.calves,
    required this.parentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calves of $parentId')),
      body: calves.isEmpty
          ? const Center(
              child: Text(
                'No calves found for this buffalo.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: calves.length,
              itemBuilder: (context, index) {
                final calf = calves[index];
                return BuffaloCard(
                  farmName: 'FarmVest Unit', // Using default/inherited values
                  location: 'Hyderabad',
                  id: calf.breedId ?? 'Unknown ID',
                  healthStatus: calf.status ?? 'Healthy',
                  lastMilking: 'N/A',
                  age: calf.ageYears != null ? '${calf.ageYears} years' : 'N/A',
                  breed: calf.breedId ?? 'Unknown Breed',
                  isGridView: true,
                  onTap: () {
                    // Navigate to details if needed, or do nothing as requested
                    // context.go('/unit-details', extra: {'buffalo': calf});
                  },
                  // No calves for calves, so onCalvesTap is null
                );
              },
            ),
    );
  }
}
