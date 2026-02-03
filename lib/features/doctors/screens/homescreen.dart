import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/doctors/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dashboard_stat_card.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.white,
        title: Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: const TextSpan(
              text: 'Hello ',

              style: TextStyle(color: AppTheme.black, fontSize: 16),

              children: [
                TextSpan(
                  text: 'Dr. Krishna,',
                  style: TextStyle(
                    color: AppTheme.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.black),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(title: 'Buffalo Health Tickets'),
            const SizedBox(height: 12),
            _grid([
              DashboardStatCard(
                title: 'Total Tickets',
                value: '20',
                iconWidget: Image.asset(
                  'assets/icons/buffalo_head.png',
                  width: 24,
                  height: 28,
                ),

                backgroundColor: AppTheme.primary,
              ),
              DashboardStatCard(
                title: 'Pending Tickets',
                value: '02',
                iconWidget: Image.asset(
                  'assets/icons/buffalo_head.png',
                  width: 24,
                  height: 24,
                  color: AppTheme.white,
                ),

                backgroundColor: const Color(0xFFFCA222),
              ),
              DashboardStatCard(
                title: 'In Progress Tickets',
                value: '03',
                iconWidget: Image.asset(
                  'assets/icons/buffalo_head.png',
                  width: 24,
                  height: 24,
                  color: AppTheme.white,
                ),

                backgroundColor: AppTheme.lightPrimary,
              ),
              DashboardStatCard(
                title: 'Completed Tickets',
                value: '03',
                iconWidget: Image.asset(
                  'assets/icons/buffalo_head.png',
                  width: 24,
                  height: 24,
                  color: AppTheme.white,
                ),

                backgroundColor: AppTheme.lightGreen,
              ),
            ]),
            const SizedBox(height: 24),
            _sectionHeader(title: 'Vaccination Tickets'),
            const SizedBox(height: 12),
            _grid([
              DashboardStatCard(
                title: 'Total Tickets',
                value: '14',
                iconWidget: Image.asset(
                  'assets/icons/injection.png',
                  width: 24,
                  height: 24,
                ),

                backgroundColor: AppTheme.successGreen,
              ),
              DashboardStatCard(
                title: 'Pending Tickets',
                value: '03',
                iconWidget: Image.asset(
                  'assets/icons/injection.png',
                  width: 24,
                  height: 24,
                ),

                backgroundColor: AppTheme.orange,
              ),
              DashboardStatCard(
                title: 'In Progress Tickets',
                value: '02',
                iconWidget: Image.asset(
                  'assets/icons/injection.png',
                  width: 24,
                  height: 24,
                ),

                backgroundColor: AppTheme.lightPrimary,
              ),
              DashboardStatCard(
                title: 'Completed Tickets',
                value: '01',
                iconWidget: Image.asset(
                  'assets/icons/injection.png',
                  width: 28,
                  height: 28,
                  color: AppTheme.white,
                ),

                backgroundColor: AppTheme.lightGreen,
              ),
            ]),
          ],
        ),
      ),

      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);

          // switch (index) {
          //   case 0:
          //     context.go('/health');
          //     break;
          //   case 1:
          //     context.go('/vaccination');
          //     break;
          //   case 2:
          //     context.go('/movement');
          //     break;
          //   case 3:
          //     context.go('/buffalo');
          //     break;
          //   case 4:
          //     context.go('/home');
          //     break;
          // }
        },
      ),
    );
  }

  Widget _sectionHeader({required String title, String? badge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.darkPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'View All Tickets',
            style: TextStyle(color: AppTheme.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _grid(List<Widget> children) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: children,
    );
  }
}
