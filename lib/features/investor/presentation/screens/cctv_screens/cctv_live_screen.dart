// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:video_player/video_player.dart';
// import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
// import '../providers/buffalo_provider.dart';

// class CCTVLiveScreen extends ConsumerStatefulWidget {
//   CCTVLiveScreen({super.key});

//   @override
//   ConsumerState<CCTVLiveScreen> createState() => _CCTVLiveScreenState();
// }

// class _CCTVLiveScreenState extends ConsumerState<CCTVLiveScreen> {
//   final Map<String, List<VideoPlayerController>> _shedControllers = {};
//   int _selectedShedIndex = 0;
//   int _mainAngleIndex = 0;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _initAllFeeds();
//   }

//   Future<void> _initAllFeeds() async {
//     try {
//       final feeds = await ref.read(cctvFeedsProvider.future);
//       if (feeds.isEmpty) {
//         if (mounted)
//           setState(() {
//             _error = "No camera feeds available.";
//           });
//         return;
//       }

//       for (var i = 0; i < feeds.length; i++) {
//         final shedName = feeds[i]['name'] as String;
//         final urls = feeds[i]['urls'] as List<String>;
//         final controllers = urls
//             .map((url) => VideoPlayerController.networkUrl(Uri.parse(url)))
//             .toList();

//         await Future.wait(controllers.map((c) => c.initialize()));
//         for (var c in controllers) {
//           c.play();
//           c.setLooping(true);
//         }
//         _shedControllers[shedName] = controllers;
//       }

//       if (mounted) setState(() {});
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           _error = "Failed to load camera feeds.";
//         });
//     }
//   }

//   @override
//   void dispose() {
//     for (var list in _shedControllers.values) {
//       for (var c in list) {
//         c.dispose();
//       }
//     }
//     super.dispose();
//   }

//   void _onAngleTapped(int index) {
//     setState(() {
//       _mainAngleIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final feedsAsync = ref.watch(cctvFeedsProvider);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(
//           'Live Camera Feed',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.black,
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: SafeArea(
//         child: feedsAsync.when(
//           loading: () => _buildLoadingState(),
//           error: (err, stack) => _buildErrorState(err.toString()),
//           data: (feeds) {
//             if (feeds.isEmpty || _shedControllers.isEmpty) {
//               return _buildErrorState(
//                 _error ?? "No camera feeds found for your units.",
//               );
//             }

//             final currentShed = feeds[_selectedShedIndex];
//             final shedName = currentShed['name'] as String;
//             final controllers = _shedControllers[shedName] ?? [];

//             if (controllers.isEmpty) return _buildLoadingState();

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (feeds.length > 1) _buildShedSelector(feeds),

//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Shed: $shedName',
//                         style: TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14,
//                         ),
//                       ),
//                       Text(
//                         'Angle ${_mainAngleIndex + 1}',
//                         style: TextStyle(
//                           color: AppTheme.secondary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     margin: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.white24),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: _buildVideoPlayer(controllers[_mainAngleIndex]),
//                     ),
//                   ),
//                 ),

//                 Padding(
//                   padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//                   child: Text(
//                     'Viewing Angles',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),

//                 SizedBox(
//                   height: 110,
//                   child: ListView.builder(
//                     padding: EdgeInsets.symmetric(horizontal: 8),
//                     scrollDirection: Axis.horizontal,
//                     itemCount: controllers.length,
//                     itemBuilder: (context, index) {
//                       return _buildThumbnail(index, controllers[index]);
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildShedSelector(List<Map<String, dynamic>> feeds) {
//     return Container(
//       height: 50,
//       margin: EdgeInsets.symmetric(vertical: 8),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: feeds.length,
//         itemBuilder: (context, index) {
//           final isSelected = _selectedShedIndex == index;
//           return GestureDetector(
//             onTap: () => setState(() {
//               _selectedShedIndex = index;
//               _mainAngleIndex = 0;
//             }),
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 8),
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: isSelected ? AppTheme.primary : Colors.white10,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 feeds[index]['name'],
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : Colors.white60,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: AppTheme.secondary),
//           SizedBox(height: 16),
//           Text(
//             'Connecting to live feeds...',
//             style: TextStyle(color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String message) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.videocam_off_rounded,
//               size: 64,
//               color: Colors.white24,
//             ),
//             SizedBox(height: 16),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white70),
//             ),
//             SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => _initAllFeeds(),
//               child: Text('Retry'.tr(ref)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoPlayer(VideoPlayerController controller) {
//     if (!controller.value.isInitialized) {
//       return Center(child: CircularProgressIndicator());
//     }
//     return AspectRatio(
//       aspectRatio: controller.value.aspectRatio,
//       child: VideoPlayer(controller),
//     );
//   }

//   Widget _buildThumbnail(int index, VideoPlayerController controller) {
//     final isSelected = index == _mainAngleIndex;

//     return GestureDetector(
//       onTap: () => _onAngleTapped(index),
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 6.0),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? AppTheme.secondary : Colors.white12,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         width: 140,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               _buildVideoPlayer(controller),
//               if (!isSelected) Container(color: Colors.black45),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: EdgeInsets.symmetric(vertical: 2),
//                   child: Text(
//                     'Angle ${index + 1}',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
