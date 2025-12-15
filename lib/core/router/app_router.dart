import 'package:farm_vest/features/customer/screens/customer_profile_screen.dart';
import 'package:go_router/go_router.dart';
import '../../features/customer/screens/buffalo_calves_screen.dart';
import '../../features/customer/models/unit_response.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';

import '../../features/common/screens/notifications_screen.dart';
import '../../features/customer/screens/asset_valuation_screen.dart';
import '../../features/customer/screens/cctv_live_screen.dart';
import '../../features/customer/screens/customer_dashboard_screen.dart';
import '../../features/customer/screens/health_records_screen.dart';
import '../../features/customer/screens/monthly_visits_screen.dart';
import '../../features/customer/screens/revenue_screen.dart';
import '../../features/customer/screens/support_screen.dart';
import '../../features/customer/screens/unit_details_screen.dart';
import '../../features/employee/screens/assistant_dashboard_screen.dart';
import '../../features/employee/screens/doctor_dashboard_screen.dart';
import '../../features/employee/screens/health_issues_screen.dart';
import '../../features/employee/screens/milk_production_screen.dart';
import '../../features/employee/screens/profile_screen.dart';
import '../../features/employee/screens/raise_ticket_screen.dart';
import '../../features/employee/screens/supervisor_dashboard_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';

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
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      // Customer Routes
      GoRoute(
        path: '/customer-dashboard',
        builder: (context, state) => const CustomerDashboardScreen(),
      ),
      GoRoute(
        path: '/unit-details',
        builder: (context, state) => const UnitDetailsScreen(),
      ),
      GoRoute(
        path: '/cctv-live',
        builder: (context, state) => const CCTVLiveScreen(),
      ),
      GoRoute(
        path: '/monthly-visits',
        builder: (context, state) => const MonthlyVisitsScreen(),
      ),
      GoRoute(
        path: '/health-records',
        builder: (context, state) => const HealthRecordsScreen(),
      ),
      GoRoute(
        path: '/revenue',
        builder: (context, state) => const RevenueScreen(),
      ),
      GoRoute(
        path: '/asset-valuation',
        builder: (context, state) => const AssetValuationScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/customer-profile',
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: '/buffalo-calves',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return BuffaloCalvesScreen(
            calves: extras['calves'] as List<Animal>,
            parentId: extras['parentId'] as String,
          );
        },
      ),

      // Employee Routes
      GoRoute(
        path: '/supervisor-dashboard',
        builder: (context, state) => const SupervisorDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
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
