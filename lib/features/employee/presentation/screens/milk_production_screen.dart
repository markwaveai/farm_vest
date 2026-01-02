import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';

class MilkProductionEntry {
  final DateTime date;
  final double morningLitres;
  final double eveningLitres;
  final double totalLitres;

  MilkProductionEntry({
    required this.date,
    required this.morningLitres,
    required this.eveningLitres,
  }) : totalLitres = morningLitres + eveningLitres;
}

class MilkProductionScreen extends StatefulWidget {
  const MilkProductionScreen({super.key});

  @override
  State<MilkProductionScreen> createState() => _MilkProductionScreenState();
}

class _MilkProductionScreenState extends State<MilkProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _morningController = TextEditingController();
  final _eveningController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<MilkProductionEntry> _pastEntries = [];

  @override
  void initState() {
    super.initState();
    _generatePastEntries();
  }

  @override
  void dispose() {
    _morningController.dispose();
    _eveningController.dispose();
    super.dispose();
  }

  void _generatePastEntries() {
    _pastEntries = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: index + 1));
      return MilkProductionEntry(
        date: date,
        morningLitres: 80 + (index * 2.5),
        eveningLitres: 75 + (index * 2.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Production Entry'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationHelper.safePopOrNavigate(
            context,
            fallbackRoute: '/supervisor-dashboard',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Entry',
                        style: AppTheme.headingMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Date Picker
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.mediumGrey),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusM,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: AppConstants.spacingM),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDate),
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: AppTheme.mediumGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Morning Litres
                      TextFormField(
                        controller: _morningController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Morning Litres',
                          prefixIcon: Icon(Icons.wb_sunny),
                          suffixText: 'L',
                          hintText: 'Enter morning milk production',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter morning litres';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),

                      // Evening Litres
                      TextFormField(
                        controller: _eveningController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Evening Litres',
                          prefixIcon: Icon(Icons.nights_stay),
                          suffixText: 'L',
                          hintText: 'Enter evening milk production',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter evening litres';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Total Display
                      if (_morningController.text.isNotEmpty &&
                          _eveningController.text.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppConstants.spacingM),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusM,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Production:',
                                style: AppTheme.bodyMedium,
                              ),
                              Text(
                                '${_calculateTotal()}L',
                                style: AppTheme.headingSmall.copyWith(
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppConstants.spacingL),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitEntry,
                          child: const Text('Submit Entry'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Past Entries
            const Text('Recent Entries', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),

            // Summary Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Today\'s Total',
                    '163L',
                    Icons.today,
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildStatCard(
                    'Weekly Avg',
                    '158L',
                    Icons.bar_chart,
                    AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildStatCard(
                    'Monthly Total',
                    '4,740L',
                    Icons.calendar_month,
                    AppTheme.darkSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),

            // Past Entries List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pastEntries.length,
              itemBuilder: (context, index) {
                final entry = _pastEntries[index];
                return _buildEntryCard(entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppConstants.iconM),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: AppTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(MilkProductionEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            // Date
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(entry.date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(entry.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),

            // Production Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE').format(entry.date),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Row(
                    children: [
                      const Icon(
                        Icons.wb_sunny,
                        size: AppConstants.iconS,
                        color: AppTheme.warningOrange,
                      ),
                      const SizedBox(width: AppConstants.spacingXS),
                      Text(
                        '${entry.morningLitres}L',
                        style: AppTheme.bodySmall,
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      const Icon(
                        Icons.nights_stay,
                        size: AppConstants.iconS,
                        color: AppTheme.darkGrey,
                      ),
                      const SizedBox(width: AppConstants.spacingXS),
                      Text(
                        '${entry.eveningLitres}L',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Total
            Column(
              children: [
                Text(
                  '${entry.totalLitres}L',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
                const Text('Total', style: AppTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double _calculateTotal() {
    final morning = double.tryParse(_morningController.text) ?? 0;
    final evening = double.tryParse(_eveningController.text) ?? 0;
    return morning + evening;
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      final morning = double.parse(_morningController.text);
      final evening = double.parse(_eveningController.text);

      // Add to past entries
      setState(() {
        _pastEntries.insert(
          0,
          MilkProductionEntry(
            date: _selectedDate,
            morningLitres: morning,
            eveningLitres: evening,
          ),
        );

        // Clear form
        _morningController.clear();
        _eveningController.clear();
        _selectedDate = DateTime.now();
      });

      ToastUtils.showSuccess(
        context,
        'Milk production entry submitted successfully!',
      );
    }
  }
}
