import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
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
                    'Animal ID: ${animal['animal_id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RFID: ${animal['rfid'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Age: ${animal['age_months'] ?? 0} Months',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                        color: _getHealthStatusColor(animal['health_status']),
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
    );
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
