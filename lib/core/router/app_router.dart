import 'package:farm_vest/features/farm_manager/presentation/screen/farm_manager_dashboard.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/health_and_transfers_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/staff_list_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/widgets/investor_details.dart';
import 'package:farm_vest/features/supervisor/presentation/screens/buffalo_details_screen.dart';
import 'package:farm_vest/features/supervisor/presentation/screens/buffalo_grid_screen.dart';

import 'package:farm_vest/features/employee/presentation/screens/doctor_dashboard_newscreen.dart';

import 'package:farm_vest/features/employee/new_supervisor/screens/new_supervisor_dashboard.dart';

import 'package:go_router/go_router.dart';
import 'package:farm_vest/features/investor/presentation/screens/cctv_main_screen.dart';
import 'package:farm_vest/features/investor/presentation/screens/investor_profile_screen.dart';
import 'package:farm_vest/features/investor/presentation/widgets/investor_shell.dart';
import '../../features/employee/presentation/screens/doctor_dashboard_newscreen.dart';
import '../../features/investor/presentation/screens/buffalo_calves_screen.dart';
import '../../features/investor/data/models/unit_response.dart';
import '../../features/auth/presentation/screens/new_login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/common/presentation/screens/notifications_screen.dart';
import '../../features/investor/presentation/screens/asset_valuation_screen.dart';
import '../../features/investor/presentation/screens/investor_dashboard_screen.dart';
import '../../features/investor/presentation/screens/monthly_visits_screen.dart';
import '../../features/investor/presentation/screens/revenue_screen.dart';
import '../../features/investor/presentation/screens/support_screen.dart';
import '../../features/investor/presentation/screens/unit_details_screen.dart';
import '../../features/employee/presentation/screens/assistant_dashboard_screen.dart';
import '../../features/employee/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/employee/presentation/screens/health_issues_screen.dart';
import '../../features/employee/presentation/screens/milk_production_screen.dart';
import '../../features/employee/presentation/screens/profile_screen.dart';
import '../../features/employee/presentation/screens/raise_ticket_screen.dart';
//import '../../features/supervisor/presentation/screens/supervisor_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const NewLoginScreen();
        },
      ),

      // Customer Routes
      ShellRoute(
        builder: (context, state, child) => InvestorShell(child: child),
        routes: [
          GoRoute(
            path: '/customer-dashboard',
            builder: (context, state) => const InvestorDashboardScreen(),
          ),
          GoRoute(
            path: '/asset-valuation',
            builder: (context, state) => const AssetValuationScreen(),
          ),
          GoRoute(
            path: '/cctv-live',
            builder: (context, state) => const CCTVMainScreen(),
          ),
          GoRoute(
            path: '/revenue',
            builder: (context, state) => const RevenueScreen(),
          ),
          GoRoute(
            path: '/customer-profile',
            builder: (context, state) => const InvestorProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/unit-details',
        builder: (context, state) => const UnitDetailsScreen(),
      ),
      GoRoute(
        path: '/monthly-visits',
        builder: (context, state) => const MonthlyVisitsScreen(),
      ),

      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/buffalo-calves',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return BuffaloCalvesScreen(
            calves: extras['calves'] as List<Animal>,
            parentId: extras['parentId'] as String,
            parent: extras['parent'] as Animal?,
          );
        },
      ),

      // Employee Routes
      GoRoute(
        path: '/supervisor-dashboard',
        builder: (context, state) => const NewSupervisorDashboard(),
      ),
      GoRoute(
        path: '/buffalo-grid',
        builder: (context, state) => const BuffaloGridScreen(),
      ),
      GoRoute(
        path: '/buffalo-details/:location',
        builder: (context, state) {
          final location = state.pathParameters['location']!;
          return BuffaloDetailsScreen(location: location);
        },
      ),
      GoRoute(
        path: '/farm-manager-dashboard',
        builder: (context, state) => const FarmManagerDashboard(),
      ),
      GoRoute(
        path: '/health-transfers-dashboard',
        builder: (context, state) => const HealthAndTransfersScreen(),
      ),
      GoRoute(
        path: '/investor-details',
        builder: (context, state) => const InvestorDetails(),
      ),
      GoRoute(
        path: '/staff-list',
        builder: (context, state) => const StaffListScreen(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => DoctorDashboardNewscreen(),
        //const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/assistant-dashboard',
        builder: (context, state) => const AssistantDashboardScreen(),
      ),
      GoRoute(
        path: '/milk-production',
        builder: (context, state) => const MilkProductionScreen(),
      ),
      GoRoute(
        path: '/health-issues',
        builder: (context, state) => const HealthIssuesScreen(),
      ),
      GoRoute(
        path: '/raise-ticket',
        builder: (context, state) => const RaiseTicketScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Common Routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) {
          final extra = state.extra;

          final fallbackRoute = (extra is Map<String, String>)
              ? extra['fallbackRoute']
              : null;

          return NotificationsScreen(fallbackRoute: fallbackRoute ?? '/');
        },
      ),
    ],
  );
}
