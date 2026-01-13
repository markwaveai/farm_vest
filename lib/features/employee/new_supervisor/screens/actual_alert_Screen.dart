import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/filter_chip.dart';

import 'package:flutter/material.dart';
import '../../new_supervisor/widgets/alert_cards.dart';



class ActualAlertScreen extends StatelessWidget {
  const ActualAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.white,
        title: const Text(
          'ALERTS',
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.black),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
            height: 40, 
            child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
            FilterChipWidget(label: 'All', selected: true),
            FilterChipWidget(label: 'Critical'),
            FilterChipWidget(label: 'Today'),
            FilterChipWidget(label: 'Completed'),
           ],
           ),
         ),

            

            const SizedBox(height: 16),
            const Text(
              'Active Alerts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            
            Expanded(
              child: ListView(
                children: const [
                   
                  AlertCardDivided(
                  title: 'Doctor Prescription',
                  subtitle: '2 buffaloes got prescription',
                  time: '10 min ago',
                  ids: 'B14, B17, ...',
                  actionText: 'View Instructions',
                  headerColor: AppTheme.primary,
                  ),
                  SizedBox(height: 16),
                  AlertCardDivided(
                    title: 'Vet Visit Required',
                    subtitle: '#D12 is not eating and appears weak',
                    time: '20 min ago',
                    ids: 'D12, D15, ...',
                    actionText: 'Schedule Now',
                    headerColor: Colors.red,
                  ),
                  SizedBox(height: 16),
                  AlertCardDivided(
                    title: 'Missed Heat',
                    subtitle: 'A24 missed heat cycle yesterday',
                    time: '1 hr ago',
                    ids: 'A24, A30, ...',
                    actionText: 'Mark Heat',
                    headerColor: Colors.orange,
                  ),  
                  SizedBox(height: 16),
                  AlertCardDivided(
                    title: 'Vaccination Due',
                    subtitle: '7 buffaloes scheduled at 5pm',
                    time: '1 hr ago',
                    ids: 'B05, B09, ...',
                    actionText: 'View Buffalo',
                    headerColor: Colors.green,
                  ),  
                  SizedBox(height: 16),              
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Completed Alerts ⌄',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
