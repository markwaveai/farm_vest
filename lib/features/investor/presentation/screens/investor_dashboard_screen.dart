import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:farm_vest/features/investor/presentation/screens/buffalo_calves_screen.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/buffalo_card.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/dashboard_stats_card.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/monthly_visit_card.dart';
import 'package:farm_vest/features/investor/presentation/widgets/dashboard/search_and_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvestorDashboardScreen extends ConsumerStatefulWidget {
  const InvestorDashboardScreen({super.key});

  @override
  ConsumerState<InvestorDashboardScreen> createState() =>
      _InvestorDashboardScreenState();
}

class _InvestorDashboardScreenState
    extends ConsumerState<InvestorDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isGridView = true;

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
    ref.invalidate(rawBuffaloListProvider);
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

    final theme = Theme.of(context);
    final buffalosAsync = ref.watch(filteredBuffaloListProvider);

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshData();
            // Wait for data to refresh (optional, as providers handle loading state)
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Consolidated Stats & Financial Overview
              SliverToBoxAdapter(child: DashboardStatsCard()),

              // Monthly Visits Card
              SliverToBoxAdapter(child: MonthlyVisitCard()),

              // Search & Filter
              SliverToBoxAdapter(child: SearchAndFilterBar()),

              // "My Buffaloes" Header and Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ('My Buffaloes'.tr),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                        onPressed: () {
                          setState(() {
                            _isGridView = !_isGridView;
                          });
                        },
                        tooltip: _isGridView
                            ? 'Switch to List View'
                            : 'Switch to Grid View',
                      ),
                    ],
                  ),
                ),
              ),

              // Buffalo List/Grid Content
              buffalosAsync.when(
                data: (data) {
                  if (data.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('No buffaloes found'.tr)),
                    );
                  }

                  if (_isGridView) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(8),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.65,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final buffalo = data[index];
                          // Grid View
                          return BuffaloCard(
                            animal: buffalo,
                            isGridView: true,
                            onTap: () {
                              context.push(
                                '/unit-details',
                                extra: {'buffalo': buffalo},
                              );
                            },
                            onInvoiceTap: () async {
                              _handleInvoiceTap(context, ref, buffalo.rfid);
                            },
                            onCalvesTap: () async {
                              _handleCalvesTap(context, buffalo);
                            },
                          );
                        }, childCount: data.length),
                      ),
                    );
                  } else {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final buffalo = data[index];
                          // List View
                          return BuffaloCard(
                            animal: buffalo,
                            isGridView: false,
                            onTap: () {
                              context.push(
                                '/unit-details',
                                extra: {'buffalo': buffalo},
                              );
                            },
                            onInvoiceTap: () async {
                              _handleInvoiceTap(context, ref, buffalo.rfid);
                            },
                            onCalvesTap: () async {
                              _handleCalvesTap(context, buffalo);
                            },
                          );
                        }, childCount: data.length),
                      ),
                    );
                  }
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: ${err.toString()}')),
                ),
              ),

              // Bottom padding
              // const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleInvoiceTap(
    BuildContext context,
    WidgetRef ref,
    String? buffaloId,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invoice feature coming soon available".tr)),
    );
  }

  Future<void> _handleCalvesTap(
    BuildContext context,
    InvestorAnimal parent,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      if (mounted) ToastUtils.showError(context, "Authentication error");
      return;
    }

    if (!context.mounted) return;
    ToastUtils.showInfo(context, "Fetching calves".tr);

    try {
      final response = await AnimalApiServices.getCalves(
        token: token,
        animalId: parent.animalId,
      );

      if (!context.mounted) return;

      final List<InvestorAnimal> calves = response.data;

      if (calves.isEmpty) {
        ToastUtils.showInfo(context, "No calves found for this buffalo".tr);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuffaloCalvesScreen(
            parentId: parent.animalId,
            parent: parent,
            calves: calves,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, "Failed to fetch calves: $e".tr);
      }
    }
  }
}
