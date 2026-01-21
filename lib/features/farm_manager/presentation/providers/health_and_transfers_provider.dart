import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/utils/app_enums.dart';

import '../../data/models/health_transfer_ticket_model.dart';
import '../../data/repository/farm_manager_repository.dart';

class HealthAndTransfersState {
  final bool isLoading;
  final List<HealthTransferTicketModel> tickets;
  final String? error;
  final String selectedTab;

  HealthAndTransfersState({
    this.isLoading = false,
    this.tickets = const [],
    this.error,
    this.selectedTab = 'HEALTH',
  });

  HealthAndTransfersState copyWith({
    bool? isLoading,
    List<HealthTransferTicketModel>? tickets,
    String? error,
    String? selectedTab,
  }) {
    return HealthAndTransfersState(
      isLoading: isLoading ?? this.isLoading,
      tickets: tickets ?? this.tickets,
      error: error,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class HealthAndTransfersNotifier extends Notifier<HealthAndTransfersState> {
  @override
  HealthAndTransfersState build() {
    // Schedule initial fetch
    Future.microtask(() => fetchTickets());
    return HealthAndTransfersState();
  }

  Future<void> fetchTickets() async {
    final repository = ref.read(farmManagerRepositoryProvider);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tickets = await repository.getHealthAndTransferTickets(
        ticketType: state.selectedTab,
      );
      state = state.copyWith(isLoading: false, tickets: tickets);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setTab(String tab) {
    if (state.selectedTab != tab) {
      state = state.copyWith(selectedTab: tab);
      fetchTickets();
    }
  }

  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    final repository = ref.read(farmManagerRepositoryProvider);
    // Optimistic update or just set loading?
    // Let's set loading for now, better UX would be optimistic
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.updateTicketStatus(ticketId, status);
      // Refresh list after update
      await fetchTickets();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final farmManagerRepositoryProvider = Provider<FarmManagerRepository>((ref) {
  return FarmManagerRepository();
});

final healthAndTransfersProvider =
    NotifierProvider<HealthAndTransfersNotifier, HealthAndTransfersState>(
      HealthAndTransfersNotifier.new,
    );
