/// Investor Providers Barrel File
///
/// This file exports all investor-related providers for easy importing.
/// Import this file instead of individual provider files.
///
/// Example:
/// ```dart
/// import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
///
/// // Now you can use any provider
/// final animals = ref.watch(investorAnimalsProvider);
/// final stats = ref.watch(buffaloStatsProvider);
/// final filterState = ref.watch(buffaloFilterProvider);
/// ```

// Filter providers
export 'filter/buffalo_filter_state.dart';
export 'filter/buffalo_filter_notifier.dart';

// Data providers
export 'data/investor_data_providers.dart';
export 'data/buffalo_list_providers.dart';

// Statistics providers
export 'stats/investor_stats_providers.dart';
