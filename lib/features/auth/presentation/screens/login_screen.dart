// import 'package:farm_vest/core/theme/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:pinput/pinput.dart';
//
// import 'package:farm_vest/core/theme/app_theme.dart';
// import 'package:farm_vest/core/utils/toast_utils.dart';
// import 'package:farm_vest/features/investor/presentation/providers/buffalo_provider.dart';
// import '../providers/auth_provider.dart';
// import 'package:farm_vest/core/utils/app_enums.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _mobileController = TextEditingController();
//   final _otpController = TextEditingController();
//   bool _isOtpSent = false;
//
//   bool get _isMobileValid => _mobileController.text.trim().length == 10;
//   bool get _isOtpValid => _otpController.text.trim().length == 6;
//
//   @override
//   void initState() {
//     super.initState();
//     _mobileController.addListener(_onInputChanged);
//     _otpController.addListener(_onInputChanged);
//   }
//
//   void _onInputChanged() {
//     if (mounted) setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _mobileController.removeListener(_onInputChanged);
//     _otpController.removeListener(_onInputChanged);
//     _mobileController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//
//     return Scaffold(
//       backgroundColor: AppTheme.lightGrey,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(AppConstants.spacingL),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: AppConstants.spacingXL * 2),
//
//                 // Logo
//                 Center(
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: AppTheme.primary,
//                       borderRadius: BorderRadius.circular(50),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppTheme.primary.withValues(alpha: 0.3),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.agriculture,
//                       size: 50,
//                       color: AppTheme.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: AppConstants.spacingXL),
//
//                 // Title
//                 Center(
//                   child: Column(
//                     children: [
//                       const Text('Welcome Back', style: AppTheme.headingLarge),
//                       const SizedBox(height: AppConstants.spacingS),
//                       Text(
//                         _isOtpSent
//                             ? 'Enter the OTP sent to your WhatsApp'
//                             : 'Enter your mobile number to login',
//                         style: AppTheme.bodyMedium.copyWith(
//                           color: AppTheme.mediumGrey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: AppConstants.spacingXL),
//
//                 if (!_isOtpSent) ...[
//                   // Mobile Number Field
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppTheme.white,
//                       borderRadius: BorderRadius.circular(AppConstants.radiusM),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppTheme.dark.withOpacity(0.06),
//                           blurRadius: 12,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: TextFormField(
//                       controller: _mobileController,
//                       keyboardType: TextInputType.phone,
//                       autofillHints: const [AutofillHints.telephoneNumber],
//                       style: AppTheme.bodyLarge.copyWith(letterSpacing: 1.2),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(10),
//                       ],
//                       onChanged: (_) => setState(() {}),
//                       validator: (value) {
//                         if (value == null || value.length != 10) {
//                           return 'Enter a valid 10-digit mobile number';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         labelText: 'Mobile Number',
//                         hintText: 'Enter 10-digit number',
//                         floatingLabelBehavior: FloatingLabelBehavior.auto,
//
//                         prefixIcon: const Icon(
//                           Icons.phone_android,
//                           size: 22,
//                           color: AppTheme.primary,
//                         ),
//
//                         filled: true,
//                         fillColor: Colors.transparent,
//
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 18,
//                           horizontal: 16,
//                         ),
//
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AppConstants.radiusM,
//                           ),
//                           borderSide: BorderSide(
//                             color: AppTheme.mediumGrey.withOpacity(0.4),
//                             width: 1,
//                           ),
//                         ),
//
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AppConstants.radiusM,
//                           ),
//                           borderSide: const BorderSide(
//                             color: AppTheme.primary,
//                             width: 2,
//                           ),
//                         ),
//
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AppConstants.radiusM,
//                           ),
//                           borderSide: const BorderSide(
//                             color: AppTheme.errorRed,
//                             width: 1.2,
//                           ),
//                         ),
//
//                         focusedErrorBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             AppConstants.radiusM,
//                           ),
//                           borderSide: const BorderSide(
//                             color: AppTheme.errorRed,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ] else ...[
//                   // OTP Field
//                   // OTP Field (Box Style)
//                   Container(
//                     decoration: BoxDecoration(
//                       // color: AppTheme.white,
//                       borderRadius: BorderRadius.circular(AppConstants.radiusM),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppTheme.dark.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     child: Center(
//                       child: Pinput(
//                         length: 6,
//                         controller: _otpController,
//                         keyboardType: TextInputType.number,
//                         autofocus: true,
//                         onChanged: (value) {
//                           setState(() {});
//                         },
//                         onCompleted: (value) {
//                           setState(() {});
//                           // Optional: auto-verify when OTP complete
//                           // _handleVerifyOtp();
//                         },
//                         validator: (value) {
//                           if (value == null || value.length != 6) {
//                             return 'Enter valid 6 digit OTP';
//                           }
//                           return null;
//                         },
//                         defaultPinTheme: PinTheme(
//                           width: 48,
//                           height: 55,
//                           textStyle: AppTheme.bodyLarge.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: AppTheme.mediumGrey),
//                           ),
//                         ),
//                         focusedPinTheme: PinTheme(
//                           width: 48,
//                           height: 55,
//                           textStyle: AppTheme.bodyLarge.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: AppTheme.primary,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         submittedPinTheme: PinTheme(
//                           width: 48,
//                           height: 55,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: AppTheme.primary.withOpacity(0.1),
//                             border: Border.all(color: AppTheme.primary),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//
//                 const SizedBox(height: AppConstants.spacingXL),
//
//                 // Action Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: authState.isLoading
//                         ? null
//                         : (_isOtpSent
//                               ? (_isOtpValid ? _handleVerifyOtp : null)
//                               : (_isMobileValid ? _handleSendOtp : null)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primary,
//                       foregroundColor: AppTheme.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           AppConstants.radiusM,
//                         ),
//                       ),
//                       elevation: 4,
//                       shadowColor: AppTheme.primary.withValues(alpha: 0.4),
//                     ),
//                     child: authState.isLoading
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               color: AppTheme.white,
//                               strokeWidth: 2.5,
//                             ),
//                           )
//                         : Text(
//                             _isOtpSent ? 'Verify & Login' : 'Get OTP',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//
//                 if (_isOtpSent)
//                   Padding(
//                     padding: const EdgeInsets.only(top: AppConstants.spacingM),
//                     child: Center(
//                       child: TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _isOtpSent = false;
//                             _otpController.clear();
//                           });
//                         },
//                         child: const Text('Change Mobile Number'),
//                       ),
//                     ),
//                   ),
//
//                 const SizedBox(height: AppConstants.spacingXL * 2),
//
//                 // Powered by MarkWave
//                 const Center(
//                   child: Text(
//                     AppConstants.poweredBy,
//                     style: AppTheme.bodySmall,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handleSendOtp() async {
//     if (_formKey.currentState!.validate()) {
//       final mobile = _mobileController.text.trim();
//       final response = await ref
//           .read(authProvider.notifier)
//           .sendWhatsappOtp(mobile);
//
//       if (mounted) {
//         if (response != null) {
//           if (response.status) {
//             setState(() {
//               _isOtpSent = true;
//             });
//             ToastUtils.showSuccess(
//               context,
//               response.message ?? 'OTP sent successfully',
//             );
//             // For testing:
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //  SnackBar(content: Text('OTP sent: ${response.otp}')),
//             // );
//           } else {
//             // API returned success=200 but logic failed (e.g. User not found)
//             ToastUtils.showError(
//               context,
//               response.message ?? 'Failed to send OTP',
//             );
//           }
//         } else {
//           ToastUtils.showError(
//             context,
//             'Failed to connect to server. Please try again.',
//           );
//         }
//       }
//     }
//   }
//
//   void _handleVerifyOtp() async {
//     if (_formKey.currentState!.validate()) {
//       final enteredOtp = _otpController.text.trim();
//       final isValid = ref
//           .read(authProvider.notifier)
//           .verifyWhatsappOtpLocal(enteredOtp);
//
//       if (isValid) {
//         final mobile = _mobileController.text.trim();
//
//         // Complete login and fetch user data
//         final loginData = await ref
//             .read(authProvider.notifier)
//             .completeLoginWithData(mobile);
//
//         if (!mounted) return;
//
//         final role = loginData['role'] as UserType;
//
//         // Invalidate buffalo provider to trigger data fetch for customer role
//         if (role == UserType.customer) {
//           // This will trigger the unitResponseProvider to fetch fresh data
//           ref.invalidate(unitResponseProvider);
//         }
//
//         if (!mounted) return;
//
//         switch (role) {
//           case UserType.customer:
//             context.go('/customer-dashboard');
//             break;
//           case UserType.supervisor:
//             context.go('/supervisor-dashboard');
//             break;
//           case UserType.doctor:
//             context.go('/doctor-dashboard');
//             break;
//           case UserType.assistant:
//             context.go('/assistant-dashboard');
//             break;
//           case UserType.admin:
//             context.go('/admin-dashboard');
//             break;
//           default:
//             // fallback
//             context.go('/customer-dashboard');
//         }
//       } else {
//         if (mounted) {
//           ToastUtils.showError(context, 'Invalid OTP');
//         }
//       }
//     }
//   }
// }
