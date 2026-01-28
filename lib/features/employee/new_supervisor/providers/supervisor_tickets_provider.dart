import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final supervisorTicketsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.read(supervisorRepositoryProvider);
  final response = await repo.getTickets();
  return List<Map<String, dynamic>>.from(response['data'] ?? []);
});

final ticketStatusFilterProvider = StateProvider<String>((ref) => 'all');

final filteredSupervisorTicketsProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
      final ticketsAsync = ref.watch(supervisorTicketsProvider);
      final filter = ref.watch(ticketStatusFilterProvider);

      return ticketsAsync.whenData((tickets) {
        if (filter == 'all') return tickets;
        if (filter == 'Critical')
          return tickets.where((t) => t['priority'] == 'CRITICAL').toList();
        if (filter == 'Today') {
          final todayStr = DateTime.now().toIso8601String().substring(0, 10);
          return tickets
              .where(
                (t) =>
                    t['created_at']?.toString().startsWith(todayStr) ?? false,
              )
              .toList();
        }
        if (filter == 'Completed')
          return tickets
              .where(
                (t) => t['status'] == 'RESOLVED' || t['status'] == 'REJECTED',
              )
              .toList();
        return tickets;
      });
    });
