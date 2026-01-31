import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import '../providers/admin_provider.dart';

class InvestorAnimalsScreen extends ConsumerStatefulWidget {
  final int investorId;
  final String investorName;

  const InvestorAnimalsScreen({
    super.key,
    required this.investorId,
    required this.investorName,
  });

  @override
  ConsumerState<InvestorAnimalsScreen> createState() =>
      _InvestorAnimalsScreenState();
}

class _InvestorAnimalsScreenState extends ConsumerState<InvestorAnimalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(adminProvider.notifier)
          .fetchInvestorAnimals(widget.investorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final animals = adminState.investorAnimals;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text('${widget.investorName}\'s Buffaloes'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : animals.isEmpty
          ? const Center(child: Text('No animals found for this investor'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                return _buildAnimalCard(animal);
              },
            ),
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showCalvesDialog(animal['animal_id']),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.pets, color: Colors.grey, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RFID: ${animal['rfid'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.agriculture,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${animal['farm_name']} (${animal['farm_location']})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      const SizedBox(height: 4),
                      if (animal['shed_name'] != null ||
                          animal['shed_id'] != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.home_work_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Shed: ${animal['shed_name'] ?? 'N/A'} (ID: ${animal['shed_id'] ?? 'N/A'})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Age: ${animal['age_months'] ?? animal['age'] ?? 0} Months',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (animal['onboarded_at'] != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Onboarded: ${DateFormat('dd MMM yyyy').format(DateTime.parse(animal['onboarded_at']))}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getHealthStatusColor(
                            animal['health_status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          animal['health_status']?.toUpperCase() ?? 'UNKNOWN',
                          style: TextStyle(
                            color: _getHealthStatusColor(
                              animal['health_status'],
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCalvesDialog(String? animalId) async {
    if (animalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Animal ID available for this buffalo'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Calf Details'),
          content: FutureBuilder<List<InvestorAnimal>>(
            future: _fetchCalves(animalId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No calves found for this animal.');
              }

              final calves = snapshot.data!;
              return SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: calves.length,
                  separatorBuilder: (c, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final calf = calves[index];

                    final calfRfid = calf.rfid ?? 'N/A';
                    final calfId = calf.animalId;
                    final calfAge = calf.age ?? 0;
                    final calfHealth = calf.healthStatus;
                    final calfType = calf.animalType ?? 'Calf';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      title: Text('RFID: $calfRfid'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: $calfId'),
                          Text('Age: $calfAge Months | Type: $calfType'),
                          if (calf.onboardedAt != null)
                            Text(
                              'Onboarded: ${DateFormat('dd MMM yyyy').format(calf.onboardedAt!)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getHealthStatusColor(
                            calfHealth,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          calfHealth,
                          style: TextStyle(
                            color: _getHealthStatusColor(calfHealth),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<List<InvestorAnimal>> _fetchCalves(String animalId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    final response = await AnimalApiServices.getCalves(
      token: token,
      animalId: animalId,
    );
    return response.data;
  }

  Color _getHealthStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'sick':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
