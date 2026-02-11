import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/doctors/widgets/health_ticket_card.dart';
import 'package:flutter/material.dart';

class VaccineTicketsScreen extends StatefulWidget {
  const VaccineTicketsScreen({super.key});

  @override
  State<VaccineTicketsScreen> createState() => _VaccineTicketsScreenState();
}

class _VaccineTicketsScreenState extends State<VaccineTicketsScreen> {
  String selectedFilter = "All";

  final List<String> filters = ["All", "Pending", "Completed", "Approved"];

  final List<Map<String, String>> tickets = [
    {"id": "#33", "status": "Pending"},
    {"id": "#34", "status": "Completed"},
    {"id": "#35", "status": "Pending"},
    {"id": "#36", "status": "Approved"},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTickets = tickets.where((ticket) {
      if (selectedFilter == "All") return true;
      return ticket["status"] == selectedFilter;
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
          "Vaccine Tickets",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),

      body: Column(
        children: [
          _buildFilterButtons(),

          Expanded(
            child: ListView.builder(
              itemCount: filteredTickets.length,
              itemBuilder: (context, index) {
                final ticket = filteredTickets[index];

                return HealthTicketCard(
                  ticketId: ticket["id"]!,
                  description:
                      "Ticket raised by Supervisor awaiting final medical authorization",
                  timeAgo: "10 min ago",
                  status: ticket["status"]!,
                  isVaccination: true,
                  onActionTap: () {
                    print("Add Vaccine Tapped");
                  },
                  onViewDetailsTap: () {
                    print("View Details tapped");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: filters.length,
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
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.darkPrimary
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Theme.of(context).cardColor),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? (isSelected ? AppTheme.darkPrimary : Colors.white12)
                      : AppTheme.darkPrimary,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.white
                      : (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : AppTheme.darkPrimary),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
