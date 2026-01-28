import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';

class BiometricLockScreen extends StatefulWidget {
  final Widget child;
  const BiometricLockScreen({super.key, required this.child});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with WidgetsBindingObserver {
  bool _enabled = false;
  bool _checkedEnabled = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialAuth();
    });
  }

  Future<void> _initialAuth() async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    if (!mounted) return;

    setState(() {
      _enabled = enabled;
      _checkedEnabled = true;
    });

    if (!enabled) {
      BiometricService.lock();
      return;
    }

    await _authenticate();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    await BiometricService.authenticate();
    if (!mounted) return;
    setState(() => _isAuthenticating = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    if (!mounted) return;

    _enabled = enabled;
    _checkedEnabled = true;

    if (!enabled) {
      BiometricService.lock();
      setState(() {});
      return;
    }

    if (state == AppLifecycleState.paused) {
      if (!BiometricService.isLockSuppressed) {
        BiometricService.lock();
        setState(() {});
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (!BiometricService.isUnlocked) {
        await _authenticate();
        if (!mounted) return;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedEnabled) {
      return const SizedBox.shrink();
    }

    if (!_enabled || BiometricService.isUnlocked) {
      return widget.child;
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 52),
                const SizedBox(height: 12),
                const Text(
                  ' FarmVest App Locked',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                // const SizedBox(height: 6),
                // const Text(
                //   'Authenticate to continue',
                //   textAlign: TextAlign.center,
                // ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isAuthenticating ? null : _authenticate,
                  child: Text('unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
