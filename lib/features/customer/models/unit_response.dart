class UnitResponse {
  final int? statusCode;
  final String? status;
  final String? userId;
  final String? userCreatedAt;
  final List<Order>? orders;
  final Financials? financials;
  final CpfSummary? cpfSummary;
  final OverallStats? overallStats;

  UnitResponse({
    this.statusCode,
    this.status,
    this.userId,
    this.userCreatedAt,
    this.orders,
    this.financials,
    this.cpfSummary,
    this.overallStats,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    return UnitResponse(
      statusCode: json['statuscode'],
      status: json['status'],
      userId: json['userId'],
      userCreatedAt: json['userCreatedAt'],
      orders: json['orders'] != null
          ? List<Order>.from(json['orders'].map((x) => Order.fromJson(x)))
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
  final num? investmentWithCPF;
  final num? investmentWithoutCPF;
  final num? totalCpfValue;
  final num? netProfit;

  Financials({
    this.totalRevenueEarned,
    this.investmentWithCPF,
    this.investmentWithoutCPF,
    this.totalCpfValue,
    this.netProfit,
  });

  factory Financials.fromJson(Map<String, dynamic> json) {
    return Financials(
      totalRevenueEarned: json['totalRevenueEarned'],
      investmentWithCPF: json['investmentWithCPF'],
      investmentWithoutCPF: json['investmentWithoutCPF'],
      totalCpfValue: json['totalCpfValue'],
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
  final num? buffaloesCount;
  final num? calvesCount;
  final num? pregnantBuffaloes;
  final num? healthyBuffaloes;
  final num? underTreatment;
  final num? totalAssetValue;

  OverallStats({
    this.totalUnits,
    this.buffaloesCount,
    this.calvesCount,
    this.pregnantBuffaloes,
    this.healthyBuffaloes,
    this.underTreatment,
    this.totalAssetValue,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalUnits: json['totalUnits'],
      buffaloesCount: json['buffaloesCount'],
      calvesCount: json['calvesCount'],
      pregnantBuffaloes: json['pregnantBuffaloes'],
      healthyBuffaloes: json['healthyBuffaloes'],
      underTreatment: json['underTreatment'],
      totalAssetValue: json['totalAssetValue'],
    );
  }
}

class Order {
  final String? id;
  final String? userId;
  final String? userCreatedAt;
  final String? paymentSessionDate;
  final String? breedId;
  final int? numUnits;
  final int? buffaloCount;
  final int? calfCount;
  final String? status;
  final String? paymentStatus;
  final String? paymentType;
  final String? placedAt;
  final String? approvalDate;
  final num? baseUnitCost;
  final num? cpfUnitCost;
  final num? unitCost;
  final num? totalCost;
  final bool? withCpf;
  final List<Animal>? buffalos;

  Order({
    this.id,
    this.userId,
    this.userCreatedAt,
    this.paymentSessionDate,
    this.breedId,
    this.numUnits,
    this.buffaloCount,
    this.calfCount,
    this.status,
    this.paymentStatus,
    this.paymentType,
    this.placedAt,
    this.approvalDate,
    this.baseUnitCost,
    this.cpfUnitCost,
    this.unitCost,
    this.totalCost,
    this.withCpf,
    this.buffalos,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      userCreatedAt: json['userCreatedAt'],
      paymentSessionDate: json['paymentSessionDate'],
      breedId: json['breedId'],
      numUnits: json['numUnits'],
      buffaloCount: json['buffaloCount'],
      calfCount: json['calfCount'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      paymentType: json['paymentType'],
      placedAt: json['placedAt'],
      approvalDate: json['approvalDate'],
      baseUnitCost: json['baseUnitCost'],
      cpfUnitCost: json['cpfUnitCost'],
      unitCost: json['unitCost'],
      totalCost: json['totalCost'],
      withCpf: json['withCpf'],
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
  final String? cpfDueDate;
  final String? expectedMaturationDate;
  final String? shedNumber;
  final String? farmName;
  final String? farmLocation;
  final String? healthStatus;
  final num? assetValue;
  final List<Animal>? children;

  Animal({
    this.id,
    this.parentId,
    this.breedId,
    this.ageYears,
    this.status,
    this.type,
    this.cpfDueDate,
    this.expectedMaturationDate,
    this.shedNumber,
    this.farmName,
    this.farmLocation,
    this.healthStatus,
    this.assetValue,
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
      cpfDueDate: json['cpfDueDate'],
      expectedMaturationDate: json['expectedMaturationDate'],
      shedNumber: json['shedNumber'],
      farmName: json['farmName'],
      farmLocation: json['farmLocation'],
      healthStatus: json['healthStatus'],
      assetValue: json['assetValue'],
      children: json['children'] != null
          ? (json['children'] as List).map((i) => Animal.fromJson(i)).toList()
          : null,
    );
  }
}
