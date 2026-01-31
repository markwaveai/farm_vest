// Removed unused import

class Investor {
  final int investorId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final int animalCount;
  final DateTime? memberSince;

  Investor({
    required this.investorId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.animalCount = 0,
    this.memberSince,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Investor.fromJson(Map<String, dynamic> json) {
    return Investor(
      investorId: json['investor_id'] is num
          ? (json['investor_id'] as num).toInt()
          : 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      address: json['address'],
      animalCount: json['animal_count'] is num
          ? (json['animal_count'] as num).toInt()
          : 0,
      memberSince: json['member_since'] != null
          ? DateTime.tryParse(json['member_since'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investor_id': investorId,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'animal_count': animalCount,
      'member_since': memberSince?.toIso8601String(),
    };
  }
}

class InvestorListResponse {
  final String status;
  final int count;
  final List<Investor> data;

  InvestorListResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory InvestorListResponse.fromJson(Map<String, dynamic> json) {
    return InvestorListResponse(
      status: json['status'] ?? 'success',
      count: json['count'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Investor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
