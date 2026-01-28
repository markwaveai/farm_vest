class Staff {
  final String? id;
  final String? name;
  final String? role;
  final String? designation;
  final String? phone;
  final String? email;
  final String? status;
  final String? seniorDoctorName;
  final String? seniorDoctorPhone;
  final String? shedName;
  final List<String> assignedFarms;
  final List<String> assignedSheds;

  Staff({
    this.id,
    this.name,
    this.role,
    this.designation,
    this.phone,
    this.email,
    this.status,
    this.shedName,
    this.seniorDoctorName,
    this.seniorDoctorPhone,
    this.assignedFarms = const [],
    this.assignedSheds = const [],
  });

  factory Staff.fromJson(Map<String, dynamic> json, String role) {
    final seniorDoctor = json['senior_doctor'];
    final List<dynamic> farms = json['assigned_farms'] ?? [];
    final List<dynamic> sheds = json['assigned_sheds'] ?? [];

    return Staff(
      id: json['id']?.toString(),
      name: json['name'] ?? 'Unknown',
      role: role,
      designation: json['designation'] ?? 'Not Assigned',
      shedName: json['shed_name'] ?? 'Not Assigned',
      phone: json['mobile'] ?? '-',
      email: json['email'] ?? '-',
      status: json['status'] ?? 'On Duty',
      seniorDoctorName: seniorDoctor?['name'],
      seniorDoctorPhone: seniorDoctor?['mobile']?.toString(),
      assignedFarms: farms.map((f) => f['name'].toString()).toList(),
      assignedSheds: sheds.map((s) => s['name'].toString()).toList(),
    );
  }
}
