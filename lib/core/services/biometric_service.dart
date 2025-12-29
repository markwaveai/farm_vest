import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static bool _isUnlocked = false;
  static String? _lastError;

  static bool get isUnlocked => _isUnlocked;
  static String? get lastError => _lastError;

  static void lock() {
    _isUnlocked = false;
    _lastError = null;
  }

  static Future<bool> authenticate() async {
    try {
      _lastError = null;
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      if (!isSupported || !canCheck) {
        _isUnlocked = true;
        return true;
      }

      final available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) {
        _lastError = 'No biometrics enrolled on this device';
        _isUnlocked = false;
        return false;
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Unlock FarmVest',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      _isUnlocked = didAuthenticate;
      return didAuthenticate;
    } catch (e) {
      _lastError = e.toString();
      _isUnlocked = false;
      return false;
    }
  }
}
