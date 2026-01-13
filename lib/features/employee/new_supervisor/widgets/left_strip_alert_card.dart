

// import 'package:flutter/material.dart';

// class LeftStripAlertCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color stripColor;

//   const LeftStripAlertCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.stripColor,
//   });

//   @override
//   Widget build(BuildContext context) {
   
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Container(
//       width: screenWidth * 0.95, 
      
      
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Stack(
//         children: [
          
//           Positioned(
//             left: 0,
//             top: 0,
//             bottom: 0,
//             child: Container(
//               width: 60,
//               decoration: BoxDecoration(
//                 color: stripColor,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(26),
//                   bottomLeft: Radius.circular(26),
//                 ),
//               ),
//             ),
//           ),
          
//           Positioned.fill(
//             left: 10, 
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(18),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child:
//                Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
                  
//                   Container(
//                     decoration: BoxDecoration(
//                       color: stripColor.withOpacity(0.15),
//                       shape: BoxShape.circle,
//                     ),
//                     padding: const EdgeInsets.all(12),
//                     child: Icon(icon, color: stripColor, size: 24),
//                   ),
//                   const SizedBox(width: 16),
                  
//                   Expanded(
//                     child: Column(
                    
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           subtitle,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
