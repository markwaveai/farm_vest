import 'package:farm_vest/core/services/farm_manager_api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/staff_model.dart';


class StaffListState {
  final bool isLoading;
  final List<Staff> staff;
  final String? error;

  StaffListState({this.isLoading = false, this.staff = const [], this.error});

  StaffListState copyWith({
    bool? isLoading,
    List<Staff>? staff,
    String? error,
  }) {
    return StaffListState(
      isLoading: isLoading ?? this.isLoading,
      staff: staff ?? this.staff,
      error: error ?? this.error,
    );
  }
}


class StaffListNotifier extends StateNotifier<StaffListState> {
  StaffListNotifier() : super(StaffListState()) {
    loadStaff();
  }

  Future<void> loadStaff() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final staff = await FarmManagerApiServices.fetchStaff();

      state = state.copyWith(isLoading: false, staff: staff);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  
  void addStaff(Staff newStaff) {
    state = state.copyWith(staff: [...state.staff, newStaff]);
  }
}


final staffListProvider =
    StateNotifierProvider<StaffListNotifier, StaffListState>(
        (ref) => StaffListNotifier());


class MilkReportState {
  final bool isLoading;
  final dynamic data;
  final String? error;

  MilkReportState({
    this.isLoading = false,
    this.data,
    this.error,
  });
  factory MilkReportState.initial() {
    return MilkReportState(
      isLoading: false,
      data: null,
      error: null,
    );
  }

  MilkReportState copyWith({
    bool? isLoading,
    dynamic data,
    String? error,
  }) {
    return MilkReportState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class MilkReportNotifier extends StateNotifier<MilkReportState> {
  MilkReportNotifier() : super(MilkReportState.initial());
  void clear() {
    state = MilkReportState.initial();
  }

  Future<void> getDailyReport({
    required String date,
    required String timing,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await FarmManagerApiServices.fetchMilkReport(
        reportDate: date,
        timing: timing,
        entryFrequency: "DAILY",
      );

      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getWeeklyReport({
    required String date,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await FarmManagerApiServices.fetchMilkReport(
        reportDate: date,
        entryFrequency: "WEEKLY",
      );

      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final milkReportProvider =
    StateNotifierProvider<MilkReportNotifier, MilkReportState>(
  (ref) => MilkReportNotifier(),
);



