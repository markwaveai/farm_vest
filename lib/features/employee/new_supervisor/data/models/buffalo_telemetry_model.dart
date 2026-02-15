class BuffaloTelemetry {
  final String beltId;
  final int activity;
  final int rumination;
  final int chewing;
  final int idle;
  final int standing;
  final int sitting;
  final String healthAlert;
  final String heatAlert;

  BuffaloTelemetry({
    required this.beltId,
    required this.activity,
    required this.rumination,
    required this.chewing,
    required this.idle,
    required this.standing,
    required this.sitting,
    required this.healthAlert,
    required this.heatAlert,
  });

  factory BuffaloTelemetry.fromJson(Map<String, dynamic> json) {
    final cow = json['cow_detail'] ?? {};
    return BuffaloTelemetry(
      beltId: (cow['beltId'] ?? '').toString(),
      activity: (cow['activity'] ?? 0).toInt(),
      rumination: (cow['rumination'] ?? 0).toInt(),
      chewing: (cow['chewing'] ?? 0).toInt(),
      idle: (cow['idle'] ?? 0).toInt(),
      standing: (cow['standing'] ?? 0).toInt(),
      sitting: (cow['sitting'] ?? 0).toInt(),
      healthAlert: (cow['health_alert'] ?? 'No').toString(),
      heatAlert: (cow['heat_alert'] ?? 'No').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beltId': beltId,
      'activity': activity,
      'rumination': rumination,
      'chewing': chewing,
      'idle': idle,
      'standing': standing,
      'sitting': sitting,
      'health_alert': healthAlert,
      'heat_alert': heatAlert,
    };
  }
}
