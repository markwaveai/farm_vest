import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/services/visits_api_services.dart';
import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';
import 'package:farm_vest/features/investor/data/models/visit_model.dart';
import 'package:farm_vest/features/investor/data/models/visit_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final investorFarmsProvider = FutureProvider<List<InvestorFarm>>((ref) async {
  final repository = AuthRepository();
  final token = await repository.getToken();
  return VisitsApiServices.getInvestorFarms(token!);
});

final visitAvailabilityProvider =
    FutureProvider.family<VisitAvailability, VisitAvailabilityParams>((
      ref,
      params,
    ) async {
      final repository = AuthRepository();
      final token = await repository.getToken();
      return VisitsApiServices.getVisitAvailability(
        date: params.date,
        farmId: params.farmId,
        token: token!,
      );
    });

final myVisitsProvider = FutureProvider<List<Visit>>((ref) async {
  final repository = AuthRepository();
  final token = await repository.getToken();
  return VisitsApiServices.getMyVisits(token!);
});
