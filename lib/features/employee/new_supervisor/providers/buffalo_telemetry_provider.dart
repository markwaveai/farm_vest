import 'package:farm_vest/core/services/buffalofit_api_services.dart';
import 'package:farm_vest/features/employee/new_supervisor/data/models/buffalo_telemetry_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final buffaloTelemetryProvider =
    FutureProvider.family<BuffaloTelemetry, String>((ref, beltId) async {
      return BuffaloFitApiServices.getCattleDetails(beltId);
    });
