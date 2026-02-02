class UserModel {
  final String id;
  final String mobile;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String role;
  final List<String> roles; // Added roles list
  final String? gender;
  final String? dob;
  final String? address;
  final String? occupation;
  final String? aadharNumber;
  final String? aadharFrontImageUrl;
  final String? aadharBackImageUrl;
  final String? referedByMobile;
  final String? referedByName;
  final bool isFormFilled;
  final bool verified;
  final bool otpVerified;
  final bool isQuit;
  final String? imageUrl;
  final String? farmId;
  final String? farmName;
  final String? farmLocation;
  final String? shedId;
  final String? shedName;

  final bool isActive;

  UserModel({
    required this.id,
    required this.mobile,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.role,
    this.roles = const [], // Default to empty list
    this.gender,
    this.dob,
    this.address,
    this.occupation,
    this.aadharNumber,
    this.aadharFrontImageUrl,
    this.aadharBackImageUrl,
    this.referedByMobile,
    this.referedByName,
    this.isFormFilled = false,
    this.verified = false,
    this.otpVerified = false,
    this.isQuit = false,
    this.isActive = true, // Default to true
    this.imageUrl,
    this.farmId,
    this.farmName,
    this.farmLocation,
    this.shedId,
    this.shedName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse roles list safely
    List<String> parsedRoles = [];
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        parsedRoles = List<String>.from(json['roles'].map((e) => e.toString()));
      }
    } else if (json['role'] != null) {
      // Fallback: if roles is missing but role exists, add it to list
      parsedRoles = [json['role'].toString()];
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Customer',
      roles: parsedRoles,
      gender: json['gender']?.toString(),
      dob: json['dob']?.toString(),
      address: json['address']?.toString(),
      occupation: json['occupation']?.toString(),
      aadharNumber: json['aadhar_number']?.toString(),
      aadharFrontImageUrl: json['aadhar_front_image_url']?.toString(),
      aadharBackImageUrl: json['aadhar_back_image_url']?.toString(),
      referedByMobile: json['refered_by_mobile']?.toString(),
      referedByName: json['refered_by_name']?.toString(),
      isFormFilled: json['isFormFilled'] ?? false,
      verified: json['verified'] ?? false,
      otpVerified: json['otp_verified'] ?? false,
      isQuit: json['isQuit'] ?? false,
      isActive: json['is_active'] ?? true, // Map from is_active
      imageUrl: (json['imageUrl'] ?? json['image_url'])?.toString(),
      farmId: json['farm_id']?.toString(),
      farmName:
          (json['farm_name'] ??
                  json['farmName'] ??
                  (json['farm'] is String ? json['farm'] : null) ??
                  json['farm']?['farm_name'] ??
                  json['farm']?['name'] ??
                  json['farm_details']?['farm_name'] ??
                  json['farm_details']?['name'])
              ?.toString(),
      farmLocation:
          (json['farm_location'] ??
                  json['location'] ??
                  json['city'] ??
                  json['district'] ??
                  json['state'] ??
                  json['area'] ??
                  json['farm_area'] ??
                  json['address'] ??
                  json['farm']?['location'] ??
                  json['farm']?['city'] ??
                  json['farm']?['farm_location'] ??
                  json['farm']?['address'] ??
                  json['farm_details']?['location'] ??
                  json['farm_details']?['city'] ??
                  json['farm_details']?['farm_location'] ??
                  json['farm_details']?['address'])
              ?.toString(),
      shedId: json['shed_id']?.toString(),
      shedName: json['shed_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': mobile,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'email': email,
      'role': role,
      'roles': roles,
      'gender': gender,
      'dob': dob,
      'address': address,
      'occupation': occupation,
      'aadhar_number': aadharNumber,
      'aadhar_front_image_url': aadharFrontImageUrl,
      'aadhar_back_image_url': aadharBackImageUrl,
      'refered_by_mobile': referedByMobile,
      'refered_by_name': referedByName,
      'isFormFilled': isFormFilled,
      'verified': verified,
      'otp_verified': otpVerified,
      'isQuit': isQuit,
      'is_active': isActive,
      'image_url': imageUrl,
      'farm_id': farmId,
      'farm_name': farmName,
      'farm_location': farmLocation,
      'shed_id': shedId,
      'shed_name': shedName,
    };
  }

  UserModel copyWith({
    String? id,
    String? mobile,
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? role,
    List<String>? roles,
    String? gender,
    String? dob,
    String? address,
    String? occupation,
    String? aadharNumber,
    String? aadharFrontImageUrl,
    String? aadharBackImageUrl,
    String? referedByMobile,
    String? referedByName,
    bool? isFormFilled,
    bool? verified,
    bool? otpVerified,
    bool? isActive,
    String? imageUrl,
    String? farmId,
    String? farmName,
    String? farmLocation,
    String? shedId,
    String? shedName,
  }) {
    return UserModel(
      id: id ?? this.id,
      mobile: mobile ?? this.mobile,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      aadharFrontImageUrl: aadharFrontImageUrl ?? this.aadharFrontImageUrl,
      aadharBackImageUrl: aadharBackImageUrl ?? this.aadharBackImageUrl,
      referedByMobile: referedByMobile ?? this.referedByMobile,
      referedByName: referedByName ?? this.referedByName,
      isFormFilled: isFormFilled ?? this.isFormFilled,
      verified: verified ?? this.verified,
      otpVerified: otpVerified ?? this.otpVerified,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      shedId: shedId ?? this.shedId,
      shedName: shedName ?? this.shedName,
    );
  }
}
