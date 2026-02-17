import 'dart:async';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/utils/toast_utils.dart';
import 'package:farm_vest/core/widgets/primary_button.dart';
import 'package:farm_vest/features/investor/presentation/providers/investor_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../../../../core/providers/environment_provider.dart';
import '../../../../core/theme/app_constants.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class NewLoginScreen extends ConsumerStatefulWidget {
  NewLoginScreen({super.key});

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
  int _logoTapCount = 0;
  Timer? _tapResetTimer;
  final _phoneFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final mobileNumber = ref.read(authProvider).mobileNumber;
    _phoneController = TextEditingController(text: mobileNumber ?? '');
    _phoneNumber = mobileNumber ?? '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tapResetTimer?.cancel();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 24;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
      // Refresh investor data providers
      ref.invalidate(investorSummaryProvider);
      ref.invalidate(investorAnimalsProvider);
    }

    if (!mounted) return;

    switch (role) {
      case UserType.customer:
        context.go('/customer-dashboard');
        break;
      case UserType.supervisor:
        context.go('/supervisor-dashboard');
        break;
      case UserType.farmManager:
        context.go('/farm-manager-dashboard');
        break;
      case UserType.doctor:
        context.go('/doctor-dashboard');
        break;
      case UserType.assistant:
        context.go('/assistant-dashboard');
        break;
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

  void _handleLogoTap() {
    _tapResetTimer?.cancel();
    _logoTapCount++;
    if (_logoTapCount >= 5) {
      _logoTapCount = 0;
      _showDeveloperCodeDialog();
    } else {
      _tapResetTimer = Timer(Duration(seconds: 2), () {
        _logoTapCount = 0;
      });
    }
  }

  void _showDeveloperCodeDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Developer Mode'.tr(ref)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: InputDecoration(hintText: 'Enter Developer Code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(ref)),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text == '5963') {
                Navigator.pop(context);
                _showEnvironmentSelection();
              } else {
                ToastUtils.showError(context, 'Invalid Code'.tr(ref));
              }
            },
            child: Text('Submit'.tr(ref)),
          ),
        ],
      ),
    );
  }

  void _showEnvironmentSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Environment'.tr(ref)),
        content: Text('Choose which server to connect to:'.tr(ref)),
        actions: [
          TextButton(
            onPressed: () => _switchEnvironment(false),
            child: Text('LIVE'.tr(ref)),
          ),
          TextButton(
            onPressed: () => _switchEnvironment(true),
            child: Text('STAGING (Testing)'.tr(ref)),
          ),
        ],
      ),
    );
  }

  Future<void> _switchEnvironment(bool isStaging) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_staging', isStaging);

    if (isStaging) {
      AppConstants.useStaging();
      ref.read(isStagingProvider.notifier).state = true;
      if (mounted) ToastUtils.showSuccess(context, 'Switched to STAGING');
    } else {
      AppConstants.useLive();
      ref.read(isStagingProvider.notifier).state = false;
      if (mounted) ToastUtils.showSuccess(context, 'Switched to LIVE');
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withValues(alpha: 0.8),
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                  ]
                : [
                    AppTheme.primary,
                    AppTheme.primary.withValues(alpha: 0.85),
                    AppTheme.darkPrimary,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_showRoleSelection) {
                          setState(() {
                            _showRoleSelection = false;
                            _isOtpSent = false;
                            _otp = '';
                            _timer?.cancel();
                          });
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
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.white,
                          size: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Back'.tr(ref),
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // App Logo Area - Hides when keyboard is up to save space
              if (!_showRoleSelection &&
                  MediaQuery.of(context).viewInsets.bottom == 0)
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: _handleLogoTap,
                      child: Image.asset(
                        'assets/images/farmvest_logo.png',
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.agriculture,
                          size: 100,
                          color: isDark ? AppTheme.primary : AppTheme.white,
                        ),
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 20),

              // Title and subtitle
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey(
                    _showRoleSelection
                        ? 'role'
                        : (_isOtpSent ? 'otp' : 'login'),
                  ),
                  children: [
                    Text(
                      _showRoleSelection
                          ? 'Select Role'.tr(ref)
                          : (_isOtpSent
                                ? 'Verify Your Phone'.tr(ref)
                                : 'Welcome Back'.tr(ref)),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _showRoleSelection
                            ? 'Choose how you want to log in'.tr(ref)
                            : (_isOtpSent
                                  ? '${'Enter the 6-digit code sent to'.tr(ref)}\n+91 $_phoneNumber'
                                  : 'Enter your phone number to access your account'.tr(ref)),
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

              SizedBox(height: 40),

              // Form/Role Container - Expanded to take remaining space
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black45 : Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _showRoleSelection
                      ? _buildRoleSelection(theme, isDark)
                      : _buildLoginForm(authState, theme, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthState authState, ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10), // Shrunk the top spacing
          AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: _isOtpSent
                ? _buildOtpDisplay(theme, isDark)
                : _buildPhoneNumberDisplay(theme, isDark),
          ),
          SizedBox(height: 40),
          if (_isOtpSent) ...[
            _buildTimerSection(theme),
            SizedBox(height: 32),
          ],
          PrimaryButton(
            text: _isOtpSent ? 'Verify & Login'.tr(ref) : 'Continue'.tr(ref),
            isLoading: authState.isLoading,
            onPressed: (_isOtpSent
                ? (_otp.length == 6 ? _handleContinue : null)
                : (_phoneNumber.length == 10 ? _handleContinue : null)),
          ),
          SizedBox(height: 24),
          if (!_isOtpSent)
            Text(
              'By continuing, you agree to our Terms & Privacy Policy'.tr(ref),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRoleSelection(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      itemCount: _availableRoles.length,
      itemBuilder: (context, index) {
        final role = _availableRoles[index];

        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await ref.read(authProvider.notifier).selectRole(role);
                _navigateToDashboard(role);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: role.color.withOpacity(0.2),
                    width: 2,
                  ),
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  gradient: isDark
                      ? null
                      : LinearGradient(
                          colors: [role.color.withOpacity(0.05), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: role.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(role.icon, color: role.color, size: 28),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${'Log in as'.tr(ref)} ${role.label}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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

  Widget _buildTimerSection(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive the code? '.tr(ref),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            GestureDetector(
              onTap: _handleResend,
              child: AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _remainingSeconds == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                child: Text('Resend OTP'.tr(ref)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberDisplay(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number'.tr(ref),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceVariant
                : AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Country code picker style
              Row(
                children: [
                  Text('🇮🇳'.tr(ref), style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    '+91'.tr(ref),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
              SizedBox(width: 12),
              Container(
                height: 30,
                width: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              SizedBox(width: 16),
              // Input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => setState(() => _phoneNumber = value),
                  onSubmitted: (_) => _handleContinue(),

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 2.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Your Phone Number'.tr(ref),

                    hintStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      letterSpacing: 2.0,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpDisplay(ThemeData theme, bool isDark) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceVariant : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );

    return Column(
      children: [
        Pinput(
          focusNode: _otpFocusNode,
          length: 6,
          autofocus: true,
          keyboardType: TextInputType.number,

          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          separatorBuilder: (index) => SizedBox(width: 8),
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onChanged: (value) => setState(() => _otp = value),
          onCompleted: (value) {
            setState(() => _otp = value);
            _handleContinue();
          },
        ),
      ],
    );
  }
}
