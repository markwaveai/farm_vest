class UnitResponse {
  final int? statusCode;
  final String? status;
  final String? userId;
  final List<Unit>? units;
  final Financials? financials;
  final CpfSummary? cpfSummary;
  final OverallStats? overallStats;

  UnitResponse({
    this.statusCode,
    this.status,
    this.userId,
    this.units,
    this.financials,
    this.cpfSummary,
    this.overallStats,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    return UnitResponse(
      statusCode: json['statuscode'],
      status: json['status'],
      userId: json['userId'],
      units: json['units'] != null
          ? List<Unit>.from(json['units'].map((x) => Unit.fromJson(x)))
          : [],
      financials: json['financials'] != null
          ? Financials.fromJson(json['financials'])
          : null,
      cpfSummary: json['cpfSummary'] != null
          ? CpfSummary.fromJson(json['cpfSummary'])
          : null,
      overallStats: json['overallStats'] != null
          ? OverallStats.fromJson(json['overallStats'])
          : null,
    );
  }
}

class Financials {
  final num? totalRevenueEarned;
  final num? investment;
  final num? netProfit;

  Financials({this.totalRevenueEarned, this.investment, this.netProfit});

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      totalRevenueEarned: json['totalRevenueEarned'],
      investment: json['investment'],
      netProfit: json['netProfit'],
    );
  }
}

class CpfSummary {
  final num? cpfAmountPerUnit;
  final num? totalUnits;
  final num? cpfTakenUnits;
  final num? cpfPendingUnits;
  final num? totalCpfValue;
  final num? cpfTakenValue;
  final num? cpfPendingValue;

  CpfSummary({
    this.cpfAmountPerUnit,
    this.totalUnits,
    this.cpfTakenUnits,
    this.cpfPendingUnits,
    this.totalCpfValue,
    this.cpfTakenValue,
    this.cpfPendingValue,
  });

  factory CpfSummary.fromJson(Map<String, dynamic> json) {
    return CpfSummary(
      cpfAmountPerUnit: json['cpfAmountPerUnit'],
      totalUnits: json['totalUnits'],
      cpfTakenUnits: json['cpfTakenUnits'],
      cpfPendingUnits: json['cpfPendingUnits'],
      totalCpfValue: json['totalCpfValue'],
      cpfTakenValue: json['cpfTakenValue'],
      cpfPendingValue: json['cpfPendingValue'],
    );
  }
}

class OverallStats {
  final num? totalUnits;
  final num? totalCalves;
  final num? pregnantBuffaloes;
  final num? healthyBuffaloes;
  final num? underTreatment;

  OverallStats({
    this.totalUnits,
    this.totalCalves,
    this.pregnantBuffaloes,
    this.healthyBuffaloes,
    this.underTreatment,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalUnits: json['totalUnits'],
      totalCalves: json['totalCalves'],
      pregnantBuffaloes: json['pregnantBuffaloes'],
      healthyBuffaloes: json['healthyBuffaloes'],
      underTreatment: json['underTreatment'],
    );
  }
}

class Unit {
  final String? id;
  final String? userId;
  final String? buffaloId;
  final int? numUnits;
  final int? buffaloCount;
  final int? calfCount;
  final String? status;
  final String? paymentStatus;
  final String? paymentType;
  final String? placedAt;
  final List<Animal>? buffalos;

  Unit({
    this.id,
    this.userId,
    this.buffaloId,
    this.numUnits,
    this.buffaloCount,
    this.calfCount,
    this.status,
    this.paymentStatus,
    this.paymentType,
    this.placedAt,
    this.buffalos,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      userId: json['userId'],
      buffaloId: json['buffaloId'],
      numUnits: json['numUnits'],
      buffaloCount: json['buffaloCount'],
      calfCount: json['calfCount'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      paymentType: json['paymentType'],
      placedAt: json['placedAt'],
      buffalos: json['buffalos'] != null
          ? List<Animal>.from(json['buffalos'].map((x) => Animal.fromJson(x)))
          : [],
    );
  }
}

class Animal {
  final String? id;
  final String? parentId;
  final String? breedId;
  final num? ageYears;
  final String? status;
  final String? type;
  final List<Animal>? children;

  Animal({
    this.id,
    this.parentId,
    this.breedId,
    this.ageYears,
    this.status,
    this.type,
    this.children,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      parentId: json['parentId'],
      breedId: json['breedId'],
      ageYears: json['ageYears'],
      status: json['status'],
      type: json['type'],
      children: json['children'] != null
          ? (json['children'] as List).map((i) => Animal.fromJson(i)).toList()
          : null,
    );
  }
}
