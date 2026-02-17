import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/filter_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_tickets_provider.dart';

import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter/material.dart';
import '../../new_supervisor/widgets/alert_cards.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';

class ActualAlertScreen extends ConsumerWidget {
  ActualAlertScreen({super.key});

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
          'Alerts'.tr(ref),
          style: TextStyle(
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Farm Alerts'.tr(ref),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChipWidget(
                    label: 'All'.tr(ref),
                    selected: currentFilter == 'all',
                    onTap: () =>
                        ref.read(ticketStatusFilterProvider.notifier).state =
                            'all',
                  ),
                  FilterChipWidget(
                    label: 'Critical'.tr(ref),
                    selected: currentFilter == 'Critical',
                    onTap: () =>
                        ref.read(ticketStatusFilterProvider.notifier).state =
                            'Critical',
                  ),
                  FilterChipWidget(
                    label: 'Today'.tr(ref),
                    selected: currentFilter == 'Today',
                    onTap: () =>
                        ref.read(ticketStatusFilterProvider.notifier).state =
                            'Today',
                  ),
                  FilterChipWidget(
                    label: 'Completed'.tr(ref),
                    selected: currentFilter == 'Completed',
                    onTap: () =>
                        ref.read(ticketStatusFilterProvider.notifier).state =
                            'Completed',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Active Alerts'.tr(ref),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ticketsAsync.when(
                data: (tickets) {
                  if (tickets.isEmpty) {
                    return Center(child: Text('No alerts found'.tr(ref)));
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
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: AlertCardDivided(
                          title: '$type Ticket #${ticket.id}',
                          subtitle: ticket.description,
                          time:
                              '${DateTime.now().difference(createdAt).inMinutes}m ago',
                          ids:
                              'Animal ID: ${ticket.animalId?.toString() ?? 'N/A'}',
                          actionText: status == TicketStatus.pending.value
                              ? 'Track Progress'.tr(ref)
                              : 'View Details'.tr(ref),
                          headerColor: headerColor,
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error: ${err.toString()}')),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Completed Alerts'.tr(ref),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 100), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }
}
