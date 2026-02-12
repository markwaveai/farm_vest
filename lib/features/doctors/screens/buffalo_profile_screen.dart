import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/widgets/employee_bottom_navigation.dart';
import 'package:farm_vest/features/doctors/widgets/buffalo_profile_view.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class BuffaloProfileScreen extends StatefulWidget {
  const BuffaloProfileScreen({super.key});

  @override
  State<BuffaloProfileScreen> createState() => _BuffaloProfileScreenState();
}

class _BuffaloProfileScreenState extends State<BuffaloProfileScreen> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Buffalo Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: const BuffaloProfileView(),
      bottomNavigationBar: EmployeeBottomNavigation(
        role: UserType.doctor,
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
          } else if (index == 2) {
            context.push('/transfer-tickets');
          } else if (index == 3) {
            // Already here
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : AppTheme.darkPrimary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkPrimary
                  : AppTheme.white,
              width: 4,
            ),
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
            child: Image.asset(
              'assets/icons/home.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primary
                  : AppTheme.white,
            ),
          ),
        ),
      ),
    );
  }
}
