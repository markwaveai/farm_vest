class UserModel {
  final String id;
  final String mobile;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String role;
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

  UserModel({
    required this.id,
    required this.mobile,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.role,
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
    this.imageUrl,
    this.farmId,
    this.farmName,
    this.farmLocation,
    this.shedId,
    this.shedName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Customer',
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
      imageUrl: (json['imageUrl'] ?? json['image_url'])?.toString(),
      farmId: json['farm_id']?.toString(),
      farmName: json['farm_name']?.toString(),
      farmLocation: json['farm_location']?.toString(),
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
      imageUrl: imageUrl ?? this.imageUrl,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      shedId: shedId ?? this.shedId,
      shedName: shedName ?? this.shedName,
    );
  }
}
