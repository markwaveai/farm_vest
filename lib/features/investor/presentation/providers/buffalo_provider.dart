/// Buffalo Provider - Main Entry Point
///
/// **DEPRECATED**: This file is maintained for backward compatibility.
/// Please use the new modular provider structure instead.
///
/// **New Structure**:
/// ```
/// providers/
///   ├── filter/
///   │   ├── buffalo_filter_state.dart
///   │   └── buffalo_filter_notifier.dart
///   ├── data/
///   │   ├── investor_data_providers.dart
///   │   └── buffalo_list_providers.dart
///   ├── stats/
///   │   └── investor_stats_providers.dart
///   └── investor_providers.dart (barrel file)
/// ```
///
/// **Migration Guide**:
/// Instead of:
/// ```dart
/// import 'package:farm_vest/features/investor/presentation/providers/buffalo_provider.dart';
/// ```
///
/// Use:
/// ```dart
/// import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
/// ```
///
/// All providers remain the same, just better organized!

// Re-export all providers for backward compatibility
export 'investor_providers.dart';
