import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_animals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupervisorBuffaloScreen extends ConsumerStatefulWidget {
  const SupervisorBuffaloScreen({super.key});

  @override
  ConsumerState<SupervisorBuffaloScreen> createState() =>
      _SupervisorBuffaloScreenState();
}

class _SupervisorBuffaloScreenState
    extends ConsumerState<SupervisorBuffaloScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController(
      text: ref.read(animalSearchQueryProvider) == 'all'
          ? ''
          : ref.read(animalSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(searchedAnimalsProvider);

    return Scaffold(
      backgroundColor: AppTheme.grey,
      appBar: AppBar(
        title: const Text('Animals List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Tag, RFID or ID',
                    prefixIcon: const Icon(Icons.search),
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
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) {
                    ref.read(animalSearchQueryProvider.notifier).state =
                        value.isEmpty ? 'all' : value;
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Buffaloes'),
                  Tab(text: 'Calves'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: animalsAsync.when(
        data: (animals) {
          final buffaloes = animals.where((a) {
            final type =
                a['animal_details']?['animal_type']?.toString().toLowerCase() ??
                '';
            return !type.contains('calf');
          }).toList();

          final calves = animals.where((a) {
            final type =
                a['animal_details']?['animal_type']?.toString().toLowerCase() ??
                '';
            return type.contains('calf');
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAnimalList(buffaloes, 'No buffaloes found'),
              _buildAnimalList(calves, 'No calves found'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAnimalList(List<dynamic> animals, String emptyMessage) {
    if (animals.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];
        final details = animal['animal_details'] ?? {};
        final shed = animal['shed_details'] ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: const Icon(Icons.pets, color: AppTheme.primary),
            ),
            title: Text(
              details['animal_id'] ?? 'Unknown ID',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Tag: ${details['ear_tag'] ?? 'N/A'} | Shed: ${shed['shed_name'] ?? 'N/A'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('RFID', details['rfid_tag_number']),
                    _buildDetailRow('Breed', details['breed_name']),
                    _buildDetailRow(
                      'Age',
                      '${details['age_months'] ?? 'N/A'} months',
                    ),
                    _buildDetailRow('Type', details['animal_type']),
                    _buildDetailRow('Health', details['health_status']),
                    _buildDetailRow('Status', details['status']),
                    const Divider(),
                    _buildDetailRow(
                      'Farm',
                      animal['farm_details']?['farm_name'],
                    ),
                    _buildDetailRow(
                      'Investor',
                      animal['investor_details']?['full_name'],
                    ),
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
            style: const TextStyle(
              color: Colors.grey,
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
