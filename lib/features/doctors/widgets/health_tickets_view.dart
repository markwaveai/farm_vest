import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/doctors/providers/doctors_provider.dart';
import 'package:farm_vest/features/doctors/widgets/health_ticket_card.dart';
import 'package:farm_vest/features/doctors/widgets/assignment_dialogs.dart';
import 'package:farm_vest/features/doctors/widgets/ticket_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HealthTicketsView extends ConsumerStatefulWidget {
  final String ticketType; // 'HEALTH' or 'VACCINATION'
  final String initialFilter;
  final bool showActions;

  const HealthTicketsView({
    super.key,
    required this.ticketType,
    this.initialFilter = "All",
    this.showActions = true,
  });

  @override
  ConsumerState<HealthTicketsView> createState() => _HealthTicketsViewState();
}

class _HealthTicketsViewState extends ConsumerState<HealthTicketsView> {
  late String selectedFilter;
  final List<String> filters = [
    "All",
    "Pending",
    "Completed",
    "Approved",
    "In progress",
  ];

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    Future.microtask(() {
      ref.read(doctorsProvider.notifier).fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(doctorsProvider);
    final tickets = widget.ticketType == 'VACCINATION'
        ? healthState.vaccinationTickets
        : healthState.healthTickets;

    final filteredTickets = tickets.where((ticket) {
      if (selectedFilter == "All") return true;
      return ticket.status.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();

    return Column(
      children: [
        _buildFilterButtons(),
        Expanded(
          child: healthState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : healthState.error != null
              ? Center(child: Text('Error: ${healthState.error}'))
              : filteredTickets.isEmpty
              ? Center(
                  child: Text(
                    "No ${widget.ticketType.toLowerCase()} tickets found",
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(doctorsProvider.notifier).fetchTickets(),
                  child: ListView.builder(
                    itemCount: filteredTickets.length,
                    itemBuilder: (context, index) {
                      final ticket = filteredTickets[index];
                      return HealthTicketCard(
                        ticketId:
                            "${ticket.animalId ?? 'Animal'}-${ticket.description}",
                        description: ticket.description,
                        timeAgo: ticket.createdAt != null
                            ? DateFormat(
                                'hh:mm a',
                              ).format(ticket.createdAt!.toLocal())
                            : "Recently",
                        status: ticket.status,
                        isVaccination: widget.ticketType == 'VACCINATION',
                        onAssignTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AssignTicketDialog(
                              ticketId: ticket.id.toString(),
                              buffaloId: ticket.animalId ?? 'Unknown',
                              onAssign: (assistantName) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AssignmentSuccessDialog(
                                    ticketId: '#${ticket.id}',
                                    assignedTo: assistantName,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        onViewDetailsTap: () {
                          TicketDetailsBottomSheet.show(context, ticket);
                        },
                        onActionTap: widget.ticketType == 'VACCINATION'
                            ? () {
                                // Handle vaccination action if needed
                              }
                            : null,
                        showActions: widget.showActions,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.darkPrimary
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : AppTheme.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.darkPrimary),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? AppTheme.white : AppTheme.darkPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: filters.length,
      ),
    );
  }
}
