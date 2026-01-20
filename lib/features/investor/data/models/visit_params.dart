
import 'package:equatable/equatable.dart';

class VisitAvailabilityParams extends Equatable {
  final String date;
  final String location;

  const VisitAvailabilityParams({required this.date, required this.location});

  @override
  List<Object?> get props => [date, location];
}
