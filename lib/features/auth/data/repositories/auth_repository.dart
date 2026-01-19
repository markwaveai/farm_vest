import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:farm_vest/core/widgets/floating_toast.dart';
import 'package:farm_vest/features/auth/data/models/login_response.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:farm_vest/core/services/api_services.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import '../models/user_model.dart';
import '../models/whatsapp_otp_response.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Future<LoginResponse> loginWithOtp(String mobile, String otp) async {
    final response = await ApiServices.loginWithOtp(mobile, otp);
    if (response == null) {
      throw Exception('Failed to login');
    }
    return response;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<WhatsappOtpResponse?> sendOtp(String mobile) async {
    return await ApiServices.sendWhatsappOtp(mobile);
  }

  Future<UserModel?> getUserData(String mobile) async {
    return await ApiServices.getUserData(mobile);
  }

  Future<UserModel?> updateUserProfile({
    required String mobile,
    required Map<String, dynamic> body,
  }) async {
    return await ApiServices.updateUserProfile(mobile: mobile, body: body);
  }

  Future<void> saveUserSession({
    required String mobile,
    required UserType role,
    required UserModel? userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile_number', mobile);
    await prefs.setString('user_role', role.value);

    if (userData != null) {
      final userDataString = jsonEncode(userData.toJson());
      await prefs.setString('user_data', userDataString);
    }
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobile_number');
    final roleString = prefs.getString('user_role');
    final userDataString = prefs.getString('user_data');

    if (mobile != null && roleString != null) {
      final role = UserType.fromString(roleString);
      UserModel? userData;
      if (userDataString != null) {
        try {
          final userJson = jsonDecode(userDataString);
          userData = UserModel.fromJson(userJson);
        } catch (_) {}
      }
      return {'mobile': mobile, 'role': role, 'userData': userData};
    }
    return null;
  }

  //upload profile image
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    final storage = FirebaseStorage.instanceFor(
      bucket: AppConstants.storageBucketName,
    );

    final ref = storage.ref().child(
      'farmvestuserpics/$userId/profile.jpg',
    );
    final snapshot = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg', cacheControl: "no-cache"),
    );
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<String?> getCurrentFirebaseImageUrl(String userId) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      final ref = storage.ref().child('farmvestuserpics/$userId/profile.jpg');

      // Try to get download URL - this will throw if file doesn't exist
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // File doesn't exist in Firebase
        return '';
      }
      debugPrint('Firebase error: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error getting Firebase image URL: $e');
      return null;
    }
  }

  // Delete profile image from Firebase
  Future<bool> deleteProfileImage(
      {required String userId, required String filePath}) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      final ref = storage.ref().child('farmvestuserpics/$userId/profile.jpg');
      await ref.delete();

      FloatingToast.showSimpleToast('Front image deleted successfully');
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // Already deleted or never uploaded.
        SnackBar(content: Text('Profile image already deleted'));
        return true;
      }
      debugPrint('Error deleting front image: ${e.code} ${e.message}');
      SnackBar(content: Text('Failed to delete front image'));
      return false;
    } catch (e) {
      debugPrint('Error deleting front image: $e');
      SnackBar(content: Text('Failed to delete front image'));
      return false;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
