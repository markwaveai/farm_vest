import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/api_services.dart';
import '../models/whatsapp_otp_response.dart';

enum UserRole { customer, supervisor, doctor, assistant, admin, unknown }

class AuthState {
  final bool isLoading;
  final UserRole? role;
  final String? error;
  final WhatsappOtpResponse? otpResponse;
  final String? mobileNumber;

  AuthState({
    this.isLoading = false,
    this.role,
    this.error,
    this.otpResponse,
    this.mobileNumber,
  });

  AuthState copyWith({
    bool? isLoading,
    UserRole? role,
    String? error,
    WhatsappOtpResponse? otpResponse,
    String? mobileNumber,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
      error: error ?? this.error,
      otpResponse: otpResponse ?? this.otpResponse,
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<WhatsappOtpResponse?> sendWhatsappOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ApiServices.sendWhatsappOtp(phone);

      state = state.copyWith(isLoading: false, otpResponse: response);

      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to send OTP");
      return null;
    }
  }

  bool verifyWhatsappOtpLocal(String enteredOtp) {
    if (state.otpResponse == null) return false;
    return state.otpResponse!.otp == enteredOtp;
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobile_number');
    final roleString = prefs.getString('user_role');

    if (mobile != null && roleString != null) {
      UserRole role;
      switch (roleString) {
        case 'customer':
          role = UserRole.customer;
          break;
        case 'supervisor':
          role = UserRole.supervisor;
          break;
        case 'doctor':
          role = UserRole.doctor;
          break;
        case 'assistant':
          role = UserRole.assistant;
          break;
        case 'admin':
          role = UserRole.admin;
          break;
        default:
          role = UserRole.customer;
      }
      state = state.copyWith(mobileNumber: mobile, role: role);
    }
  }

  Future<void> _saveUserSession(String mobile, UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile_number', mobile);

    String roleString;
    switch (role) {
      case UserRole.customer:
        roleString = 'customer';
        break;
      case UserRole.supervisor:
        roleString = 'supervisor';
        break;
      case UserRole.doctor:
        roleString = 'doctor';
        break;
      case UserRole.assistant:
        roleString = 'assistant';
        break;
      case UserRole.admin:
        roleString = 'admin';
        break;
      default:
        roleString = 'customer';
    }
    await prefs.setString('user_role', roleString);
  }

  // Logic to determine role after OTP is verified
  Future<UserRole> completeLogin(String mobileNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    // Check if we have a role from the OTP response
    String? apiRole;
    if (state.otpResponse?.user != null) {
      apiRole = state.otpResponse!.user!['role']?.toString();
    }

    state = state.copyWith(isLoading: false, mobileNumber: mobileNumber);

    UserRole detectedRole = UserRole.customer;

    if (apiRole != null) {
      // Map API roles to UserRole enum
      if (apiRole.toLowerCase() == 'investor') {
        detectedRole = UserRole.customer;
      } else if (apiRole.toLowerCase() == 'supervisor') {
        detectedRole = UserRole.supervisor;
      } else if (apiRole.toLowerCase() == 'doctor') {
        detectedRole = UserRole.doctor;
      } else if (apiRole.toLowerCase() == 'assistant') {
        detectedRole = UserRole.assistant;
      } else if (apiRole.toLowerCase() == 'admin') {
        detectedRole = UserRole.admin;
      }
    } else {
      // Fallback Mock logic for dev/testing if API doesn't return role or valid role
      if (mobileNumber.endsWith('0')) {
        detectedRole = UserRole.customer;
      } else if (mobileNumber.endsWith('1')) {
        detectedRole = UserRole.supervisor;
      } else if (mobileNumber.endsWith('2')) {
        detectedRole = UserRole.doctor;
      } else if (mobileNumber.endsWith('3')) {
        detectedRole = UserRole.assistant;
      } else if (mobileNumber.endsWith('9')) {
        detectedRole = UserRole.admin;
      } else {
        detectedRole = UserRole.customer;
      }
    }

    state = state.copyWith(role: detectedRole);
    await _saveUserSession(mobileNumber, detectedRole);
    return detectedRole;
  }

  Future<void> logout() async {
    state = AuthState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
