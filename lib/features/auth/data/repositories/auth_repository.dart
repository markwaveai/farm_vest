import 'dart:convert';
import 'dart:io';
import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    final now = DateTime.now();
    final dateFolder =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final fileName = '${now.millisecondsSinceEpoch}.jpg';

    final storage = FirebaseStorage.instanceFor(
      bucket: AppConstants.storageBucketName,
    );

    final ref = storage.ref().child(
      'farmvestuserpics/$userId/$dateFolder/$fileName',
    );
    final snapshot = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
