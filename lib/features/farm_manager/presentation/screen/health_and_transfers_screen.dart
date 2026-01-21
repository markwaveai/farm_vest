import 'package:farm_vest/features/farm_manager/presentation/widgets/ticket_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/health_and_transfers_provider.dart';

class HealthAndTransfersScreen extends ConsumerStatefulWidget {
  const HealthAndTransfersScreen({super.key});

  @override
  ConsumerState<HealthAndTransfersScreen> createState() =>
      _HealthAndTransfersScreenState();
}

class _HealthAndTransfersScreenState
    extends ConsumerState<HealthAndTransfersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final tabName = _tabController.index == 0 ? 'HEALTH' : 'TRANSFER';
      ref.read(healthAndTransfersProvider.notifier).setTab(tabName);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthAndTransfersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Health & Transfers",
          style: TextStyle(color: AppTheme.dark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.dark),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: "Health Issues"),
            Tab(text: "Transfer Requests"),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text("Error: ${state.error}"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tickets.length,
              itemBuilder: (context, index) {
                final ticket = state.tickets[index];
                return TicketCard(
                  ticket: ticket,
                  onApprove: () => ref
                      .read(healthAndTransfersProvider.notifier)
                      .updateTicketStatus(
                        ticket.ticketId.toString(),
                        TicketStatus.resolved,
                      ),
                  onReject: () => ref
                      .read(healthAndTransfersProvider.notifier)
                      .updateTicketStatus(
                        ticket.ticketId.toString(),
                        TicketStatus.rejected,
                      ),
                );
              },
            ),
    );
  }
}
