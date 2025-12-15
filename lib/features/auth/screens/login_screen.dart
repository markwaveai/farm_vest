import 'package:farm_vest/core/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/toast_utils.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spacingXL * 2),

                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 50,
                      color: AppTheme.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),

                // Title
                Center(
                  child: Column(
                    children: [
                      const Text('Welcome Back', style: AppTheme.headingLarge),
                      const SizedBox(height: AppConstants.spacingS),
                      Text(
                        _isOtpSent
                            ? 'Enter the OTP sent to your WhatsApp'
                            : 'Enter your mobile number to login',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),

                if (!_isOtpSent) ...[
                  // Mobile Number Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      style: AppTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: const Icon(
                          Icons.phone_android,
                          color: AppTheme.primary,
                        ),
                        hintText: 'Enter your mobile number',
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        // Simple regex for testing, can be more strict if needed
                        if (value.length < 10) {
                          return 'Please enter a valid mobile number';
                        }
                        return null;
                      },
                    ),
                  ),
                ] else ...[
                  // OTP Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      style: AppTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp OTP',
                        prefixIcon: const Icon(
                          Icons.lock_clock,
                          color: AppTheme.primary,
                        ),
                        hintText: 'Enter OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusM,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        return null;
                      },
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingXL),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : (_isOtpSent ? _handleVerifyOtp : _handleSendOtp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      elevation: 4,
                      shadowColor: AppTheme.primary.withOpacity(0.4),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isOtpSent ? 'Verify & Login' : 'Get OTP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                if (_isOtpSent)
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.spacingM),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            _otpController.clear();
                          });
                        },
                        child: const Text('Change Mobile Number'),
                      ),
                    ),
                  ),

                const SizedBox(height: AppConstants.spacingXL * 2),

                // Powered by MarkWave
                const Center(
                  child: Text(
                    AppConstants.poweredBy,
                    style: AppTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendOtp() async {
    if (_formKey.currentState!.validate()) {
      final mobile = _mobileController.text.trim();
      final response = await ref
          .read(authProvider.notifier)
          .sendWhatsappOtp(mobile);

      if (mounted) {
        if (response != null) {
          if (response.status) {
            setState(() {
              _isOtpSent = true;
            });
            ToastUtils.showSuccess(
              context,
              response.message ?? 'OTP sent successfully',
            );
            // For testing:
            // ScaffoldMessenger.of(context).showSnackBar(
            //  SnackBar(content: Text('OTP sent: ${response.otp}')),
            // );
          } else {
            // API returned success=200 but logic failed (e.g. User not found)
            ToastUtils.showError(
              context,
              response.message ?? 'Failed to send OTP',
            );
          }
        } else {
          ToastUtils.showError(
            context,
            'Failed to connect to server. Please try again.',
          );
        }
      }
    }
  }

  void _handleVerifyOtp() async {
    if (_formKey.currentState!.validate()) {
      final enteredOtp = _otpController.text.trim();
      final isValid = ref
          .read(authProvider.notifier)
          .verifyWhatsappOtpLocal(enteredOtp);

      if (isValid) {
        final mobile = _mobileController.text.trim();
        // Proceed to role setup
        final role = await ref
            .read(authProvider.notifier)
            .completeLogin(mobile);

        if (!mounted) return;

        switch (role) {
          case UserRole.customer:
            context.go('/customer-dashboard');
            break;
          case UserRole.supervisor:
            context.go('/supervisor-dashboard');
            break;
          case UserRole.doctor:
            context.go('/doctor-dashboard');
            break;
          case UserRole.assistant:
            context.go('/assistant-dashboard');
            break;
          default:
            // fallback
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
