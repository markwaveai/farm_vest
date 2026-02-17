import 'package:farm_vest/features/doctors/screens/all_health_tickets.dart';
import 'package:farm_vest/features/doctors/screens/doctor_home_screen.dart';
import 'package:farm_vest/features/doctors/screens/vaccination_tickets.dart';
import 'package:farm_vest/features/doctors/screens/buffalo_profile_screen.dart';
import 'package:farm_vest/features/doctors/screens/buffalo_device_details_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/actual_alert_Screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/create_leave_request_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/leave_requests_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/new_supervisor_dashboard.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/new_supervisor_shell.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/bulk_milk_entry_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/supervisor_buffalo_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/supervisor_more_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/supervisor_stats_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/screens/transfer_tickets_screen.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/buffalo_details_screen.dart';
import 'package:farm_vest/features/employee/new_supervisor/widgets/buffalo_grid_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/buffalo_allocation_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/farm_manager_dashboard.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/manager_transfer_approval_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/onboard_animal_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/create_transfer_ticket_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/reports_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/screen/staff_list_screen.dart';
import 'package:farm_vest/features/farm_manager/presentation/widgets/investor_details.dart';
import 'package:farm_vest/features/investor/presentation/screens/cctv_screens/cctv_main_screen.dart';
import 'package:farm_vest/features/investor/presentation/screens/monthly_visits/monthly_visits_screen.dart';
import 'package:farm_vest/features/common/presentation/screens/profile_screen.dart';
import 'package:farm_vest/features/investor/presentation/widgets/investor_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farm_vest/features/auth/presentation/screens/login_screen.dart';
import 'package:farm_vest/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:farm_vest/features/auth/presentation/screens/splash_screen.dart';
import 'package:farm_vest/features/common/presentation/screens/notifications_screen.dart';
import 'package:farm_vest/features/employee/presentation/screens/assistant_dashboard_screen.dart';
import 'package:farm_vest/features/employee/presentation/screens/health_issues_screen.dart';
import 'package:farm_vest/features/employee/presentation/screens/milk_production_screen.dart';
import 'package:farm_vest/features/employee/presentation/screens/raise_ticket_screen.dart';
import 'package:farm_vest/features/investor/presentation/screens/investor_dashboard_screen.dart';
import 'package:farm_vest/features/investor/presentation/screens/profile_Screens/support_screen.dart';
import 'package:farm_vest/features/investor/presentation/screens/unit_details_screen.dart';

