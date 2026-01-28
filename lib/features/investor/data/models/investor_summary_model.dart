/// Model for investor profile details.
///
/// Contains personal information about the investor.
class InvestorProfileDetails {
  /// Investor's first name
  final String firstName;

  /// Investor's last name
  final String lastName;

  /// Investor's phone number
  final String phoneNumber;

  /// Investor's email address (optional)
  final String? email;

  /// Investor's address (optional)
  final String? address;

  /// Date when the investor became a member
  final String memberSince;

  /// Creates an instance of [InvestorProfileDetails].
  const InvestorProfileDetails({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.address,
    required this.memberSince,
  });

  /// Creates an [InvestorProfileDetails] from JSON data.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "first_name": "shenkhar",
  ///   "last_name": "uma",
  ///   "phone_number": "6305447441",
  ///   "email": null,
  ///   "address": null,
  ///   "member_since": "2026-01-28T14:43:52.289001+05:30"
  /// }
  /// ```
  factory InvestorProfileDetails.fromJson(Map<String, dynamic> json) {
    return InvestorProfileDetails(
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      memberSince: json['member_since'] as String? ?? '',
    );
  }

  /// Converts this [InvestorProfileDetails] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'member_since': memberSince,
    };
  }

  /// Gets the full name of the investor.
  String get fullName => '$firstName $lastName'.trim();

  /// Creates a copy of this [InvestorProfileDetails] with the given fields replaced.
  InvestorProfileDetails copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? address,
    String? memberSince,
  }) {
    return InvestorProfileDetails(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      memberSince: memberSince ?? this.memberSince,
    );
  }

  @override
  String toString() {
    return 'InvestorProfileDetails(fullName: $fullName, phoneNumber: $phoneNumber)';
  }
}

/// Model for investor summary data from /api/investors/summary endpoint.
///
/// This model contains aggregated statistics and profile information
/// for the investor's dashboard.
class InvestorSummary {
  /// Investor's profile details
  final InvestorProfileDetails profileDetails;

  /// Total number of buffaloes owned
  final int totalBuffaloes;

  /// Total number of calves owned
  final int totalCalves;

  /// Current asset value in rupees
  final double assetValue;

  /// Total revenue earned in rupees
  final double revenue;

  /// Creates an instance of [InvestorSummary].
  const InvestorSummary({
    required this.profileDetails,
    required this.totalBuffaloes,
    required this.totalCalves,
    required this.assetValue,
    required this.revenue,
  });

  /// Creates an [InvestorSummary] from JSON data.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "profile_details": {...},
  ///   "total_buffaloes": 1,
  ///   "total_calves": 1,
  ///   "asset_value": 160000.0,
  ///   "revenue": 0
  /// }
  /// ```
  factory InvestorSummary.fromJson(Map<String, dynamic> json) {
    return InvestorSummary(
      profileDetails: InvestorProfileDetails.fromJson(
        json['profile_details'] as Map<String, dynamic>? ?? {},
      ),
      totalBuffaloes: json['total_buffaloes'] as int? ?? 0,
      totalCalves: json['total_calves'] as int? ?? 0,
      assetValue: (json['asset_value'] as num?)?.toDouble() ?? 0.0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts this [InvestorSummary] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'profile_details': profileDetails.toJson(),
      'total_buffaloes': totalBuffaloes,
      'total_calves': totalCalves,
      'asset_value': assetValue,
      'revenue': revenue,
    };
  }

  /// Gets the total number of animals (buffaloes + calves).
  int get totalAnimals => totalBuffaloes + totalCalves;

  /// Gets formatted asset value with currency symbol.
  String get formattedAssetValue => '₹${assetValue.toStringAsFixed(0)}';

  /// Gets formatted revenue with currency symbol.
  String get formattedRevenue => '₹${revenue.toStringAsFixed(0)}';

  /// Creates a copy of this [InvestorSummary] with the given fields replaced.
  InvestorSummary copyWith({
    InvestorProfileDetails? profileDetails,
    int? totalBuffaloes,
    int? totalCalves,
    double? assetValue,
    double? revenue,
  }) {
    return InvestorSummary(
      profileDetails: profileDetails ?? this.profileDetails,
      totalBuffaloes: totalBuffaloes ?? this.totalBuffaloes,
      totalCalves: totalCalves ?? this.totalCalves,
      assetValue: assetValue ?? this.assetValue,
      revenue: revenue ?? this.revenue,
    );
  }

  @override
  String toString() {
    return 'InvestorSummary(totalBuffaloes: $totalBuffaloes, '
        'totalCalves: $totalCalves, assetValue: $formattedAssetValue, '
        'revenue: $formattedRevenue)';
  }
}

/// Response model for /api/investors/summary endpoint.
class InvestorSummaryResponse {
  /// Status of the response
  final String status;

  /// Investor summary data
  final InvestorSummary data;

  /// Creates an instance of [InvestorSummaryResponse].
  const InvestorSummaryResponse({required this.status, required this.data});

  /// Creates an [InvestorSummaryResponse] from JSON data.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "data": {...}
  /// }
  /// ```
  factory InvestorSummaryResponse.fromJson(Map<String, dynamic> json) {
    return InvestorSummaryResponse(
      status: json['status'] as String? ?? 'success',
      data: InvestorSummary.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Converts this [InvestorSummaryResponse] to JSON.
  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data.toJson()};
  }
}
