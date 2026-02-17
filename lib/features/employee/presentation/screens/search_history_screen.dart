import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_textfield.dart';

import 'package:farm_vest/core/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class SearchHistoryScreen extends ConsumerStatefulWidget {
  SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends ConsumerState<SearchHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data
  final List<Map<String, String>> _allRecords = [
    {'id': 'BUF-089', 'date': 'Today, 09:30 AM', 'issue': 'High Fever'},
    {'id': 'BUF-142', 'date': 'Yesterday, 04:15 PM', 'issue': 'Limping'},
    {'id': 'BUF-203', 'date': '15 Jan, 2:00 PM', 'issue': 'Routine Checkup'},
    {'id': 'BUF-405', 'date': '12 Jan, 10:00 AM', 'issue': 'Vaccination'},
  ];

  List<Map<String, String>> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _filteredRecords = _allRecords;
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _allRecords;
      } else {
        _filteredRecords = _allRecords
            .where(
              (record) =>
                  record['id']!.toLowerCase().contains(query.toLowerCase()) ||
                  record['issue']!.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search History'.tr(ref),
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.dark),
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            CustomTextField(
              hint: 'Search by Buffalo ID or Issue...',
              controller: _searchController,
              onChanged: _filterRecords,
              prefixIcon: Icon(Icons.search),
            ),
            SizedBox(height: AppConstants.spacingM),
            Expanded(
              child: _filteredRecords.isEmpty
                  ? Center(
                      child: Text(
                        'No records found'.tr(ref),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = _filteredRecords[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: AppConstants.spacingS,
                          ),
                          child: CustomCard(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Text(
                                record['id']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.dark,
                                ),
                              ),
                              subtitle: Text(
                                '${record['issue']} • ${record['date']}',
                              ),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Navigate to detail view
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
