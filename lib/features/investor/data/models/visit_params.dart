class VisitAvailabilityParams {
  final String date;
  final int farmId;

  const VisitAvailabilityParams({required this.date, required this.farmId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitAvailabilityParams &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          farmId == other.farmId;

  @override
  int get hashCode => date.hashCode ^ farmId.hashCode;
}
