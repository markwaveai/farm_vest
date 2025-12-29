import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _bioKey = 'biometric_enabled';

  static Future<void> enableBiometric(bool value) async {
    await _storage.write(key: _bioKey, value: value.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _bioKey);
    return value == 'true';
  }
}
