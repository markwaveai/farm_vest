import 'package:farm_vest/core/services/tickets_api_services.dart';
import 'package:farm_vest/features/admin/data/models/ticket_model.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthTicketsState {
  final List<Ticket> healthTickets;
  final List<Ticket> vaccinationTickets;
  final bool isLoading;
  final String? error;

  HealthTicketsState({
    this.healthTickets = const [],
    this.vaccinationTickets = const [],
    this.isLoading = false,
    this.error,
  });

  HealthTicketsState copyWith({
    List<Ticket>? healthTickets,
    List<Ticket>? vaccinationTickets,
    bool? isLoading,
    String? error,
  }) {
    return HealthTicketsState(
      healthTickets: healthTickets ?? this.healthTickets,
      vaccinationTickets: vaccinationTickets ?? this.vaccinationTickets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Helper methods to get counts
  Map<String, int> get healthCounts => _getCounts(healthTickets);
  Map<String, int> get vaccinationCounts => _getCounts(vaccinationTickets);

  Map<String, int> _getCounts(List<Ticket> tickets) {
    int total = tickets.length;
    int pending = tickets
        .where(
          (t) =>
              t.status.toUpperCase() == 'OPEN' ||
              t.status.toUpperCase() == 'PENDING',
        )
        .length;
    int inProgress = tickets
        .where(
          (t) =>
              t.status.toUpperCase() == 'IN_PROGRESS' ||
              t.status.toUpperCase() == 'IN PROGRESS',
        )
        .length;
    int completed = tickets
        .where(
          (t) =>
              t.status.toUpperCase() == 'COMPLETED' ||
              t.status.toUpperCase() == 'RESOLVED' ||
              t.status.toUpperCase() == 'CLOSED',
        )
        .length;
    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
    };
  }
}

class DoctorsNotifier extends Notifier<HealthTicketsState> {
  @override
  HealthTicketsState build() {
    return HealthTicketsState();
  }

  Future<void> fetchTickets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await ref.read(authProvider.notifier).getToken();
      if (token == null) {
        state = state.copyWith(isLoading: false, error: 'Token not found');
        return;
      }

      final healthTickets = await TicketsApiServices.getHealthTickets(
        token: token,
        ticketType: 'HEALTH',
      );

      final vaccinationTickets = await TicketsApiServices.getHealthTickets(
        token: token,
        ticketType: 'VACCINATION',
      );

      state = state.copyWith(
        healthTickets: healthTickets,
        vaccinationTickets: vaccinationTickets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final doctorsProvider = NotifierProvider<DoctorsNotifier, HealthTicketsState>(
  () {
    return DoctorsNotifier();
  },
);
