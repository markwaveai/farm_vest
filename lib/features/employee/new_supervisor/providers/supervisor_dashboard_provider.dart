import 'package:farm_vest/features/employee/new_supervisor/data/repositories/supervisor_repository.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:farm_vest/features/admin/data/models/ticket_model.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
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
  final String allTicketsCount;

  SupervisorDashboardStats({
    required this.totalAnimals,
    required this.milkToday,
    required this.activeIssues,
    required this.transfers,
    required this.pendingAllocations,
    required this.allTicketsCount,
  });
}

// 2. State Class - Now includes checklist state
class SupervisorDashboardState {
  final SupervisorDashboardStats stats;
  final List<SupervisorTask> tasks;
  final List<HealthConcern> healthConcerns;
  final bool isLoading;
  final bool isLocatingAnimal;
  final String? error;
  final Map<String, dynamic>? animalLocation;
  final List<InvestorAnimal> animalSuggestions;

  // Checklist state
  final bool morningFeed;
  final bool waterCleaning;
  final bool shedWash;
  final bool eveningMilking;

  final List<Map<String, dynamic>> unallocatedAnimals;

  SupervisorDashboardState({
    required this.stats,
    this.tasks = const [],
    this.healthConcerns = const [],
    this.isLoading = false,
    this.isLocatingAnimal = false,
    this.morningFeed = true,
    this.waterCleaning = true,
    this.shedWash = false,
    this.eveningMilking = false,
    this.error,
    this.animalLocation,
    this.animalSuggestions = const [],
    this.unallocatedAnimals = const [],
  });

  SupervisorDashboardState copyWith({
    SupervisorDashboardStats? stats,
    List<SupervisorTask>? tasks,
    List<HealthConcern>? healthConcerns,
    bool? isLoading,
    bool? isLocatingAnimal,
    bool? morningFeed,
    bool? waterCleaning,
    bool? shedWash,
    bool? eveningMilking,
    String? error,
    Map<String, dynamic>? animalLocation,
    List<InvestorAnimal>? animalSuggestions,
    List<Map<String, dynamic>>? unallocatedAnimals,
  }) {
    return SupervisorDashboardState(
      stats: stats ?? this.stats,
      tasks: tasks ?? this.tasks,
      healthConcerns: healthConcerns ?? this.healthConcerns,
      isLoading: isLoading ?? this.isLoading,
      isLocatingAnimal: isLocatingAnimal ?? this.isLocatingAnimal,
      morningFeed: morningFeed ?? this.morningFeed,
      waterCleaning: waterCleaning ?? this.waterCleaning,
      shedWash: shedWash ?? this.shedWash,
      eveningMilking: eveningMilking ?? this.eveningMilking,
      error: error ?? this.error,
      animalLocation: animalLocation ?? this.animalLocation,
      animalSuggestions: animalSuggestions ?? this.animalSuggestions,
      unallocatedAnimals: unallocatedAnimals ?? this.unallocatedAnimals,
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
        allTicketsCount: '0',
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
      final transfersResponse = await supervisorRepo.getTransferTickets();
      final allTicketsCount = await supervisorRepo.getTicketsCount();

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
      final List<Ticket> allTickets = List<Ticket>.from(
        ticketsResponse['data'] ?? [],
      );
      final activeHealthIssues = allTickets.where((t) {
        final type = TicketType.fromString(t.ticketType);
        final status = TicketStatus.fromString(t.status);
        return type == TicketType.health && status == TicketStatus.pending;
      }).length;

      final List<Ticket> transferTickets = List<Ticket>.from(
        transfersResponse['data'] ?? [],
      );
      final transferRequests = transferTickets.where((t) {
        final status = TicketStatus.fromString(t.status);
        return status == TicketStatus.pending;
      }).length;

      // Fetch pending allocations
      int pendingCount = 0;
      List<Map<String, dynamic>> unallocatedList = [];
      try {
        final unallocated = await supervisorRepo.getUnallocatedAnimals(token);
        unallocatedList = List<Map<String, dynamic>>.from(unallocated);
        pendingCount = unallocatedList.length;
      } catch (e) {
        debugPrint('Error fetching unallocated animals: $e');
      }

      final newStats = SupervisorDashboardStats(
        totalAnimals: totalAnimals.toString(),
        milkToday: '${milkToday.toStringAsFixed(2)}L',
        activeIssues: activeHealthIssues.toString(),
        transfers: transferRequests.toString(),
        pendingAllocations: pendingCount.toString(),
        allTicketsCount: allTicketsCount.toString(),
      );

      state = state.copyWith(
        stats: newStats,
        isLoading: false,
        unallocatedAnimals: unallocatedList,
      );
    } catch (e, stackTrace) {
      debugPrint('Error fetching supervisor stats: $e');
      debugPrint(stackTrace.toString());
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch data. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>?> createTicket(
    Map<String, dynamic> body, {
    String ticketType = 'HEALTH',
  }) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    try {
      final response = await supervisorRepo.createTicket(
        body: body,
        ticketType: ticketType,
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

  Future<Map<String, dynamic>?> createTransferTicket(
    Map<String, dynamic> body,
  ) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    try {
      final response = await supervisorRepo.createTransferTicket(body: body);
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
    required int animalId,
    String? date,
  }) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    try {
      final response = await supervisorRepo.createMilkEntry(
        timing: timing,
        quantity: quantity,
        animalId: animalId,
        date: date,
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

  Future<Map<String, dynamic>?> createDistributedMilkEntry({
    required List<String> dates,
    required String timing,
    required String totalQuantity,
  }) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    try {
      final response = await supervisorRepo.createDistributedMilkEntry(
        dates: dates,
        timing: timing,
        totalQuantity: totalQuantity,
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
    state = state.copyWith(
      isLocatingAnimal: true,
      animalLocation: null,
      error: null,
    );
    try {
      // 1. Search for animal by tag/query string
      final animals = await supervisorRepo.searchAnimals(query: query);
      if (animals.isEmpty) {
        state = state.copyWith(
          isLocatingAnimal: false,
          error: 'No animal found with this tag $query.',
        );
        return;
      }

      // 2. Extract location directly from search result
      // Prioritize exact match if multiple results found
      final q = query.trim().toLowerCase();
      final animal = animals.firstWhere((a) {
        final rfid = (a.rfid ?? '').toLowerCase();
        final ear = (a.earTagId ?? '').toLowerCase();
        final aid = a.animalId.toLowerCase();
        return rfid == q || ear == q || aid == q;
      }, orElse: () => animals.first);

      final Map<String, dynamic> locationData = {
        'shed_id': animal.shedId,
        'shed_name': animal.shedName,
        'row_number': animal.rowNumber,
        'parking_id': animal.parkingId,
        'health_status': animal.healthStatus,
      };

      state = state.copyWith(
        animalLocation: locationData,
        isLocatingAnimal: false,
      );
    } catch (e) {
      state = state.copyWith(isLocatingAnimal: false, error: e.toString());
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