// 1. Define the GlobalKey for the navigator.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    // 2. Assign the key to the router.
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        builder: (context, state) =>  OnboardingScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          return  NewLoginScreen();
        },
      ),

      // Customer Routes
      ShellRoute(
        builder: (context, state, child) => InvestorShell(child: child),
        routes: [
          GoRoute(
            path: '/customer-dashboard',
            builder: (context, state) =>  InvestorDashboardScreen(),
          ),
          // GoRoute(
          //   path: '/asset-valuation',
          //   builder: (context, state) => const AssetValuationScreen(),
          // ),
          GoRoute(
            path: '/cctv-live',
            builder: (context, state) =>  CCTVMainScreen(),
          ),
          // GoRoute(
          //   path: '/revenue',
          //   builder: (context, state) => const RevenueScreen(),
          // ),
          GoRoute(
            path: '/profile',
            builder: (context, state) =>  ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/unit-details',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final buffalo = extras?['buffalo'] as InvestorAnimal?;
          return UnitDetailsScreen(animal: buffalo);
        },
      ),
      GoRoute(
        path: '/monthly-visits',
        builder: (context, state) =>  MonthlyVisitsScreen(),
      ),
      GoRoute(
        path: '/manager-transfer-approvals',
        builder: (context, state) =>  ManagerTransferApprovalScreen(),
      ),

      GoRoute(
        path: '/support',
        builder: (context, state) =>  SupportScreen(),
      ),
      // GoRoute(
      //   path: '/buffalo-calves',
      //   builder: (context, state) {
      //     final extras = state.extra as Map<String, dynamic>;
      //     return BuffaloCalvesScreen(
      //       calves: extras['calves'] as List<Animal>,
      //       parentId: extras['parentId'] as String,
      //       parent: extras['parent'] as Animal?,
      //     );
      //   },
      // ),

      // Employee Routes
      ShellRoute(
        builder: (context, state, child) => NewSupervisorShell(child: child),
        routes: [
          GoRoute(
            path: '/supervisor-dashboard',
            builder: (context, state) =>  NewSupervisorDashboard(),
          ),
          GoRoute(
            path: '/new-supervisor/buffalo',
            builder: (context, state) =>  SupervisorBuffaloScreen(),
          ),
          GoRoute(
            path: '/new-supervisor/alerts',
            builder: (context, state) =>  ActualAlertScreen(),
          ),
          GoRoute(
            path: '/new-supervisor/stats',
            builder: (context, state) =>  SupervisorStatsScreen(),
          ),
          GoRoute(
            path: '/new-supervisor/more',
            builder: (context, state) =>  SupervisorMoreScreen(),
          ),
          GoRoute(
            path: '/new-supervisor/bulk-milk-entry',
            builder: (context, state) =>  BulkMilkEntryScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/buffalo-grid',
        builder: (context, state) =>  BuffaloGridScreen(),
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
        builder: (context, state) =>  FarmManagerDashboard(),
      ),
      GoRoute(
        path: '/onboard-animal',
        builder: (context, state) =>  OnboardAnimalScreen(),
      ),
      GoRoute(
        path: '/leave-requests',
        builder: (context, state) =>  LeaveRequestsScreen(),
      ),
      GoRoute(
        path: '/transfer-tickets',
        builder: (context, state) =>  TransferTicketsScreen(),
      ),
      GoRoute(
        path: '/create-leave-request',
        builder: (context, state) =>  CreateLeaveRequestScreen(),
      ),
      GoRoute(
        path: '/buffalo-allocation',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return BuffaloAllocationScreen(
            initialFarmId: extras?['farmId'] as int?,
            initialShedId: extras?['shedId'] as int?,
            targetParkingId: extras?['parkingId'] as String?,
            initialAnimalId: extras?['animalId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/investor-details',
        builder: (context, state) => InvestorDetails(),
      ),
      GoRoute(
        path: '/staff-list',
        builder: (context, state) => StaffListScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) =>  ReportsScreen(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => DoctorHomeScreen(),
        // DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/all-health-tickets',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return HealthTicketScreen(
            initialFilter: extras?['filter'] as String?,
            ticketType: extras?['type'] as String? ?? 'HEALTH',
          );
        },
      ),

      GoRoute(
        path: '/vaccination-screen',
        builder: (context, state) => VaccineTicketsScreen(),
      ),
      GoRoute(
        path: '/buffalo-profile',
        builder: (context, state) => BuffaloProfileScreen(),
      ),
      GoRoute(
        path: '/buffalo-device-details',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return BuffaloDeviceDetailsScreen(
            animalId: extras['animalId'],
            beltId: extras['beltId'],
            rfid: extras['rfid'],
            tagNumber: extras['tagNumber'],
            age: extras['age'],
            breed: extras['breed'],
            status: extras['status'],
            animal: extras['animal'],
          );
        },
      ),
      GoRoute(
        path: '/assistant-dashboard',
        builder: (context, state) => AssistantDashboardScreen(),
      ),
      GoRoute(
        path: '/milk-production',
        builder: (context, state) =>  MilkProductionScreen(),
      ),
      GoRoute(
        path: '/health-issues',
        builder: (context, state) => HealthIssuesScreen(),
      ),
      GoRoute(
        path: '/raise-ticket',
        builder: (context, state) => RaiseTicketScreen(),
      ),
      GoRoute(
        path: '/create-transfer-ticket',
        builder: (context, state) =>  CreateTransferTicketScreen(),
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
