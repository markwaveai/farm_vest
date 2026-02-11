import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/doctors/providers/doctors_provider.dart';
import 'package:farm_vest/features/doctors/widgets/bottom_navigation.dart';
import 'package:farm_vest/features/doctors/widgets/health_ticket_card.dart';
import 'package:farm_vest/features/doctors/widgets/assignment_dialogs.dart';
import 'package:farm_vest/features/doctors/widgets/ticket_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HealthTicketScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  final String ticketType;

  const HealthTicketScreen({
    super.key,
    this.initialFilter,
    this.ticketType = 'HEALTH',
  });

  @override
  ConsumerState<HealthTicketScreen> createState() => _HealthTicketScreenState();
}

class _HealthTicketScreenState extends ConsumerState<HealthTicketScreen> {
  int _currentIndex = 0;
  String selectedFilter = "All";

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
    selectedFilter = widget.initialFilter ?? "All";

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.ticketType == 'VACCINATION'
              ? "Vaccination Tickets"
              : "Health Tickets",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
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
                      "No health tickets found",
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
                              ? DateFormat('hh:mm a').format(ticket.createdAt!)
                              : "Recently",
                          status: ticket.status,
                          onAssignTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AssignTicketDialog(
                                ticketId: ticket.id.toString(),
                                buffaloId: ticket.animalId ?? 'Unknown',
                                onAssign: (assistantName) {
                                  // TODO: Call API to assign assistant
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AssignmentSuccessDialog(
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
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            context.push(
              '/all-health-tickets',
              extra: {'filter': 'All', 'type': 'HEALTH'},
            );
          } else if (index == 1) {
            context.push(
              '/all-health-tickets',
              extra: {'filter': 'All', 'type': 'VACCINATION'},
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = 4);
          context.go('/doctor-dashboard');
        },
        child: Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            color: AppTheme.darkPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.asset('assets/icons/home.png', color: AppTheme.white),
          ),
        ),
      ),
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
