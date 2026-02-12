import 'package:farm_vest/features/doctors/widgets/health_tickets_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VaccineTicketsScreen extends StatelessWidget {
  const VaccineTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Vaccination Tickets",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const HealthTicketsView(
        ticketType: 'VACCINATION',
        initialFilter: "All",
      ),
    );
  }
}
