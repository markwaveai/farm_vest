import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The simulation logic appears to be missing from the project, likely from a
// commented-out package 'buffalo_visualizer'. This provider uses a mock
// implementation of the simulation.
// To make this screen functional, the actual simulation logic needs to be
// integrated into the _runSimulation function.
Future<Map<String, Map<String, dynamic>>> _runSimulation({
  double units = 1.0,
}) async {
  await Future.delayed(
    const Duration(milliseconds: 800),
  ); // Simulate async work

  // This data structure is based on what AssetValuationScreen expects.
  // The real simulation would populate 'buffaloes' and 'yearlyData'.
  return {
    'treeData': {
      'units': units,
      'buffaloes': [],
      'startYear': DateTime.now().year,
      'years': 10,
      'totalBuffaloes': 0,
    },
    'revenueData': {'totalRevenue': 0.0, 'yearlyData': []},
  };
}

class SimulationState {
  final bool isLoading;
  final Map<String, dynamic>? treeData;
  final Map<String, dynamic>? revenueData;
  final double units;
  final String? error;

  SimulationState({
    this.isLoading = false,
    this.treeData,
    this.revenueData,
    this.units = 1.0,
    this.error,
  });

  SimulationState copyWith({
    bool? isLoading,
    Map<String, dynamic>? treeData,
    Map<String, dynamic>? revenueData,
    double? units,
    String? error,
    bool clearError = false,
  }) {
    return SimulationState(
      isLoading: isLoading ?? this.isLoading,
      treeData: treeData ?? this.treeData,
      revenueData: revenueData ?? this.revenueData,
      units: units ?? this.units,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SimulationNotifier extends Notifier<SimulationState> {
  @override
  SimulationState build() {
    // Automatically trigger simulation with default units
    Future.microtask(() => _runSimulationForState(1.0));
    return SimulationState(isLoading: true);
  }

  Future<void> _runSimulationForState(double units) async {
    try {
      final simulationResult = await _runSimulation(units: units);

      state = state.copyWith(
        isLoading: false,
        treeData: simulationResult['treeData'],
        revenueData: simulationResult['revenueData'],
        units: units,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSettings({double? units}) {
    final newUnits = units ?? state.units;
    // Only run if units change or if there's no data yet.
    if (newUnits != state.units || state.treeData == null) {
      state = state.copyWith(isLoading: true, units: newUnits);
      _runSimulationForState(newUnits);
    }
  }
}

final simulationProvider =
    NotifierProvider<SimulationNotifier, SimulationState>(
      SimulationNotifier.new,
    );
