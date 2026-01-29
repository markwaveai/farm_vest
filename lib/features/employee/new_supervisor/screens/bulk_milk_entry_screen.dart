import 'dart:math';

import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_animals_provider.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BulkMilkEntryScreen extends ConsumerStatefulWidget {
  const BulkMilkEntryScreen({super.key});

  @override
  ConsumerState<BulkMilkEntryScreen> createState() =>
      _BulkMilkEntryScreenState();
}

class _BulkMilkEntryScreenState extends ConsumerState<BulkMilkEntryScreen> {
  DateTimeRange? _selectedDateRange;
  // If range is null, we assume today (or single selected day if I added single picker, but range can cover single).
  // I'll initialize range to Today-Today to mimic single.

  String _selectedTiming = 'Morning';
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
      cur = cur.add(const Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(supervisorAnimalsProvider);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: const Text('Milk Entry', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: animalsAsync.when(
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(child: Text('No animals found'));
          }
          final milkingAnimals = animals.where((a) {
            final type =
                a['animal_details']?['animal_type']?.toString().toLowerCase() ??
                '';
            return !type.contains('calf');
          }).toList();

          // Filter Logic
          final query = _searchController.text.trim().toLowerCase();
          final filteredAnimals = milkingAnimals.where((a) {
            if (query.isEmpty) return true;
            final details = a['animal_details'];
            final id = (details['animal_id'] ?? details['ear_tag'] ?? '')
                .toString()
                .toLowerCase();
            final tag = (details['ear_tag'] ?? '').toString().toLowerCase();
            return id.contains(query) || tag.contains(query);
          }).toList();

          return Column(
            children: [
              _buildControlPanel(milkingAnimals.length),
              if (!_isDistributedMode)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by ID or Tag',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
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
        loading: () => const Center(child: CircularProgressIndicator()),
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
      color: Colors.white,
      padding: const EdgeInsets.all(16),
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
                    decoration: const InputDecoration(
                      labelText: 'Dates',
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
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTiming,
                  decoration: const InputDecoration(
                    labelText: 'Session',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: ['Morning', 'Evening']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTiming = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle Mode
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDistributedMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isDistributedMode
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Per Animal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_isDistributedMode
                              ? Colors.white
                              : Colors.black,
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isDistributedMode
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Shed Total',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isDistributedMode
                              ? Colors.white
                              : Colors.black, // Fixed color logic
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
            const SizedBox(height: 12),
            Text(
              "Active Animals Participating: $animalCount",
              style: const TextStyle(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.hub, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            "Enter Total Shed Production",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "This will be distributed equally among $count animals.\nAvg: ${_calculateAvg(count)} L/animal",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _totalShedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              suffixText: 'Liters',
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

  Widget _buildDetailedList(List<Map<String, dynamic>> animals) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: animals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final animal = animals[index];
        final details = animal['animal_details'];
        final id = details['id'] as int;
        final displayId = details['animal_id'] ?? details['ear_tag'] ?? 'N/A';
        final breed = details['breed_name'] ?? 'Unknown';

        if (!_quantityControllers.containsKey(id)) {
          _quantityControllers[id] = TextEditingController();
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID: $displayId",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        breed,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _quantityControllers[id],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Liters',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
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

  Widget _buildSubmitButton(List<Map<String, dynamic>> animals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
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
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit Entries',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _submit(List<Map<String, dynamic>> animals) async {
    final dates = _getSelectedDates();
    if (dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one date')),
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
          const SnackBar(content: Text('Please enter valid total quantity')),
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
              content: Text('Success! ${res['message'] ?? 'Entries Created'}'),
            ),
          );
          if (mounted) Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to submit.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
    // PER ANIMAL MODE
    else {
      // Collect entries
      final perAnimalData = <int, String>{};
      for (final animal in animals) {
        final id = animal['animal_details']['id'];
        final txt = _quantityControllers[id]?.text.trim();
        if (txt != null && txt.isNotEmpty) {
          perAnimalData[id] = txt;
        }
      }

      if (perAnimalData.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No entries entered')));
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
          SnackBar(content: Text('Successfully created $successCount entries')),
        );
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Finished with $failCount errors. $successCount success.',
            ),
          ),
        );
      }
    }

    setState(() => _isSubmitting = false);
  }
}
