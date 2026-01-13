
// import 'package:flutter/material.dart';

// class QuickActionCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color iconColor; 
//   final VoidCallback onTap;

//   const QuickActionCard({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.iconColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return 
//     InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white, // white card background
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
           
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.2), 
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: iconColor,
//                 size: 28,
//               ),
//             ),

//             const SizedBox(height: 12),

           
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
