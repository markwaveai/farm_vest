import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/buffalo_list_section.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/dashboard_stats_card.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/monthly_visit_card.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/search_and_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvestorDashboardScreen extends ConsumerStatefulWidget {
  const InvestorDashboardScreen({super.key});

  @override
  ConsumerState<InvestorDashboardScreen> createState() =>
      _InvestorDashboardScreenState();
}

class _InvestorDashboardScreenState
    extends ConsumerState<InvestorDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Force refresh data on screen load to ensure freshness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    ref.invalidate(investorSummaryProvider);
    ref.invalidate(investorAnimalsProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes to fetch data once user is available
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.mobileNumber != next.mobileNumber &&
          next.mobileNumber != null) {
        // Defer invalidation until after build completes
        Future.microtask(() => _refreshData());
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshData();
            // Wait for data to refresh (optional, as providers handle loading state)
            await Future.delayed(const Duration(seconds: 1));
          },
          child: Column(
            children: const [
              // Consolidated Stats & Financial Overview
              DashboardStatsCard(),

              // Monthly Visits Card
              MonthlyVisitCard(),

              // Search & Filter
              SearchAndFilterBar(),

              // Buffalo List Section (Header + List/Grid)
              Expanded(child: BuffaloListSection()),
            ],
          ),
        ),
      ),
    );
  }
}
