import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_enums.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../models/whatsapp_otp_response.dart';

// Re-export UserType as UserRole to minimize breaking changes in screens temporarily
// or we should update screens. Let's update screens to use UserType later.
// For now, I will use UserType internally but I can alias it if I want to save time,
// but Clean Architecture suggests using the Domain entity (UserType).
// I will update the screens in the next steps.

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthState {
  final bool isLoading;
  final UserType? role;
  final String? error;
  final WhatsappOtpResponse? otpResponse;
  final String? mobileNumber;
  final UserModel? userData;

  AuthState({
    this.isLoading = false,
    this.role,
    this.error,
    this.otpResponse,
    this.mobileNumber,
    this.userData,
  });

  AuthState copyWith({
    bool? isLoading,
    UserType? role,
    String? error,
    WhatsappOtpResponse? otpResponse,
    String? mobileNumber,
    UserModel? userData,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
      error: error ?? this.error,
      otpResponse: otpResponse ?? this.otpResponse,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      userData: userData ?? this.userData,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    return AuthState();
  }
//upload profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      if (filePath.isEmpty) return null;
      final url = await _repository.uploadProfileImage(
        file: File(filePath),
        userId: userId,
      );
      return url;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<WhatsappOtpResponse?> sendWhatsappOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.sendOtp(phone);
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
    final session = await _repository.getSession();

    if (session != null) {
      state = state.copyWith(
        mobileNumber: session['mobile'],
        role: session['role'],
        userData: session['userData'],
      );
    }
  }

  // Logic to determine role after OTP is verified
  // Merged completeLogin and completeLoginWithData for cleaner code
  Future<Map<String, dynamic>> completeLoginWithData(
    String mobileNumber,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    // Fetch user data from Repository
    UserModel? userData;
    try {
      userData = await _repository.getUserData(mobileNumber);
    } catch (e) {
      // Continue if fetch fails
    }

    // Determine Role
    String? apiRole = userData?.role;
    if (apiRole == null && state.otpResponse?.user != null) {
      apiRole = state.otpResponse!.user!['role']?.toString();
    }

    UserType detectedRole = UserType.customer;

    if (apiRole != null) {
      // Using UserType.fromString which handles casing and default
      detectedRole = UserType.fromString(apiRole);
    } else {
      // Fallback Mock logic
      if (mobileNumber.endsWith('0')) {
        detectedRole = UserType.customer;
      } else if (mobileNumber.endsWith('1')) {
        detectedRole = UserType.supervisor;
      } else if (mobileNumber.endsWith('2')) {
        detectedRole = UserType.doctor;
      } else if (mobileNumber.endsWith('3')) {
        detectedRole = UserType.assistant;
      } else if (mobileNumber.endsWith('9')) {
        detectedRole = UserType.admin;
      }
    }

    state = state.copyWith(
      mobileNumber: mobileNumber,
      role: detectedRole,
      userData: userData,
      isLoading: false,
    );

    await _repository.saveUserSession(
      mobile: mobileNumber,
      role: detectedRole,
      userData: userData,
    );

    return {'role': detectedRole, 'userData': userData};
  }

  Future<void> logout() async {
    state = AuthState();
    await _repository.clearSession();
  }

  Future<void> refreshUserData() async {
    if (state.mobileNumber == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final userData = await _repository.getUserData(state.mobileNumber!);
      if (userData != null) {
        state = state.copyWith(userData: userData, isLoading: false);
        await _repository.saveUserSession(
          mobile: state.mobileNumber!,
          role: state.role ?? UserType.customer,
          userData: userData,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to refresh user data",
      );
    }
  }

  Future<UserModel?> updateUserdata({
    required String userId,
    Map<String, dynamic>? extraFields,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      if (userId.isEmpty) {
        throw ArgumentError("Mobile number is required");
      }

      final payload = <String, dynamic>{};
      if (extraFields != null && extraFields.isNotEmpty) {
        payload.addAll(extraFields);
      }

      final user = await _repository.updateUserProfile(
        mobile: userId,
        body: payload,
      );

      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateLocalUserData(UserModel user) {
    state = state.copyWith(userData: user);
  }
}
