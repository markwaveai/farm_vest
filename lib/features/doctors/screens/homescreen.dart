import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/features/doctors/providers/doctors_provider.dart';
import 'package:farm_vest/features/doctors/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dashboard_stat_card.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  int _currentIndex = 4;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(doctorsProvider.notifier).fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(doctorsProvider);
    final healthCounts = healthState.healthCounts;
    final vaccinationCounts = healthState.vaccinationCounts;

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
      body: RefreshIndicator(
        onRefresh: () => ref.read(doctorsProvider.notifier).fetchTickets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(title: 'Buffalo Health Tickets'),
              const SizedBox(height: 12),
              if (healthState.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _grid([
                  DashboardStatCard(
                    title: 'Total Tickets',
                    value: healthCounts['total'].toString().padLeft(2, '0'),
                    iconWidget: Image.asset(
                      'assets/icons/buffalo_head.png',
                      width: 24,
                      height: 28,
                    ),
                    backgroundColor: AppTheme.primary,
                  ),
                  DashboardStatCard(
                    title: 'Pending Tickets',
                    value: healthCounts['pending'].toString().padLeft(2, '0'),
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
                    value: healthCounts['inProgress'].toString().padLeft(
                      2,
                      '0',
                    ),
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
                    value: healthCounts['completed'].toString().padLeft(2, '0'),
                    iconWidget: Image.asset(
                      'assets/icons/buffalo_head.png',
                      width: 24,
                      height: 24,
                      color: AppTheme.white,
                    ),
                    backgroundColor: AppTheme.lightGreen,
                  ),
                ]),
              ],
              const SizedBox(height: 24),
              _sectionHeader(title: 'Vaccination Tickets'),
              const SizedBox(height: 12),
              if (healthState.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _grid([
                  DashboardStatCard(
                    title: 'Total Tickets',
                    value: vaccinationCounts['total'].toString().padLeft(
                      2,
                      '0',
                    ),
                    iconWidget: Image.asset(
                      'assets/icons/injection.png',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: AppTheme.successGreen,
                  ),
                  DashboardStatCard(
                    title: 'Pending Tickets',
                    value: vaccinationCounts['pending'].toString().padLeft(
                      2,
                      '0',
                    ),
                    iconWidget: Image.asset(
                      'assets/icons/injection.png',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: AppTheme.orange,
                  ),
                  DashboardStatCard(
                    title: 'In Progress Tickets',
                    value: vaccinationCounts['inProgress'].toString().padLeft(
                      2,
                      '0',
                    ),
                    iconWidget: Image.asset(
                      'assets/icons/injection.png',
                      width: 24,
                      height: 24,
                    ),
                    backgroundColor: AppTheme.lightPrimary,
                  ),
                  DashboardStatCard(
                    title: 'Completed Tickets',
                    value: vaccinationCounts['completed'].toString().padLeft(
                      2,
                      '0',
                    ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
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
