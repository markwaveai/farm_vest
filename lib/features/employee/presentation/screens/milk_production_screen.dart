import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/navigation_helper.dart';

// 1. Updated model to be more flexible
class MilkProductionEntry {
  final DateTime date;
  final String timing; // Morning, Afternoon, Evening
  final double litres;

  MilkProductionEntry({
    required this.date,
    required this.timing,
    required this.litres,
  });
}

class MilkProductionScreen extends StatefulWidget {
  final bool hideAppBar;

  const MilkProductionScreen({super.key, this.hideAppBar = false});

  @override
  State<MilkProductionScreen> createState() => _MilkProductionScreenState();
}

class _MilkProductionScreenState extends State<MilkProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litresController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedTiming = 'Morning'; // Default timing

  // Using a map to store entries by date for easier lookup
  Map<String, List<MilkProductionEntry>> _pastEntries = {};

  @override
  void initState() {
    super.initState();
    _generatePastEntries();
    // Add listener to recalculate total when text changes
    _litresController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _litresController.dispose();
    super.dispose();
  }

  void _generatePastEntries() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _pastEntries = {
      today: [
        MilkProductionEntry(
          date: DateTime.now(),
          timing: 'Morning',
          litres: 85,
        ),
        MilkProductionEntry(
          date: DateTime.now(),
          timing: 'Evening',
          litres: 78,
        ),
      ],
      DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 1))): [
        MilkProductionEntry(
          date: DateTime.now().subtract(const Duration(days: 1)),
          timing: 'Morning',
          litres: 82,
        ),
      ],
    };
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final entriesForSelectedDate = _pastEntries[dateKey] ?? [];

    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              title: const Text('Milk Production Entry'),
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
                      _buildDatePicker(),
                      const SizedBox(height: AppConstants.spacingL),
                      // 2. Refactored to a single entry form with timings
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _litresController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Litres',
                                suffixText: 'L',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter litres';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingM),
                          // 3. The new timings dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedTiming,
                              decoration: const InputDecoration(
                                labelText: 'Timing',
                              ),
                              items: ['Morning', 'Afternoon', 'Evening']
                                  .map(
                                    (timing) => DropdownMenuItem(
                                      value: timing,
                                      child: Text(timing),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedTiming = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingL),
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
            const Text('Today\'s Entries', style: AppTheme.headingMedium),
            const SizedBox(height: AppConstants.spacingM),
            // 4. Updated list to show flexible entries
            entriesForSelectedDate.isEmpty
                ? const Center(child: Text('No entries for this date.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entriesForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final entry = entriesForSelectedDate[index];
                      return _buildEntryCard(entry);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingM),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.mediumGrey),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primary),
            const SizedBox(width: AppConstants.spacingM),
            Text(
              DateFormat('MMM dd, yyyy').format(_selectedDate),
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: AppTheme.mediumGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(MilkProductionEntry entry) {
    IconData icon;
    Color color;
    switch (entry.timing) {
      case 'Morning':
        icon = Icons.wb_sunny;
        color = AppTheme.warningOrange;
        break;
      case 'Afternoon':
        icon = Icons.brightness_5;
        color = AppTheme.secondary;
        break;
      default:
        icon = Icons.nights_stay;
        color = AppTheme.darkGrey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon, color: color)),
        title: Text('${entry.litres} Litres', style: AppTheme.headingSmall),
        subtitle: Text(entry.timing),
        trailing: Text(DateFormat('hh:mm a').format(entry.date)),
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
      setState(() => _selectedDate = picked);
    }
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      final litres = double.parse(_litresController.text);
      final newEntry = MilkProductionEntry(
        date: _selectedDate,
        timing: _selectedTiming,
        litres: litres,
      );

      final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

      setState(() {
        if (_pastEntries.containsKey(dateKey)) {
          _pastEntries[dateKey]!.add(newEntry);
        } else {
          _pastEntries[dateKey] = [newEntry];
        }

        _litresController.clear();
      });

      ToastUtils.showSuccess(
        context,
        'Entry for $_selectedTiming submitted successfully!',
      );
    }
  }
}
