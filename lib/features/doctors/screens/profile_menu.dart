// import 'package:flutter/services.dart';
// import 'package:farm_vest/core/theme/app_theme.dart';
// import 'package:farm_vest/core/theme/app_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class ProfileMenuScreen extends StatefulWidget {
//   const ProfileMenuScreen({super.key});

//   @override
//   State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
// }

// class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController(text: 'Umasankar');
//   final _emailController = TextEditingController(text: 'umaa@markwave.ai');
//   final _phoneController = TextEditingController(text: '6305447441');
//   final _addressController = TextEditingController(
//     text: 'Westgodavari district, Andhra Pradesh',
//   );
//   final _dateController = TextEditingController(text: '30/01/2026');

//   static const Color orange = Color(0xFFFCA222);

//   Future<void> _launchURL(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   void _showDeleteAccountDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Account'),
//         content: const Text(
//           'Are you sure you want to delete your account? This action is permanent and will remove all your data. You will be redirected to our website to complete the process.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _launchURL(AppConstants.deleteAccountUrl);
//             },
//             child: const Text(
//               'Delete',
//               style: const TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: GestureDetector(
//         onTap: () => Navigator.pop(context),
//         behavior: HitTestBehavior.translucent,
//         child: SizedBox(
//           width: size.width * 0.75,
//           height: size.height,
//           child: GestureDetector(
//             onTap: () {}, // Prevents taps inside the menu from closing it
//             child: Container(
//               color: AppTheme.primary,
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.fromLTRB(
//                   20,
//                   MediaQuery.of(context).padding.top + 12,
//                   20,
//                   30,
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       LayoutBuilder(
//                         builder: (context, constraints) {
//                           final logoWidth =
//                               constraints.maxWidth *
//                               0.55; // ~140px on normal phones
//                           final logoHeight =
//                               logoWidth * (55 / 140); // maintain aspect ratio

//                           return Image.asset(
//                             'assets/images/farmvestlogo(1).png',
//                             width: logoWidth,
//                             height: logoHeight,
//                             fit: BoxFit.contain,
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 24),

//                       Center(
//                         child: Column(
//                           children: const [
//                             Text(
//                               'My Profile',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             SizedBox(height: 12),
//                             CircleAvatar(
//                               radius: 31,
//                               backgroundColor: Colors.white,
//                               child: Icon(
//                                 Icons.person,
//                                 size: 24,
//                                 // color: Colors.grey,
//                                 color: Color(0xFF30572B),
//                               ),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Umasankar',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w200,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             Text(
//                               'umaa@markwave.ai',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w200,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 28),

//                       _label('Full Name'),
//                       _inputField(
//                         _nameController,
//                         validator: (v) {
//                           if (v == null || v.trim().isEmpty) {
//                             return 'Full name is required';
//                           }
//                           if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v)) {
//                             return 'Only letters allowed';
//                           }
//                           return null;
//                         },
//                       ),

//                       _label('Email'),
//                       _inputField(
//                         _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (v) {
//                           if (v == null || v.isEmpty) {
//                             return 'Email is required';
//                           }
//                           if (!RegExp(
//                             r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//                           ).hasMatch(v)) {
//                             return 'Enter valid email';
//                           }
//                           return null;
//                         },
//                       ),

//                       _label('Phone'),
//                       _inputField(
//                         _phoneController,
//                         keyboardType: TextInputType.phone,
//                         validator: (v) {
//                           if (v == null || v.isEmpty) {
//                             return 'Phone number required';
//                           }
//                           if (!RegExp(r'^\d{10}$').hasMatch(v)) {
//                             return 'Enter valid 10 digit number';
//                           }
//                           return null;
//                         },
//                       ),

//                       _label('Address'),
//                       _inputField(
//                         _addressController,
//                         maxLines: 2,
//                         height: 60,
//                         validator: (v) {
//                           if (v == null || v.trim().isEmpty) {
//                             return 'Address is required';
//                           }
//                           if (v.length < 5) {
//                             return 'Address too short';
//                           }
//                           return null;
//                         },
//                       ),

//                       _label('As a User Since'),
//                       _inputField(
//                         _dateController,
//                         // readOnly: true,
//                         onTap: _pickDate,
//                         validator: (v) {
//                           if (v == null || v.isEmpty) {
//                             return 'Please select a date';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 15),

//                       const Text(
//                         'Inventory',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       _simpleRow(title: 'Buffalo Profile'),

//                       const SizedBox(height: 20),

//                       _menuItem(
//                         icon: Icons.swap_horiz,
//                         title: 'Switch Role',
//                         subtitle: 'Currently as Investor',
//                       ),
//                       _menuItem(
//                         icon: Icons.lock_outline,
//                         title: 'App Lock',
//                         subtitle: 'Use biometric to unlock the app',
//                       ),
//                       _menuItem(
//                         icon: Icons.dark_mode_outlined,
//                         title: 'Dark Mode',
//                         subtitle: 'Disabled',
//                       ),
//                       _menuItem(
//                         icon: Icons.help_outline,
//                         title: 'Help & Support',
//                       ),
//                       _menuItem(
//                         icon: Icons.delete,
//                         title: 'Delete Account',
//                         onTap: _showDeleteAccountDialog,
//                       ),

//                       const SizedBox(height: 25),

//                       // 🔥 LOGOUT BUTTON (IMAGE ICON USED)
//                       Center(
//                         child: SizedBox(
//                           width: 220,
//                           height: 48,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: orange,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(60),
//                               ),
//                             ),
//                             onPressed: () {
//                               if (_formKey.currentState!.validate()) {
//                                 // logout logic
//                               }
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Text(
//                                   'Logout',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Image.asset(
//                                   'assets/icons/logout-rounded-icon.png',
//                                   width: 18,
//                                   height: 18,
//                                   fit: BoxFit.contain,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= HELPERS =================
//   Widget _label(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 15,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _inputField(
//     TextEditingController controller, {
//     String? Function(String?)? validator,
//     TextInputType keyboardType = TextInputType.text,
//     bool readOnly = false,
//     VoidCallback? onTap,
//     int maxLines = 1,
//     double height = 38,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         validator: validator,
//         readOnly: readOnly,
//         onTap: onTap,
//         maxLines: maxLines,

//         style: const TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w500,
//           color: Colors.black,
//         ),

//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white.withOpacity(0.65),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 10,
//           ),
//           errorStyle: const TextStyle(color: Colors.white, fontSize: 11),

//           // ✅ REMOVE OutlineInputBorder COMPLETELY
//           border: InputBorder.none,
//           enabledBorder: InputBorder.none,
//           focusedBorder: InputBorder.none,
//           errorBorder: InputBorder.none,
//           focusedErrorBorder: InputBorder.none,
//         ),
//       ),
//     );
//   }

//   Widget _menuItem(
//       {IconData? icon,
//       required String title,
//       String? subtitle,
//       VoidCallback? onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.white, size: 18),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(color: Colors.white)),
//                 if (subtitle != null)
//                   Text(
//                     subtitle,
//                     style: const TextStyle(color: Colors.white, fontSize: 11),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _simpleRow({required String title}) {
//     return Row(
//       children: [
//         // const Icon(color: Colors.white70, size: 18),
//         const SizedBox(width: 2),
//         Text(title, style: const TextStyle(color: Colors.white)),
//       ],
//     );
//   }

//   Future<void> _pickDate() async {
//     final Size screenSize = MediaQuery.of(context).size;

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),

//       // ✅ RESPONSIVE BUILDER
//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(
//             // Controls dialog size relative to SCREEN
//             textScaleFactor: screenSize.width < 400 ? 0.9 : 1.0,
//           ),
//           child: Center(
//             child: SizedBox(
//               width: screenSize.width * 0.8, // 90% of screen width
//               height: screenSize.height * 0.8, // 70% of screen height
//               child: child,
//             ),
//           ),
//         );
//       },
//     );

//     if (picked != null) {
//       _dateController.text =
//           '${picked.day.toString().padLeft(2, '0')}/'
//           '${picked.month.toString().padLeft(2, '0')}/'
//           '${picked.year}';
//     }
//   }
// }
