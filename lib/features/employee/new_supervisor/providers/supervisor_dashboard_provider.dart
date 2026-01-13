import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Data Models
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

// 2. State Class
class SupervisorDashboardState {
  final SupervisorDashboardStats stats;
  final List<SupervisorTask> tasks;
  final List<HealthConcern> healthConcerns;
  final bool isLoading;

  SupervisorDashboardState({
    required this.stats,
    this.tasks = const [],
    this.healthConcerns = const [],
    this.isLoading = false,
  });

  SupervisorDashboardState copyWith({
    SupervisorDashboardStats? stats,
    List<SupervisorTask>? tasks,
    List<HealthConcern>? healthConcerns,
    bool? isLoading,
  }) {
    return SupervisorDashboardState(
      stats: stats ?? this.stats,
      tasks: tasks ?? this.tasks,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 3. Notifier
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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data, replace with API calls
    final newStats = SupervisorDashboardStats(
      totalAnimals: '142',
      milkToday: '0L',
      activeIssues: '5',
      transfers: '1',
    );

    final newTasks = [
      SupervisorTask('Morning Feed Check', 'Pending'),
      SupervisorTask('Water Troughs Cleaning', 'Completed'),
    ];

    final newHealthConcerns = [
      HealthConcern('#BUF-889', 'High Temperature'),
      HealthConcern('#BUF-123', 'Not Eating'),
    ];

    state = state.copyWith(
      stats: newStats,
      tasks: newTasks,
      healthConcerns: newHealthConcerns,
      isLoading: false,
    );
  }
}

// 4. Provider
final supervisorDashboardProvider = NotifierProvider<
    SupervisorDashboardNotifier,
    SupervisorDashboardState>(
  SupervisorDashboardNotifier.new,
);
