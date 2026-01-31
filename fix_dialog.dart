// import 'dart:io';

// void main() {
//   final file = File(
//     '/Users/admin/markwave workspace/farm_vest/lib/features/employee/new_supervisor/widgets/alert_dialog.dart',
//   );
//   String content = file.readAsStringSync();

//   // Fix imports
//   if (!content.contains(
//     "import 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';",
//   )) {
//     content = content.replaceFirst(
//       "import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';",
//       "import 'package:farm_vest/features/auth/data/repositories/auth_repository.dart';\nimport 'package:farm_vest/features/investor/data/models/investor_animal_model.dart';",
//     );
//   }

//   // Replace animal retrieval
//   content = content.replaceAll(
//     "final animal =\n                                              suggestions[index]['animal_details'];",
//     "final animal = suggestions[index];",
//   );

//   // Replace tag retrieval
//   content = content.replaceAll(
//     "final tag =\n                                              animal['rfid_tag_number'] ??\n                                              animal['ear_tag'] ??\n                                              animal['animal_id'];",
//     "final tag = animal.rfid ??\n                                              animal.earTag ??\n                                              animal.animalId;",
//   );

//   // Replace subtitle
//   // We use simple string matching here, escaping $ in the pattern
//   content = content.replaceAll(
//     "'ID: \${animal['animal_id']} • Row: \${animal['row_number'] ?? 'N/A'}'",
//     "'ID: \${animal.animalId} • Row: \${animal.rowNumber ?? 'N/A'}'",
//   );

//   // Replace ID assignment
//   content = content.replaceAll(
//     "_selectedAnimalId =\n                                                    animal['id'];",
//     "_selectedAnimalId =\n                                                    animal.internalId;",
//   );

//   // Fix fallback lookup (line ~435)
//   // final details = animals.first['animal_details'];
//   // finalAnimalId = details['id'];
//   // finalAnimalRfid = details['rfid_tag_number'];

//   content = content.replaceAll(
//     "final details = animals.first['animal_details'];",
//     "final animal = animals.first;",
//   );

//   content = content.replaceAll(
//     "finalAnimalId = details['id'];",
//     "finalAnimalId = animal.internalId;",
//   );

//   content = content.replaceAll(
//     "finalAnimalRfid = details['rfid_tag_number'];",
//     "finalAnimalRfid = animal.rfid;",
//   );

//   file.writeAsStringSync(content);
//   print('File updated');
// }
