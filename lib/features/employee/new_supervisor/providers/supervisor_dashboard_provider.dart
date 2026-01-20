import 'package:farm_vest/features/employee/new_supervisor/data/repositories/supervisor_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Data Models (unchanged)
class SupervisorTask {
  final String title;
  final String subtitle;
  SupervisorTask(this.title, this.subtitle);
}

class HealthConcern {
  final String title;
  final String subtitle;
  HealthConcern(this.title, this.subtitle);
}

class SupervisorDashboardStats {
  final String totalAnimals;
  final String milkToday;
  final String activeIssues;
  final String transfers;

  SupervisorDashboardStats({
    required this.totalAnimals,
    required this.milkToday,
    required this.activeIssues,
    required this.transfers,
  });
}


// 2. State Class - Now includes checklist state
class SupervisorDashboardState {
  final SupervisorDashboardStats stats;
  final List<SupervisorTask> tasks;
  final List<HealthConcern> healthConcerns;
  final bool isLoading;
  final String? error;

  // Checklist state
  final bool morningFeed;
  final bool waterCleaning;
  final bool shedWash;
  final bool eveningMilking;


  SupervisorDashboardState({
    required this.stats,
    this.tasks = const [],
    this.healthConcerns = const [],
    this.isLoading = false,
    this.morningFeed = true,
    this.waterCleaning = true,
    this.shedWash = false,
    this.eveningMilking = false,
    this.error,
  });

  SupervisorDashboardState copyWith({
    SupervisorDashboardStats? stats,
    List<SupervisorTask>? tasks,
    List<HealthConcern>? healthConcerns,
    bool? isLoading,
    bool? morningFeed,
    bool? waterCleaning,
    bool? shedWash,
    bool? eveningMilking,
    String? error,
  }) {
    return SupervisorDashboardState(
      stats: stats ?? this.stats,
      tasks: tasks ?? this.tasks,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      isLoading: isLoading ?? this.isLoading,
      morningFeed: morningFeed ?? this.morningFeed,
      waterCleaning: waterCleaning ?? this.waterCleaning,
      shedWash: shedWash ?? this.shedWash,
      eveningMilking: eveningMilking ?? this.eveningMilking,
      error: error ?? this.error,
    );
  }
}

// Create a provider for the repository
final supervisorRepositoryProvider = Provider((ref) => SupervisorRepository());

// 3. Notifier - Now with methods to toggle checklist items
class SupervisorDashboardNotifier extends Notifier<SupervisorDashboardState> {
  @override
  SupervisorDashboardState build() {
    Future.microtask(() => _fetchData());
    return SupervisorDashboardState(
      isLoading: true,
      stats: SupervisorDashboardStats(
        totalAnimals: '0',
        milkToday: '0L',
        activeIssues: '0',
        transfers: '0',
      ),
    );
  }

  Future<void> _fetchData() async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);

    try {
      final totalAnimals = await supervisorRepo.getTotalAnimals();
      final milkEntries = await supervisorRepo.getMilkEntries();

      final milkToday = milkEntries['total_milk_quantity'] ?? 0;

      final newStats = SupervisorDashboardStats(
        totalAnimals: totalAnimals.toString(),
        milkToday: '${milkToday.toString()}L',
        activeIssues: '0', // Placeholder until API is available
        transfers: '0', // Placeholder until API is available
      );

      state = state.copyWith(stats: newStats, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error fetching supervisor stats: $e');
      debugPrint(stackTrace.toString());
      state = state.copyWith(isLoading: false, error: 'Failed to fetch data. Please try again.');
    }
  }

  Future<Map<String, dynamic>?> createMilkEntry({
    required String timing,
    required String quantity,
  }) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    try {
      final response = await supervisorRepo.createMilkEntry(
        timing: timing,
        quantity: quantity,
      );
      if (response['status'] == 'success') {
        await _fetchData(); // Refresh data after successful entry
        return response;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Methods to update checklist state
  void toggleMorningFeed(bool value) =>
      state = state.copyWith(morningFeed: value);
  void toggleWaterCleaning(bool value) =>
      state = state.copyWith(waterCleaning: value);
  void toggleShedWash(bool value) => state = state.copyWith(shedWash: value);
  void toggleEveningMilking(bool value) =>
      state = state.copyWith(eveningMilking: value);

}

final supervisorDashboardProvider =
    NotifierProvider<SupervisorDashboardNotifier, SupervisorDashboardState>(
      SupervisorDashboardNotifier.new,
    );
