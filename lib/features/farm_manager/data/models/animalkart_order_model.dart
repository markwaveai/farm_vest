class AnimalkartOrder {
  final OrderInfo order;
  final TransactionInfo transaction;
  final InvestorInfo investor;

  AnimalkartOrder({
    required this.order,
    required this.transaction,
    required this.investor,
  });

  factory AnimalkartOrder.fromOrderAndUser(
    Map<String, dynamic> orderJson,
    Map<String, dynamic> userJson,
  ) {
    return AnimalkartOrder(
      order: OrderInfo.fromJson(orderJson),
      transaction: TransactionInfo.fromJson(orderJson),
      investor: InvestorInfo.fromJson(userJson),
    );
  }

  factory AnimalkartOrder.fromJson(Map<String, dynamic> json) {
    // Legacy support or fallback if needed
    return AnimalkartOrder(
      order: OrderInfo.fromJson(json['order'] ?? json),
      transaction: TransactionInfo.fromJson(json['transaction'] ?? json),
      investor: InvestorInfo.fromJson(json['investor'] ?? {}),
    );
  }
}

class OrderInfo {
  final String id;
  final String breedId;
  final int buffaloCount;
  final int calfCount;
  final int inTransitBuffaloCount;
  final int inTransitCalfCount;
  final int? numUnits;
  final double totalCost;
  final String status;
  final String placedAt;
  final List<String> buffaloIds;
  final List<String> calfIds;

  OrderInfo({
    required this.id,
    required this.breedId,
    required this.buffaloCount,
    required this.calfCount,
    required this.inTransitBuffaloCount,
    required this.inTransitCalfCount,
    this.numUnits,
    required this.totalCost,
    required this.status,
    required this.placedAt,
    this.buffaloIds = const [],
    this.calfIds = const [],
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    final buffaloIds =
        (json['buffaloIds'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final calfIds =
        (json['calfIds'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final numUnits = json['numUnits']?.toInt();

    // Prioritize in_transist fields if available, otherwise use buffaloIds.length or numUnits
    final transitBuf =
        (json['in_transist_buffaloes_count'] ??
                json['in_transit_buffaloes_count'] ??
                (buffaloIds.isNotEmpty ? buffaloIds.length : numUnits ?? 0))
            .toInt();
    final transitCalf =
        (json['in_transist_calfs_count'] ??
                json['in_transit_calfs_count'] ??
                (calfIds.isNotEmpty ? calfIds.length : numUnits ?? 0))
            .toInt();

    return OrderInfo(
      id: json['id'],
      breedId: json['breedId'],
      buffaloCount: (json['buffaloCount'] ?? 0).toInt(),
      calfCount: (json['calfCount'] ?? 0).toInt(),
      inTransitBuffaloCount: transitBuf,
      inTransitCalfCount: transitCalf,
      numUnits: numUnits,
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      status: json['status'],
      placedAt: json['placedAt'],
      buffaloIds: buffaloIds,
      calfIds: calfIds,
    );
  }
}

class TransactionInfo {
  final String id;
  final double amount;
  final String utrNumber;
  final String paymentType;
  final String paymentScreenshotUrl;

  TransactionInfo({
    required this.id,
    required this.amount,
    required this.utrNumber,
    required this.paymentType,
    required this.paymentScreenshotUrl,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      id: json['id'],
      amount: (json['amount'] ?? 0).toDouble(),
      utrNumber: json['utrNumber'] ?? '',
      paymentType: json['paymentType'] ?? '',
      paymentScreenshotUrl: json['paymentScreenshotUrl'] ?? '',
    );
  }
}

class InvestorInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String city;
  final String state;
  final String? aadharNumber;
  final String? aadharFrontUrl;
  final String? aadharBackUrl;
  final String? panCardUrl;

  InvestorInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.city,
    required this.state,
    this.aadharNumber,
    this.aadharFrontUrl,
    this.aadharBackUrl,
    this.panCardUrl,
  });

  factory InvestorInfo.fromJson(Map<String, dynamic> json) {
    return InvestorInfo(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      aadharNumber: json['aadhar_number'],
      aadharFrontUrl: json['aadhar_front_image_url'],
      aadharBackUrl: json['aadhar_back_image_url'],
      panCardUrl: json['panCardUrl'],
    );
  }

  String get fullName => '$firstName $lastName';
}
