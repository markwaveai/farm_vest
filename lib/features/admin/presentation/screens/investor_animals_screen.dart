import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/core/utils/svg_utils.dart';
import 'package:flutter_svg/svg.dart';
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

  Widget _buildAnimalCard(InvestorAnimal animal) {
    final statusColor = _getHealthStatusColor(animal.healthStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showCalvesDialog(animal.animalId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image/Icon Box
                Container(
                  width: 80, // Increased specific size for image visibility
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.1),
                    ),
                    image: (animal.images.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(animal.images.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: animal.images.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.pets_rounded,
                            color: AppTheme.primary,
                            size: 28,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'RFID: ${animal.rfid ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              animal.healthStatus.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      _buildInfoRowIcon(
                        Icons.location_on_rounded,
                        '${animal.farmName ?? ''} (${animal.farmLocation ?? ''})',
                      ),

                      if (animal.shedName != null) ...[
                        const SizedBox(height: 4),
                        _buildInfoRowIcon(
                          Icons.warehouse_rounded,
                          'Shed: ${animal.shedName}',
                        ),
                      ],

                      const SizedBox(height: 4),
                      _buildInfoRowIcon(
                        Icons.cake_rounded,
                        'Age: ${animal.age ?? 0} Months',
                      ),

                      if (animal.onboardedAt != null) ...[
                        const SizedBox(height: 4),
                        _buildInfoRowIcon(
                          Icons.calendar_today_rounded,
                          'Onboarded: ${DateFormat('dd MMM yyyy').format(animal.onboardedAt!)}',
                        ),
                      ],
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

  Widget _buildInfoRowIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.string(
                        SvgUtils.calvesSvg,
                        height: 26,
                        width: 26,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Colors.red,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Calf Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Flexible(
                  child: FutureBuilder<List<InvestorAnimal>>(
                    future: _fetchCalves(animalId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No calves found for this animal.',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        );
                      }

                      final calves = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: calves.length,
                        separatorBuilder: (c, i) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final calf = calves[index];
                          final calfHealth = calf.healthStatus;
                          final statusColor = _getHealthStatusColor(calfHealth);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        60, // Slightly larger for better visibility
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      image: (calf.images.isNotEmpty)
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                calf.images.first,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: calf.images.isEmpty
                                        ? const Center(
                                            child: Icon(
                                              Icons.pets_rounded,
                                              color: Colors.blue,
                                              size: 24,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'RFID: ${calf.rfid ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                calfHealth.toUpperCase(),
                                                style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        _buildCalfDetailRow(
                                          Icons.cake_rounded,
                                          'Age: ${calf.age ?? 0} Months',
                                        ),
                                        const SizedBox(height: 4),
                                        _buildCalfDetailRow(
                                          Icons.category_rounded,
                                          'Type: ${calf.animalType ?? 'Calf'}',
                                        ),
                                        if (calf.onboardedAt != null) ...[
                                          const SizedBox(height: 4),
                                          _buildCalfDetailRow(
                                            Icons.calendar_today_rounded,
                                            'Onboarded: ${DateFormat('dd MMM yyyy').format(calf.onboardedAt!)}',
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalfDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        return const Color(0xFF4CAF50); // Material Green 500
      case 'sick':
        return Colors.orangeAccent;
      case 'critical':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
