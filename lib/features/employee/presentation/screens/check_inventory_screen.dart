import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class CheckInventoryScreen extends ConsumerWidget {
  CheckInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = [
      {
        'name': 'Antibiotics (Bottle)',
        'quantity': '12',
        'status': 'High Stock',
      },
      {'name': 'Bandages', 'quantity': '8 Rolls', 'status': 'Low Stock'},
      {
        'name': 'Painkillers',
        'quantity': '20 Strips',
        'status': 'Medium Stock',
      },
      {'name': 'Syringes', 'quantity': '50 Units', 'status': 'High Stock'},
      {'name': 'Disinfectant', 'quantity': '2 Bottles', 'status': 'Critical'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory'.tr(ref),
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.dark),
      ),
      backgroundColor: Colors.grey[50],
      body: ListView.builder(
        padding: EdgeInsets.all(AppConstants.spacingM),
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final item = inventory[index];
          final status = item['status']!;
          Color statusColor;
          if (status == 'Critical' || status == 'Low Stock') {
            statusColor = AppTheme.errorRed;
          } else if (status == 'Medium Stock') {
            statusColor = AppTheme.warningOrange;
          } else {
            statusColor = Colors.green;
          }

          return Padding(
            padding: EdgeInsets.only(bottom: AppConstants.spacingS),
            child: CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2, color: Colors.blue),
                ),
                title: Text(
                  item['name']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text('Quantity: ${item['quantity']}'),
                trailing: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
