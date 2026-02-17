import 'dart:math';

import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_animals_provider.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class BulkMilkEntryScreen extends ConsumerStatefulWidget {
  BulkMilkEntryScreen({super.key});

  @override
  ConsumerState<BulkMilkEntryScreen> createState() =>
      _BulkMilkEntryScreenState();
}

class _BulkMilkEntryScreenState extends ConsumerState<BulkMilkEntryScreen> {
  DateTimeRange? _selectedDateRange;
  // If range is null, we assume today (or single selected day if I added single picker, but range can cover single).
  // I'll initialize range to Today-Today to mimic single.

  String _selectedTiming =
      'Morning'; // We can keep internal 'Morning' or localize it
  final Map<int, TextEditingController> _quantityControllers = {};
  final TextEditingController _totalShedController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isDistributedMode = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(start: now, end: now);
  }

  @override
  void dispose() {
    _quantityControllers.values.forEach((c) => c.dispose());
    _totalShedController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getSelectedDates() {
    if (_selectedDateRange == null) return [];
    final List<String> dates = [];
    DateTime cur = _selectedDateRange!.start;
    // Normalize to date only to avoid time issues loops
    cur = DateTime(cur.year, cur.month, cur.day);
    final end = DateTime(
      _selectedDateRange!.end.year,
      _selectedDateRange!.end.month,
      _selectedDateRange!.end.day,
    );

    while (!cur.isAfter(end)) {
      dates.add(DateFormat('yyyy-MM-dd').format(cur));
      cur = cur.add(Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(supervisorAnimalsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Milk Entry'.tr(ref),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        elevation: 0,
      ),
      body: animalsAsync.when(
        data: (animals) {
          if (animals.isEmpty) {
            return Center(child: Text('No alerts found'.tr(ref)));
          }
          final milkingAnimals = animals.where((a) {
            final type = a.animalType?.toLowerCase() ?? '';
            return !type.contains('calf');
          }).toList();

          // Filter Logic
          final query = _searchController.text.trim().toLowerCase();
          final filteredAnimals = milkingAnimals.where((a) {
            if (query.isEmpty) return true;
            final id = (a.animalId.isNotEmpty ? a.animalId : a.earTagId ?? '')
                .toLowerCase();
            final tag = (a.earTagId ?? '').toLowerCase();
            return id.contains(query) || tag.contains(query);
          }).toList();

          return Column(
            children: [
              _buildControlPanel(milkingAnimals.length),
              if (!_isDistributedMode)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Tag, RFID or ID'.tr(ref),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              Expanded(
                child: _isDistributedMode
                    ? _buildDistributedView(milkingAnimals.length)
                    : _buildDetailedList(filteredAnimals),
              ),
              _buildSubmitButton(milkingAnimals),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildControlPanel(int animalCount) {
    final dates = _getSelectedDates();
    final dateText = dates.length == 1
        ? DateFormat('dd MMM').format(_selectedDateRange!.start)
        : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)} (+${dates.length - 1} days)';

    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Date & Session Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      initialDateRange: _selectedDateRange,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null)
                      setState(() => _selectedDateRange = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Dates'.tr(ref),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTiming,
                  decoration: InputDecoration(
                    labelText: 'Session'.tr(ref),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Morning',
                      child: Text('Morning'.tr(ref)),
                    ),
                    DropdownMenuItem(
                      value: 'Evening',
                      child: Text('Evening'.tr(ref)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedTiming = v!),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Toggle Mode
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDistributedMode = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isDistributedMode
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Per Animal'.tr(ref),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_isDistributedMode
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDistributedMode = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isDistributedMode
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Shed Total'.tr(ref),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isDistributedMode
                              ? Colors.white
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface, // Fixed color logic
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isDistributedMode) ...[
            SizedBox(height: 12),
            Text(
              "Active Animals Participating: @count".trParams({
                'count': animalCount.toString(),
              }),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDistributedView(int count) {
    return SingleChildScrollView(
      // Allow scrolling if keyboard opens
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.hub, size: 48, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Enter Total Shed Production'.tr(ref),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "This will be distributed equally among @count animals.\nAvg: @avg L/animal"
                .trParams({
                  'count': count.toString(),
                  'avg': _calculateAvg(count),
                }),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _totalShedController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              suffixText: 'Liters'.tr(ref),
              border: OutlineInputBorder(),
              hintText: '0.0',
            ),
            onChanged: (v) => setState(() {}), // Refresh UI for avg calculation
          ),
        ],
      ),
    );
  }

  String _calculateAvg(int count) {
    if (count == 0) return '0';
    final total = double.tryParse(_totalShedController.text) ?? 0;
    return (total / count).toStringAsFixed(2);
  }

  Widget _buildDetailedList(List<InvestorAnimal> animals) {
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: animals.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final animal = animals[index];
        final id =
            animal.internalId ??
            0; // Fallback to 0 if internalId is null, verify backend
        final displayId = animal.animalId.isNotEmpty
            ? animal.animalId
            : animal.earTagId ?? 'N/A';
        final breed = animal.breed ?? 'Unknown';

        if (!_quantityControllers.containsKey(id)) {
          _quantityControllers[id] = TextEditingController();
        }

        return Card(
          elevation: 2,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    displayId.toString().substring(
                      0,
                      min(3, displayId.toString().length),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: @id'.trParams({'id': displayId}),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        breed,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _quantityControllers[id],
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Liters'.tr(ref),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
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

  Widget _buildSubmitButton(List<InvestorAnimal> animals) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: CustomActionButton(
        width: double.infinity,
        color: AppTheme.primary,
        onPressed: _isSubmitting ? null : () => _submit(animals),
        child: _isSubmitting
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Submit Entries'.tr(ref),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _submit(List<InvestorAnimal> animals) async {
    final dates = _getSelectedDates();
    if (dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one date'.tr(ref))),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final notifier = ref.read(supervisorDashboardProvider.notifier);

    // DISTRIBUTED MODE
    if (_isDistributedMode) {
      final total = _totalShedController.text.trim();
      if (total.isEmpty || (double.tryParse(total) ?? 0) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter valid total quantity'.tr(ref))),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      try {
        final res = await notifier.createDistributedMilkEntry(
          dates: dates,
          timing: _selectedTiming,
          totalQuantity: total,
        );
        if (res != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Success! @message'.trParams({
                  'message': res['message'] ?? 'Entries Created',
                }),
              ),
            ),
          );
          if (mounted) Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to submit.'.tr(ref))));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: @message'.trParams({'message': e.toString()}),
            ),
          ),
        );
      }
    }
    // PER ANIMAL MODE
    else {
      // Collect entries
      final perAnimalData = <int, String>{};
      for (final animal in animals) {
        final id = animal.internalId;
        if (id == null) continue; // Skip if no internal ID
        final txt = _quantityControllers[id]?.text.trim();
        if (txt != null && txt.isNotEmpty) {
          perAnimalData[id] = txt;
        }
      }

      if (perAnimalData.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No entries entered'.tr(ref))));
        setState(() => _isSubmitting = false);
        return;
      }

      int successCount = 0;
      int failCount = 0;

      // Loop Dates X Animals
      for (final date in dates) {
        for (final entry in perAnimalData.entries) {
          try {
            await notifier.createMilkEntry(
              timing: _selectedTiming,
              quantity: entry.value,
              animalId: entry.key,
              date: date,
            );
            successCount++;
          } catch (e) {
            failCount++;
            debugPrint('Failed: $e');
          }
        }
      }

      if (failCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully created @count entries'.trParams({
                'count': successCount.toString(),
              }),
            ),
          ),
        );
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Finished with @errors errors. @success success.'.trParams({
                'errors': failCount.toString(),
                'success': successCount.toString(),
              }),
            ),
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }
}
