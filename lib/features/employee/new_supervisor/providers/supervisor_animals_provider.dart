import 'package:farm_vest/features/employee/new_supervisor/providers/supervisor_dashboard_provider.dart';
import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final supervisorAnimalsProvider = FutureProvider<List<InvestorAnimal>>((
  ref,
) async {
  final repo = ref.read(supervisorRepositoryProvider);
  return await repo.searchAnimals();
});

final animalSearchQueryProvider = StateProvider<String>((ref) => 'all');

final searchedAnimalsProvider = FutureProvider<List<InvestorAnimal>>((
  ref,
) async {
  final repo = ref.read(supervisorRepositoryProvider);
  final query = ref.watch(animalSearchQueryProvider);
  return await repo.searchAnimals(query: query);
});
