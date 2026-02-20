import 'package:farm_vest/core/models/ticket_model.dart';
import 'package:farm_vest/core/services/animal_api_services.dart';
import 'package:farm_vest/features/auth/presentation/providers/auth_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final animalSearchQueryProvider = StateProvider<String>((ref) => "all");

final supervisorAnimalsProvider = FutureProvider<List<InvestorAnimal>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final token = await ref.read(authProvider.notifier).getToken();
  final query = ref.watch(animalSearchQueryProvider);

  if (token == null) return [];

  // Get shedId from logged in supervisor
  final shedIdStr = authState.userData?.shedId;
  final shedId = (shedIdStr != null && shedIdStr.isNotEmpty)
      ? int.tryParse(shedIdStr)
      : null;

  if (query == "all") {
    final response = await AnimalApiServices.getPagedAnimals(
      token: token,
      shedId: shedId,
      page: 1,
      size: 100, // Fetch a larger batch for the initial list
    );
    return response.data;
  } else {
    // Search logic
    return await AnimalApiServices.searchAnimals(
      token: token,
      query: query,
      // Search API doesn't seem to support shed_id filter yet based on AnimalApiServices.searchAnimals
      // But we can filter locally or update Search API if needed.
      // For now, let's filter locally if shedId is present.
    ).then((animals) {
      if (shedId != null) {
        return animals.where((a) => a.shedId == shedId).toList();
      }
      return animals;
    });
  }
});

// Alias for search filter provider to match what BuffaloProfileView expects
final searchedAnimalsProvider = supervisorAnimalsProvider;
