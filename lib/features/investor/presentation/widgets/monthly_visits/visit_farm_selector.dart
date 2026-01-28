import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/investor/data/models/visit_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitFarmSelector extends StatelessWidget {
  final AsyncValue<List<InvestorFarm>> farmsAsync;
  final InvestorFarm? selectedFarm;
  final ValueChanged<InvestorFarm?> onFarmSelected;
  final ThemeData theme;

  const VisitFarmSelector({
    super.key,
    required this.farmsAsync,
    required this.selectedFarm,
    required this.onFarmSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Farm",
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          farmsAsync.when(
            data: (farms) {
              if (farms.isEmpty) {
                return const Text("No farms found assigned to you.");
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<InvestorFarm>(
                    value: selectedFarm,
                    isExpanded: true,
                    hint: const Text("Choose a farm"),
                    items: farms.map((farm) {
                      return DropdownMenuItem(
                        value: farm,
                        child: Text(
                          "${farm.farmName} (${farm.location}) - ${farm.investorBuffaloesCount} Animals",
                          style: AppTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: onFarmSelected,
                  ),
                ),
              );
            },
            error: (e, s) => Text("Failed to load farms: $e"),
            loading: () => const LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
