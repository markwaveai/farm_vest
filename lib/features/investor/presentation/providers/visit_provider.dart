import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/features/investor/data/models/visit_model.dart';
import 'package:farm_vest/features/investor/data/models/visit_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';

// Provider for fetching user's visits history
final myVisitsProvider = FutureProvider.autoDispose<List<Visit>>((ref) async {
  final authState = ref.watch(authProvider);
  final mobile = authState.mobileNumber;
  if (mobile == null) return [];
  return await ApiServices.getMyVisits(mobile);
});

// Provider for availability - using family to pass date and location
// params: {'date': 'YYYY-MM-DD', 'location': 'Kurnool'}
// params: VisitAvailabilityParams
final visitAvailabilityProvider = FutureProvider.family
    .autoDispose<VisitAvailability?, VisitAvailabilityParams>((
      ref,
      params,
    ) async {
      return await ApiServices.getVisitAvailability(
        date: params.date,
        location: params.location,
      );
    });
