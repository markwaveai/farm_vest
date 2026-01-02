class WhatsappOtpResponse {
  final String? otp;
  final Map<String, dynamic>? user;
  final String? message;
  final bool status;

  WhatsappOtpResponse({this.otp, this.user, this.message, this.status = false});

  factory WhatsappOtpResponse.fromJson(Map<String, dynamic> json) {
    return WhatsappOtpResponse(
      otp: json['otp']?.toString(),
      user: json['user'] as Map<String, dynamic>?,
      message: json['message']?.toString(),
      status: json['status'] == 'success',
    );
  }
}
