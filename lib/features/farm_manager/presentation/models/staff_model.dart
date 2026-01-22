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

  Staff({
    this.id,
    this.name,
    this.role,
    this.designation,
    this.phone,
    this.email,
    this.status,
    this.seniorDoctorName,
    this.seniorDoctorPhone,
  });

  factory Staff.fromJson(Map<String, dynamic> json, String role) {
    final seniorDoctor = json['senior_doctor'];
    return Staff(
      id: json['id']?.toString(),
      name: json['name'] ?? 'Unknown',
      role: role, // Injected based on array
      designation: json['designation'] ?? 'Not Assigned',
      phone: json['mobile'] ?? '-',
      email: json['email'] ?? '-',
      status: json['status'] ?? 'On Duty',
      seniorDoctorName: seniorDoctor?['name'],
      seniorDoctorPhone: seniorDoctor?['mobile']?.toString(),
    );
  }
}
