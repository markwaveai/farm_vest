import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/filter_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_tickets_provider.dart';

import 'package:flutter/material.dart';
import '../../new_supervisor/widgets/alert_cards.dart';

class ActualAlertScreen extends ConsumerWidget {
  const ActualAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(filteredSupervisorTicketsProvider);
    final currentFilter = ref.watch(ticketStatusFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.white,
        title: const Text(
          'ALERTS',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.black),
            onPressed: () => ref.refresh(supervisorTicketsProvider),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            const Text(
              'Active Alerts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ticketsAsync.when(
                data: (tickets) {
                  if (tickets.isEmpty) {
                    return const Center(child: Text('No alerts found'));
                  }
                  return ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      final type = ticket['ticket_type'] ?? 'GENERAL';
                      final status = ticket['status'] ?? 'PENDING';
                      final priority = ticket['priority'] ?? 'MEDIUM';
                      final createdAt = ticket['created_at'] != null
                          ? DateTime.parse(ticket['created_at']).toLocal()
                          : DateTime.now();

                      Color headerColor = AppTheme.primary;
                      if (priority == 'CRITICAL' || priority == 'HIGH')
                        headerColor = Colors.red;
                      if (type == 'HEALTH') headerColor = Colors.orange;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AlertCardDivided(
                          title: '$type Ticket #${ticket['id']}',
                          subtitle:
                              ticket['description'] ??
                              'No description provided',
                          time:
                              '${DateTime.now().difference(createdAt).inMinutes} min ago',
                          ids: 'Animal ID: ${ticket['animal_id']}',
                          actionText: status == 'PENDING'
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
            const SizedBox(height: 8),
            const Text(
              'Completed Alerts',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }
}
