import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/filter_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_tickets_provider.dart';

import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import '../../new_supervisor/widgets/alert_cards.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';

class ActualAlertScreen extends ConsumerWidget {
  const ActualAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(filteredSupervisorTicketsProvider);
    final currentFilter = ref.watch(ticketStatusFilterProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'ALERTS'.tr,
          style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => ref.refresh(supervisorTicketsProvider),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Alerts'.tr,
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
                    label: 'All'.tr,
                    selected: currentFilter == 'all',
                    onTap: () =>
                        ref.read(ticketStatusFilterProvider.notifier).state =
                            'all',
                  ),
                  FilterChipWidget(
                    label: 'Critical'.tr,
                    selected: currentFilter == 'Critical',
                    onTap: () =>
                        ref.read(ticketStatusFilterProvider.notifier).state =
                            'Critical',
                  ),
                  FilterChipWidget(
                    label: 'Today'.tr,
                    selected: currentFilter == 'Today',
                    onTap: () =>
                        ref.read(ticketStatusFilterProvider.notifier).state =
                            'Today',
                  ),
                  FilterChipWidget(
                    label: 'Completed'.tr,
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
              'Active Alerts'.tr,
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
                    return Center(child: Text('No alerts found'.tr));
                  }
                  return ListView.builder(
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
                        headerColor = Colors.orange;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: AlertCardDivided(
                          title: '$type Ticket #${ticket.id}',
                          subtitle: ticket.description,
                          time:
                              '${DateTime.now().difference(createdAt).inMinutes} ${'min ago'.tr}',
                          ids: '${'Animal ID'.tr}: ${ticket.animalId ?? 'N/A'}',
                          actionText: status == TicketStatus.pending.value
                              ? 'Track Progress'.tr
                              : 'View Details'.tr,
                          headerColor: headerColor,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('${'Error'.tr}: $err')),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed Alerts'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }
}
