import 'package:farm_vest/features/employee/new_supervisor/data/repositories/supervisor_repository.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String pendingAllocations;

  SupervisorDashboardStats({
    required this.totalAnimals,
    required this.milkToday,
    required this.activeIssues,
    required this.transfers,
    required this.pendingAllocations,
  });
}

// 2. State Class - Now includes checklist state
class SupervisorDashboardState {
  final SupervisorDashboardStats stats;
  final List<SupervisorTask> tasks;
  final List<HealthConcern> healthConcerns;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? animalLocation;
  final List<Map<String, dynamic>> animalSuggestions;

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
    this.animalLocation,
    this.animalSuggestions = const [],
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
    Map<String, dynamic>? animalLocation,
    List<Map<String, dynamic>>? animalSuggestions,
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
      animalLocation: animalLocation ?? this.animalLocation,
      animalSuggestions: animalSuggestions ?? this.animalSuggestions,
    );
  }
}

// Create a provider for the repository
final supervisorRepositoryProvider = Provider((ref) => SupervisorRepository());

// 3. Notifier - Now with methods to toggle checklist items
class SupervisorDashboardNotifier extends Notifier<SupervisorDashboardState> {
  @override
  SupervisorDashboardState build() {
    Future.microtask(() {
      _fetchData();
      ref.read(authProvider.notifier).refreshUserData();
    });
    return SupervisorDashboardState(
      isLoading: true,
      stats: SupervisorDashboardStats(
        totalAnimals: '0',
        milkToday: '0L',
        activeIssues: '0',
        transfers: '0',
        pendingAllocations: '0',
      ),
    );
  }

  Future<void> _fetchData() async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    try {
      final totalAnimals = await supervisorRepo.getTotalAnimals();
      final milkEntries = await supervisorRepo.getMilkEntries();
      final ticketsResponse = await supervisorRepo.getTickets();

      // Sum milk quantity for entries that match today's date
      final milkData = milkEntries['data'] as List<dynamic>? ?? [];
      final todayDate = DateTime.now();
      final todayDateString =
          "${todayDate.year}-${todayDate.month.toString().padLeft(2, '0')}-${todayDate.day.toString().padLeft(2, '0')}";

      final milkToday = milkData
          .where((entry) => entry['entry_date'] == todayDateString)
          .fold<double>(
            0.0,
            (previous, current) => previous + (current['quantity'] ?? 0),
          );

      // Filter tickets
      final allTickets = ticketsResponse['data'] as List<dynamic>? ?? [];
      final activeHealthIssues = allTickets
          .where(
            (t) => t['ticket_type'] == 'HEALTH' && t['status'] == 'PENDING',
          )
          .length;
      final transferRequests = allTickets
          .where(
            (t) => t['ticket_type'] == 'TRANSFER' && t['status'] == 'PENDING',
          )
          .length;

      // Fetch pending allocations
      int pendingCount = 0;
      try {
        final unallocated = await supervisorRepo.getUnallocatedAnimals(token);
        pendingCount = unallocated.length;
      } catch (e) {
        debugPrint('Error fetching unallocated animals: $e');
      }

      final newStats = SupervisorDashboardStats(
        totalAnimals: totalAnimals.toString(),
        milkToday: '${milkToday.toStringAsFixed(2)}L',
        activeIssues: activeHealthIssues.toString(),
        transfers: transferRequests.toString(),
        pendingAllocations: pendingCount.toString(),
      );

      state = state.copyWith(stats: newStats, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error fetching supervisor stats: $e');
      debugPrint(stackTrace.toString());
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch data. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>?> createTicket(Map<String, dynamic> body) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    try {
      final response = await supervisorRepo.createTicket(body: body);
      if (response['status'] == 'success') {
        await _fetchData(); // Refresh data after successful entry
        return response;
      }
      return null;
    } catch (e) {
      rethrow;
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

  Future<void> locateAnimal(String query) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    state = state.copyWith(isLoading: true, animalLocation: null, error: null);
    try {
      // 1. Search for animal by tag/query string
      final animals = await supervisorRepo.searchAnimals(query: query);
      if (animals.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No animal found with this tag $query.',
        );
        return;
      }

      // 2. Get the database ID of the first match
      // The search result from animal/search_animal has a structure: {'animal_details': {...}, ...}
      final animalId = animals.first['animal_details']['id'];

      if (animalId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not resolve animal ID $query.',
        );
        return;
      }

      // 3. Get its specific location
      final response = await supervisorRepo.getAnimalLocation(animalId);
      state = state.copyWith(
        animalLocation: response['data'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchSuggestions(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(animalSuggestions: []);
      return;
    }
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    try {
      final animals = await supervisorRepo.searchAnimals(query: query);
      state = state.copyWith(animalSuggestions: animals);
    } catch (e) {
      debugPrint('Error searching suggestions: $e');
    }
  }

  void clearSuggestions() {
    state = state.copyWith(animalSuggestions: []);
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
