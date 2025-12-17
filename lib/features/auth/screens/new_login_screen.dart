import '../../../core/widgets/primary_button.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/toast_utils.dart';
import '../../customer/providers/buffalo_provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/app_enums.dart';

class NewLoginScreen extends ConsumerStatefulWidget {
  const NewLoginScreen({super.key});

  @override
  ConsumerState<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends ConsumerState<NewLoginScreen> {
  String _phoneNumber = '';
  String _otp = '';
  bool _isOtpSent = false;
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

  Future<void> _handleContinue() async {
    if (!_isOtpSent) {
      // Send OTP
      if (_phoneNumber.length == 10) {
        final response = await ref
            .read(authProvider.notifier)
            .sendWhatsappOtp(_phoneNumber);

        if (mounted) {
          if (response != null && response.status) {
            setState(() {
              _isOtpSent = true;
              _otp = '';
            });
            _startTimer();
            ToastUtils.showSuccess(
              context,
              response.message ?? 'OTP sent successfully',
            );
          } else {
            ToastUtils.showError(
              context,
              response?.message ?? 'Failed to send OTP',
            );
          }
        }
      }
    } else {
      // Verify OTP
      if (_otp.length == 6) {
        final isValid = ref
            .read(authProvider.notifier)
            .verifyWhatsappOtpLocal(_otp);

        if (isValid) {
          final loginData = await ref
              .read(authProvider.notifier)
              .completeLoginWithData(_phoneNumber);

          if (!mounted) return;

          final role = loginData['role'] as UserType;

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
            case UserType.admin:
              context.go('/admin-dashboard');
              break;
            default:
              context.go('/customer-dashboard');
          }
        } else {
          if (mounted) {
            ToastUtils.showError(context, 'Invalid OTP');
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_isOtpSent) {
                        setState(() {
                          _isOtpSent = false;
                          _otp = '';
                          _timer?.cancel();
                        });
                      } else {
                        context.go('/onboarding');
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: AppTheme.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Back',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Tractor Icon
            const Icon(Icons.agriculture, size: 80, color: AppTheme.white),

            const SizedBox(height: 24),

            // Title and subtitle
            Text(
              _isOtpSent ? 'Verify Your Phone' : 'Phone Number',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),

            const SizedBox(height: 12),

            if (!_isOtpSent)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Please enter your phone number to register to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.white,
                    height: 1.4,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Please enter the 6 digit code sent to\n+91 $_phoneNumber',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.white,
                    height: 1.4,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // White content area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Phone number or OTP display
                    if (!_isOtpSent)
                      _buildPhoneNumberDisplay()
                    else
                      _buildOtpDisplay(),

                    const SizedBox(height: 32),

                    // Timer and resend (OTP screen only)
                    if (_isOtpSent) ...[
                      Text(
                        '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.mediumGrey,
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleResend,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _remainingSeconds == 0
                                    ? AppTheme.primary
                                    : AppTheme.mediumGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Continue/Verify button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: PrimaryButton(
                        text: _isOtpSent ? 'Verify' : 'Continue',
                        isLoading: authState.isLoading,
                        onPressed: (_isOtpSent
                            ? (_otp.length == 6 ? _handleContinue : null)
                            : (_phoneNumber.length == 10
                                  ? _handleContinue
                                  : null)),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Country code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.mediumGrey.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                const Text(
                  '+91',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppTheme.mediumGrey,
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Phone number input
          Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() => _phoneNumber = value);
              },
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.dark,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mediumGrey.withOpacity(0.4),
                  letterSpacing: 1.5,
                ),
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.mediumGrey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.mediumGrey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpDisplay() {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppTheme.dark,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.mediumGrey.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.primary, width: 2)),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.primary, width: 2)),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Pinput(
        length: 6,
        autofocus: true,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        onChanged: (value) {
          setState(() => _otp = value);
        },
        onCompleted: (value) {
          setState(() => _otp = value);
        },
      ),
    );
  }
}
