import 'package:farm_vest/features/employee/new_supervisor/data/models/leave_request_model.dart';
import 'package:farm_vest/features/employee/new_supervisor/data/repositories/supervisor_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveRequestState {
  final bool isLoading;
  final String? error;
  final List<LeaveRequest> leaveRequests;

  LeaveRequestState({
    this.isLoading = false,
    this.error,
    this.leaveRequests = const [],
  });

  LeaveRequestState copyWith({
    bool? isLoading,
    String? error,
    List<LeaveRequest>? leaveRequests,
  }) {
    return LeaveRequestState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      leaveRequests: leaveRequests ?? this.leaveRequests,
    );
  }
}

final supervisorRepositoryProvider = Provider((ref) => SupervisorRepository());

class LeaveRequestNotifier extends Notifier<LeaveRequestState> {
  @override
  LeaveRequestState build() {
    return LeaveRequestState();
  }

  Future<void> getLeaveRequests() async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    state = state.copyWith(isLoading: true);
    try {
      final response = await supervisorRepo.getLeaveRequests();
      final data = response['data'] as List;
      final leaveRequests =
          data.map((e) => LeaveRequest.fromJson(e)).toList();
      state = state.copyWith(leaveRequests: leaveRequests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> createLeaveRequest({
    required String startDate,
    required String endDate,
    required String leaveType,
    required String reason,
  }) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    state = state.copyWith(isLoading: true);
    try {
      final response = await supervisorRepo.createLeaveRequest(
        startDate: startDate,
        endDate: endDate,
        leaveType: leaveType,
        reason: reason,
      );
      state = state.copyWith(isLoading: false);
      await getLeaveRequests(); // Refresh the list after creating a new request
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> cancelLeaveRequest(int id) async {
    final supervisorRepo = ref.read(supervisorRepositoryProvider);
    state = state.copyWith(isLoading: true);
    try {
      await supervisorRepo.cancelLeaveRequest(id);
      await getLeaveRequests(); // Refresh the list after cancelling
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final leaveRequestProvider =
    NotifierProvider<LeaveRequestNotifier, LeaveRequestState>(
  LeaveRequestNotifier.new,
);
