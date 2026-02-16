import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_vest/core/services/auth_api_services.dart';
import 'package:farm_vest/core/theme/app_constants.dart';

import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/widgets/floating_toast.dart';
import 'package:farm_vest/features/auth/data/models/login_response.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm_vest/core/utils/image_helper_compressor.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/whatsapp_otp_response.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Future<void> ensureFirebaseSession() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint("Signed in to Firebase Anonymously for Storage access");
      }
    } catch (e) {
      debugPrint("Failed to sign in to Firebase Anonymously: $e");
    }
  }

  Future<LoginResponse> loginWithOtp(String mobile, String otp) async {
    final response = await AuthApiServices.loginWithOtp(mobile, otp);
    await ensureFirebaseSession();
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
    return await AuthApiServices.sendWhatsappOtp(mobile);
  }

  Future<UserModel?> getUserData(String mobile) async {
    final token = await getToken();
    return await AuthApiServices.getUserData(mobile, token: token);
  }

  Future<UserModel?> updateUserProfile({
    required String mobile,
    required Map<String, dynamic> body,
  }) async {
    final token = await getToken();
    return await AuthApiServices.updateUserProfile(
      mobile: mobile,
      body: body,
      token: token,
    );
  }

  Future<void> registerFcmToken(String token) async {
    final jwt = await getToken();
    await AuthApiServices.registerFcmToken(token, jwt: jwt);
  }

  Future<void> saveUserSession({
    required String mobile,
    required List<UserType> roles,
    required UserType activeRole,
    required UserModel? userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile_number', mobile);
    await prefs.setString(
      'user_roles',
      jsonEncode(roles.map((r) => r.value).toList()),
    );
    await prefs.setString('active_role', activeRole.value);

    if (userData != null) {
      final userDataString = jsonEncode(userData.toJson());
      await prefs.setString('user_data', userDataString);
    }
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final mobile = prefs.getString('mobile_number');
    final rolesJson = prefs.getString('user_roles');
    final activeRoleString = prefs.getString('active_role');
    final userDataString = prefs.getString('user_data');

    if (mobile != null && rolesJson != null && activeRoleString != null) {
      final List<dynamic> rolesList = jsonDecode(rolesJson);
      final roles = rolesList.map((r) => UserType.fromString(r)).toList();
      final activeRole = UserType.fromString(activeRoleString);

      UserModel? userData;
      if (userDataString != null) {
        try {
          final userJson = jsonDecode(userDataString);
          userData = UserModel.fromJson(userJson);
        } catch (_) {}
      }
      return {
        'mobile': mobile,
        'roles': roles,
        'activeRole': activeRole,
        'userData': userData,
      };
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

    final ref = storage.ref().child('farmvest/userpics/$userId/profile.jpg');

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

      final ref = storage.ref().child('farmvest/userpics/$userId/profile.jpg');

      // Try to get download URL - this will throw if file doesn't exist
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // File doesn't exist in Firebase
        return null;
      }
      debugPrint('Firebase error: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error getting Firebase image URL: $e');
      return null;
    }
  }

  // Delete profile image from Firebase
  Future<bool> deleteProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      final ref = storage.ref().child('farmvest/userpics/$userId/profile.jpg');
      await ref.delete();

      FloatingToast.showSimpleToast('Profile image deleted successfully');
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // Already deleted or never uploaded.
        // SnackBar(content: Text('Profile image already deleted'));
        return true;
      }
      debugPrint('Error deleting profile image: ${e.code} ${e.message}');
      // SnackBar(content: Text('Failed to delete profile image'));
      return false;
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      // SnackBar(content: Text('Failed to delete profile image'));
      return false;
    }
  }

  static Future<String?> uploadImage(File file) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      // Compress image before uploading
      final compressedFile =
          await ImageCompressionHelper.getCompressedImageIfNeeded(
            file,
            maxSizeKB: 250,
            isDocument: false,
          );

      final now = DateTime.now();
      final dateFolder = DateFormat('yyyy-MM-dd').format(now);
      final timestamp = now.millisecondsSinceEpoch;

      final ref = storage.ref().child(
        'farmvest/buffaloesonboarding/$dateFolder/image_$timestamp.jpg',
      );

      final snapshot = await ref.putFile(
        compressedFile,
        SettableMetadata(contentType: 'image/jpeg', cacheControl: "no-cache"),
      );
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      FloatingToast.showSimpleToast('Failed to upload image');
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('mobile_number');
    await prefs.remove('user_roles');
    await prefs.remove('active_role');
    await prefs.remove('user_data');
  }
}
