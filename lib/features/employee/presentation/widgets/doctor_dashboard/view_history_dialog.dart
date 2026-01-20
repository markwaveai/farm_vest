import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:farm_vest/core/widgets/custom_dialog.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ViewHistoryDialog extends StatelessWidget {
  final String buffaloId;

  const ViewHistoryDialog({super.key, required this.buffaloId});

  @override
  Widget build(BuildContext context) {
    // Mock data for history
    final historyItems = [
      {
        'date': 'Yesterday, 4:15 PM',
        'issue': 'Limping on left hind leg',
        'status': 'Treated',
      },
      {
        'date': '12 Jan, 9:30 AM',
        'issue': 'Routine Checkup',
        'status': 'Healthy',
      },
      {
        'date': '20 Dec 2024, 2:00 PM',
        'issue': 'Mild Fever',
        'status': 'Resolved',
      },
    ];

    return CustomDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History for $buffaloId',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.dark,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: historyItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['date']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item['status'] == 'Healthy'
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['status']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item['status'] == 'Healthy'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['issue']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomActionButton(
              child: const Text('Close', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
