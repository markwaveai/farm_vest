class LeaveRequest {
  final int id;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String? approvedBy;
  final String? approvedAt;
  final String? rejectionReason;
  final String createdAt;
  final String? updatedAt;

  LeaveRequest({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      leaveType: json['leave_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      reason: json['reason'],
      status: json['status'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
