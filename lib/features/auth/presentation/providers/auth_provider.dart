import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:farm_vest/core/error/exceptions.dart';
import 'package:farm_vest/core/services/biometric_service.dart';
import 'package:farm_vest/core/utils/image_helper_compressor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/models/whatsapp_otp_response.dart';

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
  final List<UserType> availableRoles;
  final String? error;
  final WhatsappOtpResponse? otpResponse;
  final String? mobileNumber;
  final UserModel? userData;

  AuthState({
    this.isLoading = false,
    this.role,
    this.availableRoles = const [],
    this.error,
    this.otpResponse,
    this.mobileNumber,
    this.userData,
  });

  AuthState copyWith({
    bool? isLoading,
    UserType? role,
    List<UserType>? availableRoles,
    String? error,
    WhatsappOtpResponse? otpResponse,
    String? mobileNumber,
    UserModel? userData,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
      availableRoles: availableRoles ?? this.availableRoles,
      error: error ?? this.error,
      otpResponse: otpResponse ?? this.otpResponse,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      userData: userData ?? this.userData,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<String?> getToken() => _repository.getToken();
  final ImagePicker _picker = ImagePicker();
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
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return null;
    } catch (e) {
      debugPrint("Upload profile image error: $e");
      state = state.copyWith(error: "Failed to upload image: $e");
      return null;
    }
  }

  //delete profile image
  Future<bool> deleteProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      return await _repository.deleteProfileImage(
        userId: userId,
        filePath: filePath,
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      debugPrint("Delete profile image error: $e");
      return false;
    }
  }

  // In AuthController class
  Future<String?> getCurrentFirebaseImageUrl(String userId) async {
    return await _repository.getCurrentFirebaseImageUrl(userId);
  }

  Future<WhatsappOtpResponse?> sendWhatsappOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null, mobileNumber: phone);

    try {
      final response = await _repository.sendOtp(phone);
      state = state.copyWith(isLoading: false, otpResponse: response);
      return response;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithOtp(
    String mobileNumber,
    String otp,
  ) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      mobileNumber: mobileNumber,
    );

    try {
      final loginResponse = await _repository.loginWithOtp(mobileNumber, otp);
      await _repository.saveToken(loginResponse.accessToken);

      final availableRoles = loginResponse.roles
          .map((r) => UserType.fromString(r))
          .toList();

      final role = availableRoles.isNotEmpty
          ? availableRoles.first
          : UserType.customer;

      state = state.copyWith(
        isLoading: false,
        role: role,
        availableRoles: availableRoles,
      );

      await _repository.saveUserSession(
        mobile: mobileNumber,
        roles: availableRoles,
        activeRole: role,
        userData: null,
      );

      return {'roles': availableRoles, 'userData': null};
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    }
  }

  Future<void> selectRole(UserType role) async {
    if (state.mobileNumber == null) return;

    state = state.copyWith(role: role);
    await _repository.saveUserSession(
      mobile: state.mobileNumber!,
      roles: state.availableRoles,
      activeRole: role,
      userData: state.userData,
    );
  }

  Future<Map<String, dynamic>?> verifyWhatsappOtpLocal(String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    // Check if OTP matches the one from the API response
    if (state.otpResponse != null && state.otpResponse!.otp == otp) {
      return await completeLoginWithData(state.mobileNumber!);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: "Invalid OTP. Please try again.",
      );
      return null;
    }
  }

  Future<void> checkLoginStatus() async {
    final session = await _repository.getSession();

    if (session != null) {
      state = state.copyWith(
        mobileNumber: session['mobile'],
        availableRoles: session['roles'],
        role: session['activeRole'],
        userData: session['userData'],
      );
    }
  }

  Future<File?> pickProfileImage({
    required ImageSource source,
    bool compress = true,
    bool isDocument = true,
  }) async {
    try {
      final XFile? image = await BiometricService.runWithLockSuppressed(() {
        return _picker.pickImage(source: source, imageQuality: 85);
      });

      if (image == null) return null;

      File selectedFile = File(image.path);

      if (compress) {
        selectedFile = await ImageCompressionHelper.getCompressedImageIfNeeded(
          selectedFile,
          maxSizeKB: 250,
          isDocument: isDocument,
        );
      }

      return selectedFile;
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return null;
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
      debugPrint('Fetching user data for $mobileNumber during login...');
      userData = await _repository.getUserData(mobileNumber);
      debugPrint('User data result: ${userData?.name}, ${userData?.email}');
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }

    // Determine Roles
    List<UserType> availableRoles = [];

    // Check if the OTP response already gave us a list of roles (most reliable during login)
    final userMap = state.otpResponse?.user;
    if (userMap != null) {
      final apiRoles = userMap['roles'] ?? userMap['role'];
      if (apiRoles is List) {
        availableRoles = apiRoles
            .map((r) => UserType.fromString(r.toString()))
            .toList();
      } else if (apiRoles != null) {
        availableRoles = [UserType.fromString(apiRoles.toString())];
      }
    }

    // Fallback or complement with userData role if list is still empty
    final localData = userData;
    if (availableRoles.isEmpty && localData != null) {
      // Prioritize the new roles list from UserModel
      if (localData.roles.isNotEmpty) {
        availableRoles = localData.roles
            .map((r) => UserType.fromString(r))
            .toList();
      } else {
        // Fallback to single role string
        availableRoles = [UserType.fromString(localData.role)];
      }
    }

    if (availableRoles.isEmpty) {
      // Fallback Mock logic
      if (mobileNumber.endsWith('0')) {
        availableRoles = [UserType.customer];
      } else if (mobileNumber.endsWith('1')) {
        availableRoles = [UserType.supervisor];
      } else if (mobileNumber.endsWith('2')) {
        availableRoles = [UserType.doctor];
      } else if (mobileNumber.endsWith('3')) {
        availableRoles = [UserType.assistant];
      } else if (mobileNumber.endsWith('4')) {
        availableRoles = [UserType.farmManager];
      } else if (mobileNumber.endsWith('9')) {
        availableRoles = [UserType.admin];
      } else {
        availableRoles = [UserType.customer];
      }
    }

    UserType selectedRole = availableRoles.first;

    state = state.copyWith(
      mobileNumber: mobileNumber,
      role: selectedRole,
      availableRoles: availableRoles,
      userData: userData,
      isLoading: false,
    );

    await _repository.saveUserSession(
      mobile: mobileNumber,
      roles: availableRoles,
      activeRole: selectedRole,
      userData: userData,
    );

    return {'roles': availableRoles, 'userData': userData};
  }

  Future<void> logout() async {
    state = AuthState();
    await _repository.clearSession();
  }

  Future<void> refreshUserData() async {
    if (state.mobileNumber == null) return;

    state = state.copyWith(isLoading: true);

    try {
      debugPrint('Refreshing user data for ${state.mobileNumber}...');
      final userData = await _repository.getUserData(state.mobileNumber!);
      if (userData != null) {
        debugPrint('Refresh success: ${userData.name}');

        // Update available roles from the fresh user data
        List<UserType> newAvailableRoles = [];
        if (userData.roles.isNotEmpty) {
          newAvailableRoles = userData.roles
              .map((r) => UserType.fromString(r))
              .toList();
        } else {
          newAvailableRoles = [UserType.fromString(userData.role)];
        }

        state = state.copyWith(
          userData: userData,
          isLoading: false,
          availableRoles: newAvailableRoles, // Update state with new roles
        );

        await _repository.saveUserSession(
          mobile: state.mobileNumber!,
          roles: newAvailableRoles, // Save new roles to session
          activeRole: state.role ?? UserType.customer,
          userData: userData,
        );
      } else {
        debugPrint('Refresh returned null user data');
        state = state.copyWith(isLoading: false);
      }
    } on AppException catch (e) {
      debugPrint('Refresh error: $e');
      state = state.copyWith(isLoading: false, error: e.message);
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
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateLocalUserData(UserModel user) {
    state = state.copyWith(userData: user);
  }
}
