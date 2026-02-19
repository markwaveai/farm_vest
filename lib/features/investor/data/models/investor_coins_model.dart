class InvestorCoins {
  final double totalCoins;
  final double directReferralsCoins;
  final double indirectReferralsCoins;
  final double spendingCoins;
  final double remainingCoins;

  InvestorCoins({
    required this.totalCoins,
    required this.directReferralsCoins,
    required this.indirectReferralsCoins,
    required this.spendingCoins,
    required this.remainingCoins,
  });

  factory InvestorCoins.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    return InvestorCoins(
      totalCoins: (stats['total_coins'] as num?)?.toDouble() ?? 0.0,
      directReferralsCoins:
          (stats['direct_referrals_coins'] as num?)?.toDouble() ?? 0.0,
      indirectReferralsCoins:
          (stats['indirect_referrals_coins'] as num?)?.toDouble() ?? 0.0,
      spendingCoins: (stats['spending_coins'] as num?)?.toDouble() ?? 0.0,
      remainingCoins: (stats['remaining_coins'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory InvestorCoins.empty() {
    return InvestorCoins(
      totalCoins: 0.0,
      directReferralsCoins: 0.0,
      indirectReferralsCoins: 0.0,
      spendingCoins: 0.0,
      remainingCoins: 0.0,
    );
  }
}

class CoinTransaction {
  final double amount;
  final String giverName;
  final String orderId;
  final double coins;
  final String mobile;
  final String description;
  final String createdAt;
  final String type;
  final double? noOfUnitsBuy;
  final bool isDirect;
  final String name;
  final String? giverMobile;
  final String id;
  final String referralStatus;

  CoinTransaction({
    required this.amount,
    required this.giverName,
    required this.orderId,
    required this.coins,
    required this.mobile,
    required this.description,
    required this.createdAt,
    required this.type,
    this.noOfUnitsBuy,
    required this.isDirect,
    required this.name,
    this.giverMobile,
    required this.id,
    required this.referralStatus,
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    final tx = json['transaction'] ?? {};
    return CoinTransaction(
      amount: (tx['amount'] as num?)?.toDouble() ?? 0.0,
      giverName: tx['giverName'] ?? '',
      orderId: tx['orderId'] ?? '',
      coins: (tx['coins'] as num?)?.toDouble() ?? 0.0,
      mobile: tx['mobile'] ?? '',
      description: tx['description'] ?? '',
      createdAt: tx['created_at'] ?? '',
      type: tx['type'] ?? '',
      noOfUnitsBuy: (tx['no_of_units_buy'] as num?)?.toDouble(),
      isDirect: tx['is_direct'] == true,
      name: tx['name'] ?? '',
      giverMobile: tx['giverMobile'],
      id: tx['id'] ?? '',
      referralStatus: tx['referral_status'] ?? '',
    );
  }
}

class InvestorCoinsResponse {
  final InvestorCoins coins;
  final List<CoinTransaction> transactions;

  InvestorCoinsResponse({required this.coins, required this.transactions});

  factory InvestorCoinsResponse.fromJson(Map<String, dynamic> json) {
    return InvestorCoinsResponse(
      coins: InvestorCoins.fromJson(json),
      transactions: (json['transactions'] as List? ?? [])
          .map((e) => CoinTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
