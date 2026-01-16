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
    );
  }
}

// 3. Notifier - Now with methods to toggle checklist items
class SupervisorDashboardNotifier extends Notifier<SupervisorDashboardState> {
  @override
  SupervisorDashboardState build() {
    _fetchData();
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
    await Future.delayed(const Duration(seconds: 1));
    final newStats = SupervisorDashboardStats(
      totalAnimals: '142',
      milkToday: '0L',
      activeIssues: '5',
      transfers: '1',
    );
    state = state.copyWith(stats: newStats, isLoading: false);
  }

  // Methods to update checklist state
  void toggleMorningFeed(bool value) => state = state.copyWith(morningFeed: value);
  void toggleWaterCleaning(bool value) => state = state.copyWith(waterCleaning: value);
  void toggleShedWash(bool value) => state = state.copyWith(shedWash: value);
  void toggleEveningMilking(bool value) => state = state.copyWith(eveningMilking: value);
}

// 4. Provider (unchanged)
final supervisorDashboardProvider = NotifierProvider<
    SupervisorDashboardNotifier,
    SupervisorDashboardState>(
  SupervisorDashboardNotifier.new,
);
