import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

enum RecordType { ai, vaccination, treatment, fever, quarantine, recovery }

class HealthRecord {
  final DateTime date;
  final RecordType type;
  final String event;
  final String doctorName;
  final String? notes;

  HealthRecord({
    required this.date,
    required this.type,
    required this.event,
    required this.doctorName,
    this.notes,
  });
}

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HealthRecord> _healthRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _generateHealthRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateHealthRecords() {
    _healthRecords = [
      HealthRecord(
        date: DateTime(2024, 12, 1),
        type: RecordType.vaccination,
        event: 'FMD Vaccination',
        doctorName: 'Dr. Sharma',
        notes: 'Annual vaccination completed successfully',
      ),
      HealthRecord(
        date: DateTime(2024, 11, 28),
        type: RecordType.treatment,
        event: 'Antibiotic Treatment',
        doctorName: 'Dr. Patel',
        notes: 'Treatment for minor infection',
      ),
      HealthRecord(
        date: DateTime(2024, 11, 25),
        type: RecordType.fever,
        event: 'Fever Detected',
        doctorName: 'Assistant Kumar',
        notes: 'Temperature: 103°F, immediate treatment started',
      ),
      HealthRecord(
        date: DateTime(2024, 11, 20),
        type: RecordType.ai,
        event: 'Artificial Insemination',
        doctorName: 'Dr. Verma',
        notes: 'AI procedure completed, monitoring required',
      ),
      HealthRecord(
        date: DateTime(2024, 11, 15),
        type: RecordType.recovery,
        event: 'Full Recovery',
        doctorName: 'Dr. Patel',
        notes: 'Recovered from previous illness',
      ),
      HealthRecord(
        date: DateTime(2024, 10, 10),
        type: RecordType.quarantine,
        event: 'Quarantine Started',
        doctorName: 'Dr. Sharma',
        notes: 'Precautionary quarantine for 7 days',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/unit-details',
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'AI'),
            Tab(text: 'Vaccines'),
            Tab(text: 'Treatments'),
            Tab(text: 'Fever'),
            Tab(text: 'Quarantine'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordsList(_healthRecords),
          _buildRecordsList(
            _healthRecords.where((r) => r.type == RecordType.ai).toList(),
          ),
          _buildRecordsList(
            _healthRecords
                .where((r) => r.type == RecordType.vaccination)
                .toList(),
          ),
          _buildRecordsList(
            _healthRecords
                .where((r) => r.type == RecordType.treatment)
                .toList(),
          ),
          _buildRecordsList(
            _healthRecords.where((r) => r.type == RecordType.fever).toList(),
          ),
          _buildRecordsList(
            _healthRecords
                .where((r) => r.type == RecordType.quarantine)
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<HealthRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: AppTheme.mediumGrey,
            ),
            SizedBox(height: AppConstants.spacingM),
            Text('No records found', style: AppTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(HealthRecord record) {
    final recordInfo = _getRecordInfo(record.type);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: recordInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    recordInfo.icon,
                    color: recordInfo.color,
                    size: AppConstants.iconM,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.event,
                        style: AppTheme.headingSmall.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(record.date),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: recordInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    recordInfo.label,
                    style: TextStyle(
                      color: recordInfo.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Doctor info
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: AppConstants.iconS,
                  color: AppTheme.mediumGrey,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  record.doctorName,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Notes
            if (record.notes != null) ...[
              const SizedBox(height: AppConstants.spacingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(record.notes!, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  RecordInfo _getRecordInfo(RecordType type) {
    switch (type) {
      case RecordType.ai:
        return RecordInfo(
          label: 'AI',
          icon: Icons.favorite,
          color: Colors.pink,
        );
      case RecordType.vaccination:
        return RecordInfo(
          label: 'Vaccine',
          icon: Icons.vaccines,
          color: AppTheme.primary,
        );
      case RecordType.treatment:
        return RecordInfo(
          label: 'Treatment',
          icon: Icons.medication,
          color: Colors.blue,
        );
      case RecordType.fever:
        return RecordInfo(
          label: 'Fever',
          icon: Icons.thermostat,
          color: AppTheme.errorRed,
        );
      case RecordType.quarantine:
        return RecordInfo(
          label: 'Quarantine',
          icon: Icons.warning,
          color: AppTheme.warningOrange,
        );
      case RecordType.recovery:
        return RecordInfo(
          label: 'Recovery',
          icon: Icons.check_circle,
          color: AppTheme.successGreen,
        );
    }
  }
}

class RecordInfo {
  final String label;
  final IconData icon;
  final Color color;

  RecordInfo({required this.label, required this.icon, required this.color});
}
