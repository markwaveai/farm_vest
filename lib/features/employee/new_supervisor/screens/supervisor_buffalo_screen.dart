import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_animals_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SupervisorBuffaloScreen extends ConsumerStatefulWidget {
  const SupervisorBuffaloScreen({super.key});

  @override
  ConsumerState<SupervisorBuffaloScreen> createState() =>
      _SupervisorBuffaloScreenState();
}

class _SupervisorBuffaloScreenState
    extends ConsumerState<SupervisorBuffaloScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(animalSearchQueryProvider) == 'all'
          ? ''
          : ref.read(animalSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(searchedAnimalsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/supervisor-dashboard');
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/supervisor-dashboard'),
          ),
          title: const Text('Animals List'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Tag, RFID or ID',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      final value = _searchController.text.trim();
                      ref.read(animalSearchQueryProvider.notifier).state =
                          value.isEmpty ? 'all' : value;
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(animalSearchQueryProvider.notifier).state =
                          'all';
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                onSubmitted: (value) {
                  ref.read(animalSearchQueryProvider.notifier).state =
                      value.isEmpty ? 'all' : value;
                },
                onChanged: (value) {
                  ref.read(animalSearchQueryProvider.notifier).state =
                      value.isEmpty ? 'all' : value;
                },
              ),
            ),
          ),
        ),
        body: animalsAsync.when(
          data: (animals) {
            final buffaloes = animals.where((a) {
              final type = a.animalType?.toLowerCase() ?? '';
              return !type.contains('calf');
            }).toList();

            return _buildAnimalList(buffaloes, 'No animals found');
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildAnimalList(List<InvestorAnimal> animals, String emptyMessage) {
    if (animals.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.pets, color: Theme.of(context).primaryColor),
            ),
            title: Text(
              animal.rfid ?? 'Unknown RFID',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Tag: ${animal.earTagId ?? 'N/A'} | Shed: ${animal.shedName ?? 'N/A'}',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ID', animal.animalId),
                    _buildDetailRow('Breed', animal.breed),
                    _buildDetailRow('Age', '${animal.age ?? 'N/A'} months'),
                    _buildDetailRow('Type', animal.animalType),
                    _buildDetailRow('Health', animal.healthStatus),
                    _buildDetailRow('Status', animal.status),
                    if (animal.onboardedAt != null)
                      _buildDetailRow(
                        'Onboarded',
                        DateFormat('dd MMM yyyy').format(animal.onboardedAt!),
                      ),
                    const Divider(),
                    _buildDetailRow('Farm', animal.farmName),
                    _buildDetailRow('Investor', animal.investorName),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
