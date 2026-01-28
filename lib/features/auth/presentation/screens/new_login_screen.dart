import 'dart:async';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:farm_vest/features/investor/presentation/providers/buffalo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../providers/auth_provider.dart';

class NewLoginScreen extends ConsumerStatefulWidget {
  const NewLoginScreen({super.key});

  @override
  ConsumerState<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends ConsumerState<NewLoginScreen> {
  String _phoneNumber = '';
  String _otp = '';
  bool _isOtpSent = false;
  bool _showRoleSelection = false;
  List<UserType> _availableRoles = [];
  Timer? _timer;
  int _remainingSeconds = 24;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 24;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  // 1. Centralized navigation logic
  void _navigateToDashboard(UserType role) {
    if (role == UserType.customer) {
      ref.invalidate(unitResponseProvider);
    }

    if (!mounted) return;

    switch (role) {
      case UserType.customer:
        context.go('/customer-dashboard');
        break;
      case UserType.supervisor:
        context.go('/supervisor-dashboard');
        break;
      case UserType.doctor:
        context.go('/doctor-dashboard');
        break;
      case UserType.assistant:
        context.go('/assistant-dashboard');
        break;
      case UserType.farmManager:
        context.go('/farm-manager-dashboard');
        break;
      case UserType.admin:
        context.go('/admin-dashboard');
        break;
      default:
        context.go('/customer-dashboard');
    }
  }

  Future<void> _handleContinue() async {
    if (!_isOtpSent) {
      if (_phoneNumber.length == 10) {
        final response = await ref
            .read(authProvider.notifier)
            .sendWhatsappOtp(_phoneNumber);

        if (response != null && response.status) {
          if (mounted) {
            setState(() {
              _isOtpSent = true;
              _otp = '';
            });
            _startTimer();
          }
        } else {
          if (mounted) {
            final error = ref.read(authProvider).error;
            ToastUtils.showError(
              context,
              error ?? 'Failed to send OTP. Please try again.',
            );
          }
        }
      }
    } else {
      if (_otp.length == 6) {
        final loginData = await ref
            .read(authProvider.notifier)
            .loginWithOtp(_phoneNumber, _otp);

        if (loginData != null) {
          final List<UserType> roles = loginData['roles'] as List<UserType>;
          if (roles.length > 1) {
            setState(() {
              _availableRoles = roles;
              _showRoleSelection = true;
            });
          } else {
            _navigateToDashboard(roles.first);
          }
        } else {
          if (mounted) {
            final error = ref.read(authProvider).error;
            ToastUtils.showError(
              context,
              error ?? 'Invalid OTP or failed to login.',
            );
          }
        }
      }
    }
  }

  Future<void> _handleResend() async {
    if (_remainingSeconds == 0) {
      final response = await ref
          .read(authProvider.notifier)
          .sendWhatsappOtp(_phoneNumber);

      if (mounted) {
        if (response != null && response.status) {
          _startTimer();
          setState(() => _otp = '');
          ToastUtils.showSuccess(context, 'OTP resent successfully');
        } else {
          ToastUtils.showError(context, 'Failed to resend OTP');
        }
      }
    }
  }

  Map<String, dynamic> _getRoleInfo(UserType role) {
    switch (role) {
      case UserType.admin:
        return {
          'label': 'Administrator',
          'icon': Icons.admin_panel_settings,
          'color': Colors.blue,
        };
      case UserType.farmManager:
        return {
          'label': 'Farm Manager',
          'icon': Icons.agriculture,
          'color': Colors.green,
        };
      case UserType.supervisor:
        return {
          'label': 'Supervisor',
          'icon': Icons.assignment_ind,
          'color': Colors.orange,
        };
      case UserType.doctor:
        return {
          'label': 'Doctor',
          'icon': Icons.medical_services,
          'color': Colors.red,
        };
      case UserType.assistant:
        return {
          'label': 'Assistant Doctor',
          'icon': Icons.health_and_safety,
          'color': Colors.teal,
        };
      case UserType.customer:
        return {
          'label': 'Investor',
          'icon': Icons.trending_up,
          'color': Colors.indigo,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withOpacity(0.85),
              AppTheme.darkPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_showRoleSelection) {
                          setState(() => _showRoleSelection = false);
                        } else if (_isOtpSent) {
                          setState(() {
                            _isOtpSent = false;
                            _otp = '';
                            _timer?.cancel();
                          });
                        } else {
                          context.go('/onboarding');
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Back',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // App Logo Area (Shrink if role selection is visible)
              if (!_showRoleSelection)
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/farmvest_logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.agriculture,
                        size: 100,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Title and subtitle
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(
                    _showRoleSelection
                        ? 'role'
                        : (_isOtpSent ? 'otp' : 'login'),
                  ),
                  children: [
                    Text(
                      _showRoleSelection
                          ? 'Select Role'
                          : (_isOtpSent ? 'Verify Your Phone' : 'Welcome Back'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _showRoleSelection
                            ? 'Choose how you want to log in'
                            : (_isOtpSent
                                  ? 'Enter the 6-digit code sent to\n+91 $_phoneNumber'
                                  : 'Enter your phone number to access your account'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.white.withOpacity(0.8),
                          height: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Form/Role Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _showRoleSelection
                      ? _buildRoleSelection()
                      : _buildLoginForm(authState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthState authState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 50),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isOtpSent ? _buildOtpDisplay() : _buildPhoneNumberDisplay(),
          ),
          const SizedBox(height: 40),
          if (_isOtpSent) ...[_buildTimerSection(), const SizedBox(height: 32)],
          PrimaryButton(
            text: _isOtpSent ? 'Verify & Login' : 'Continue',
            isLoading: authState.isLoading,
            onPressed: (_isOtpSent
                ? (_otp.length == 6 ? _handleContinue : null)
                : (_phoneNumber.length == 10 ? _handleContinue : null)),
          ),
          const SizedBox(height: 24),
          if (!_isOtpSent)
            Text(
              'By continuing, you agree to our Terms & Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.slate.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      itemCount: _availableRoles.length,
      itemBuilder: (context, index) {
        final role = _availableRoles[index];
        final info = _getRoleInfo(role);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await ref.read(authProvider.notifier).selectRole(role);
                _navigateToDashboard(role);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (info['color'] as Color).withOpacity(0.2),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      (info['color'] as Color).withOpacity(0.05),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (info['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        info['icon'] as IconData,
                        color: info['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info['label'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log in as ${info['label']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.slate.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
            ),
            GestureDetector(
              onTap: _handleResend,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _remainingSeconds == 0
                      ? AppTheme.primary
                      : AppTheme.mediumGrey.withOpacity(0.5),
                ),
                child: const Text('Resend OTP'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.slate.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Country code picker style
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppTheme.slate,
                    ),
                  ],
                ),
              ),
              Container(height: 30, width: 1, color: Colors.black12),
              const SizedBox(width: 16),
              // Input
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => setState(() => _phoneNumber = value),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dark,
                    letterSpacing: 2.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: '00000 00000',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black26,
                      letterSpacing: 2.0,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpDisplay() {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppTheme.dark,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.05)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppTheme.primary, width: 1.5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Pinput(
          length: 6,
          autofocus: true,
          keyboardType: TextInputType.number,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          separatorBuilder: (index) => const SizedBox(width: 8),
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onChanged: (value) => setState(() => _otp = value),
          onCompleted: (value) => setState(() => _otp = value),
        ),
      ],
    );
  }
}
