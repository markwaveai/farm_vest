import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_tickets_provider.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/filter_chip.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/alert_cards.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:farm_vest/core/widgets/custom_button.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_animals_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';

class SupervisorStatsView extends ConsumerWidget {
  const SupervisorStatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(supervisorDashboardProvider);
    final stats = dashboardState.stats;

    if (dashboardState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            context,
            'Total Animals',
            stats.totalAnimals,
            Icons.pets,
            AppTheme.primary,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'Daily Milk Content',
            stats.milkToday,
            Icons.water_drop,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'Active Health Issues',
            stats.activeIssues,
            Icons.warning,
            AppTheme.primary,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            'Pending Transfers',
            stats.transfers,
            Icons.move_down,
            AppTheme.slate,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SupervisorAlertsView extends ConsumerWidget {
  const SupervisorAlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(filteredSupervisorTicketsProvider);
    final currentFilter = ref.watch(ticketStatusFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Alerts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChipWidget(
                  label: 'All',
                  selected: currentFilter == 'all',
                  onTap: () =>
                      ref.read(ticketStatusFilterProvider.notifier).state =
                          'all',
                ),
                FilterChipWidget(
                  label: 'Critical',
                  selected: currentFilter == 'Critical',
                  onTap: () =>
                      ref.read(ticketStatusFilterProvider.notifier).state =
                          'Critical',
                ),
                FilterChipWidget(
                  label: 'Today',
                  selected: currentFilter == 'Today',
                  onTap: () =>
                      ref.read(ticketStatusFilterProvider.notifier).state =
                          'Today',
                ),
                FilterChipWidget(
                  label: 'Completed',
                  selected: currentFilter == 'Completed',
                  onTap: () =>
                      ref.read(ticketStatusFilterProvider.notifier).state =
                          'Completed',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Active Alerts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ticketsAsync.when(
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const Center(child: Text('No alerts found'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 60),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    final type = ticket.ticketType;
                    final status = ticket.status;
                    final priority = ticket.priority ?? 'MEDIUM';
                    final createdAt =
                        ticket.createdAt?.toLocal() ?? DateTime.now();

                    Color headerColor = AppTheme.primary;
                    if (priority == 'CRITICAL' || priority == 'HIGH')
                      headerColor = Colors.red;
                    if (type == TicketType.health.value)
                      headerColor = AppTheme.primary;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: AlertCardDivided(
                        title: '$type Ticket #${ticket.id}',
                        subtitle: ticket.description,
                        time:
                            '${DateTime.now().difference(createdAt).inMinutes} min ago',
                        ids: 'Animal ID: ${ticket.animalId ?? 'N/A'}',
                        actionText: status == TicketStatus.pending.value
                            ? 'Track Progress'
                            : 'View Details',
                        headerColor: headerColor,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class BulkMilkEntryView extends ConsumerStatefulWidget {
  const BulkMilkEntryView({super.key});

  @override
  ConsumerState<BulkMilkEntryView> createState() => _BulkMilkEntryViewState();
}

class _BulkMilkEntryViewState extends ConsumerState<BulkMilkEntryView> {
  DateTimeRange? _selectedDateRange;
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

    return animalsAsync.when(
      data: (animals) {
        if (animals.isEmpty) {
          return const Center(child: Text('No animals found'));
        }
        final milkingAnimals = animals.where((a) {
          final type = a.animalType?.toLowerCase() ?? '';
          return !type.contains('calf');
        }).toList();

        final query = _searchController.text.trim().toLowerCase();
        final filteredAnimals = milkingAnimals.where((a) {
          if (query.isEmpty) return true;
          final id = (a.animalId.isNotEmpty ? a.animalId : a.earTagId ?? '')
              .toLowerCase();
          final tag = (a.earTagId ?? '').toLowerCase();
          return id.contains(query) || tag.contains(query);
        }).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildControlPanel(milkingAnimals.length),
              _isDistributedMode
                  ? _buildDistributedView(milkingAnimals.length)
                  : _buildDetailedList(filteredAnimals),
              const SizedBox(height: 24),
              _buildSubmitButton(milkingAnimals),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildControlPanel(int animalCount) {
    final dates = _getSelectedDates();
    final dateText = dates.length == 1
        ? DateFormat('dd MMM').format(_selectedDateRange!.start)
        : '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)} (+${dates.length - 1} days)';

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                // Expanded(
                //   child: GestureDetector(
                //     onTap: () => setState(() => _isDistributedMode = false),
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //       decoration: BoxDecoration(
                //         color: !_isDistributedMode
                //             ? AppTheme.primary
                //             : Colors.transparent,
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       child: Text(
                //         'Per Animal',
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //           color: !_isDistributedMode
                //               ? Colors.white
                //               : Theme.of(context).colorScheme.onSurface,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
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
                              : Theme.of(context).colorScheme.onSurface,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.hub, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            "Enter Total Shed Production",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This will be distributed equally among $count animals.\nAvg: ${_calculateAvg(count)} L/animal",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor, height: 1.5),
          ),
          const SizedBox(height: 32),
          Container(
            width: 250,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _totalShedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
              decoration: InputDecoration(
                suffixText: 'Liters',
                suffixStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
                hintText: '0.0',
                filled: true,
                fillColor: AppTheme.primary.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onChanged: (v) => setState(() {}),
            ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: animals.map((animal) {
          final id = animal.internalId ?? 0;
          final displayId = animal.animalId.isNotEmpty
              ? animal.animalId
              : animal.earTagId ?? 'N/A';
          final breed = animal.breed ?? 'Unknown';

          if (!_quantityControllers.containsKey(id)) {
            _quantityControllers[id] = TextEditingController();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.08),
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        displayId.toString().substring(
                          0,
                          min(3, displayId.toString().length),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ID: $displayId",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            breed,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: _quantityControllers[id],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Liters',
                          labelStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 18,
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                          suffixText: 'L',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton(List<InvestorAnimal> animals) {
    return CustomActionButton(
      width: 200,
      //width: double.infinity,
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
    );
  }

  Future<void> _submit(List<InvestorAnimal> animals) async {
    final dates = _getSelectedDates();
    if (dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final notifier = ref.read(supervisorDashboardProvider.notifier);

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
          startDate: DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start),
          endDate: DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end),
          timing: _selectedTiming,
          totalQuantity: total,
        );
        if (res != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Success! ${res['message'] ?? 'Entries Created'}'),
            ),
          );
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
    } else {
      final perAnimalData = <int, String>{};
      for (final animal in animals) {
        final id = animal.internalId;
        if (id == null) continue;
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
