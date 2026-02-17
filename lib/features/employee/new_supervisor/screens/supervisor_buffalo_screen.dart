import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_animals_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class SupervisorBuffaloScreen extends ConsumerStatefulWidget {
  SupervisorBuffaloScreen({super.key});

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
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.go('/supervisor-dashboard'),
          ),
          title: Text('Animals List'.tr(ref)),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(70),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Tag, RFID or ID'.tr(ref),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      final value = _searchController.text.trim();
                      ref.read(animalSearchQueryProvider.notifier).state =
                          value.isEmpty ? 'all' : value;
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(animalSearchQueryProvider.notifier).state =
                          'all';
                    },
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
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

            return _buildAnimalList(buffaloes, 'No alerts found'.tr(ref));
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'Error: @message'.trParams({'message': err.toString()}),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalList(List<InvestorAnimal> animals, String emptyMessage) {
    if (animals.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.pets, color: Theme.of(context).primaryColor),
            ),
            title: Text(
              animal.rfid ?? 'Unknown RFID'.tr(ref),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Tag: @tag | Shed: @shed'.trParams({
                'tag': animal.earTagId ?? 'N/A',
                'shed': animal.shedName ?? 'N/A',
              }),
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ID'.tr(ref), animal.animalId),
                    _buildDetailRow('Breed'.tr(ref), animal.breed),
                    _buildDetailRow(
                      'Age'.tr(ref),
                      '@count months'.trParams({
                        'count': animal.age?.toString() ?? 'N/A',
                      }),
                    ),
                    _buildDetailRow('Type'.tr(ref), animal.animalType),
                    _buildDetailRow('Health'.tr(ref), animal.healthStatus),
                    _buildDetailRow('Status'.tr(ref), animal.status),
                    if (animal.onboardedAt != null)
                      _buildDetailRow(
                        'Onboarded'.tr(ref),
                        DateFormat('dd MMM yyyy').format(animal.onboardedAt!),
                      ),
                    Divider(),
                    _buildDetailRow('Farm'.tr(ref), animal.farmName),
                    _buildDetailRow('Investor'.tr(ref), animal.investorName),
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
      padding: EdgeInsets.symmetric(vertical: 4.0),
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
