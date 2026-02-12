import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/core/models/ticket_model.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final supervisorTicketsProvider = FutureProvider<List<Ticket>>((ref) async {
  final repo = ref.read(supervisorRepositoryProvider);
  final response = await repo.getTickets();
  return List<Ticket>.from(response['data'] ?? []);
});

final ticketStatusFilterProvider = StateProvider<String>((ref) => 'all');

final filteredSupervisorTicketsProvider = Provider<AsyncValue<List<Ticket>>>((
  ref,
) {
  final ticketsAsync = ref.watch(supervisorTicketsProvider);
  final filter = ref.watch(ticketStatusFilterProvider);

  return ticketsAsync.whenData((tickets) {
    if (filter == 'all') return tickets;
    if (filter == 'Critical')
      return tickets.where((t) => t.priority == 'CRITICAL').toList();
    if (filter == 'Today') {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      return tickets
          .where(
            (t) => t.createdAt?.toIso8601String().startsWith(todayStr) ?? false,
          )
          .toList();
    }
    if (filter == 'Completed')
      return tickets
          .where(
            (t) =>
                t.status == TicketStatus.resolved.value ||
                t.status == 'REJECTED',
          )
          .toList();
    return tickets;
  });
});
