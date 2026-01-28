// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:video_player/video_player.dart';
// import 'package:farm_vest/core/theme/app_theme.dart';
// import '../providers/buffalo_provider.dart';

// class CCTVMainScreen extends ConsumerStatefulWidget {
//   const CCTVMainScreen({super.key});

//   @override
//   ConsumerState<CCTVMainScreen> createState() => _CCTVMainScreenState();
// }

// class _CCTVMainScreenState extends ConsumerState<CCTVMainScreen> {
//   final List<String> _videoUrls = [];
//   final List<String> _cameraNames = [];

//   List<VideoPlayerController?> _controllers = [];
//   int _mainPlayerIndex = 0;
//   bool _isLoading = true;
//   bool _isGridView = true;
//   List<bool> _cameraStatus = [];
//   final List<Timer> _timers = [];

//   @override
//   void initState() {
//     super.initState();
//     // Dynamic initialization based on provider data
//     WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
//   }

//   void _initializeData() {
//     final buffalosAsync = ref.read(rawBuffaloListProvider);
//     buffalosAsync.whenData((buffalos) {
//       // Collect unique shed CCTV URLs
//       final Map<String, String> shedCctvs = {};
//       for (var animal in buffalos) {
//         if (animal.cctvUrl != null && animal.cctvUrl!.isNotEmpty) {
//           shedCctvs[animal.shedNumber ?? animal.farmName ?? 'Unknown'] =
//               animal.cctvUrl!;
//         }
//       }

//       if (mounted) {
//         setState(() {
//           if (shedCctvs.isEmpty) {
//             // Fallback default URLs if none assigned
//             _videoUrls.addAll([
//               'http://161.97.182.208:8888/stream1/index.m3u8',
//               'http://161.97.182.208:8888/stream2/index.m3u8',
//             ]);
//             _cameraNames.addAll(['Default Camera 1', 'Default Camera 2']);
//           } else {
//             shedCctvs.forEach((name, url) {
//               _videoUrls.add(url);
//               _cameraNames.add('Shed $name');
//             });
//           }

//           _cameraStatus = List.generate(_videoUrls.length, (index) => false);
//           _controllers = _videoUrls
//               .map((url) => VideoPlayerController.network(url))
//               .toList();
//         });
//         _initializeVideoControllers();
//       }
//     });
//   }

//   void _initializeVideoControllers() {
//     for (int i = 0; i < _controllers.length; i++) {
//       final controller = _controllers[i];
//       if (controller == null) continue;

//       controller.addListener(() {
//         if (controller.value.isInitialized && controller.value.isPlaying) {
//           if (mounted) {
//             setState(() {
//               _cameraStatus[i] = true;
//             });
//           }
//         }
//       });

//       controller
//           .initialize()
//           .then((_) {
//             if (!mounted) return;
//             controller.play();
//             controller.setLooping(true);

//             final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
//               if (!mounted) {
//                 timer.cancel();
//                 return;
//               }
//               if (controller.value.isInitialized &&
//                   !controller.value.isPlaying) {
//                 controller.play();
//               }
//             });
//             _timers.add(timer);

//             if (_cameraStatus.every((status) => status || !status)) {
//               setState(() => _isLoading = false);
//             }
//           })
//           .catchError((error) {
//             if (mounted) {
//               setState(() => _cameraStatus[i] = false);
//               if (_cameraStatus.length == _videoUrls.length) {
//                 setState(() => _isLoading = false);
//               }
//             }
//           });
//     }
//   }

//   @override
//   void dispose() {
//     for (var timer in _timers) {
//       timer.cancel();
//     }
//     for (var controller in _controllers) {
//       controller?.dispose();
//     }
//     super.dispose();
//   }

//   void _onThumbnailTapped(int index) {
//     setState(() => _mainPlayerIndex = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_videoUrls.isEmpty && !_isLoading) {
//       return Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           title: const Text('Live CCTV'),
//         ),
//         body: const Center(
//           child: Text(
//             'No CCTV cameras assigned to your sheds.',
//             style: TextStyle(color: Colors.white70),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text(
//           _isGridView ? 'All Cameras' : _cameraNames[_mainPlayerIndex],
//           style: AppTheme.bodyMedium.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isGridView ? Icons.video_call : Icons.grid_view,
//               color: Colors.white,
//               size: 28,
//             ),
//             onPressed: () => setState(() => _isGridView = !_isGridView),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: _isLoading
//             ? _buildLoadingState()
//             : _isGridView
//             ? _buildGridView()
//             : _buildMainView(),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(color: AppTheme.white),
//           SizedBox(height: 16),
//           Text(
//             'Loading Camera Feeds...',
//             style: TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 3,
//           child: _buildVideoPlayer(
//             _controllers[_mainPlayerIndex],
//             _mainPlayerIndex,
//           ),
//         ),
//         SizedBox(
//           height: 120,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _controllers.length,
//             itemBuilder: (context, index) => _buildThumbnail(index),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGridView() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 8.0,
//           mainAxisSpacing: 8.0,
//           childAspectRatio: 16 / 9,
//         ),
//         itemCount: _controllers.length,
//         itemBuilder: (context, index) => _buildGridCamera(index),
//       ),
//     );
//   }

//   Widget _buildVideoPlayer(VideoPlayerController? controller, int cameraIndex) {
//     if (controller == null || !_cameraStatus[cameraIndex]) {
//       return Container(
//         color: Colors.grey[900],
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.videocam_off, color: Colors.red[400], size: 32),
//               const SizedBox(height: 8),
//               Text(
//                 'Camera Offline',
//                 style: TextStyle(color: Colors.red[400], fontSize: 12),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 _cameraNames[cameraIndex],
//                 style: const TextStyle(color: Colors.white54, fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (!controller.value.isInitialized) {
//       return Container(
//         color: Colors.grey[900],
//         child: const Center(
//           child: CircularProgressIndicator(
//             color: Colors.white54,
//             strokeWidth: 2,
//           ),
//         ),
//       );
//     }

//     return AspectRatio(
//       aspectRatio: controller.value.aspectRatio > 0
//           ? controller.value.aspectRatio
//           : 16 / 9,
//       child: VideoPlayer(controller),
//     );
//   }

//   Widget _buildThumbnail(int index) {
//     final controller = _controllers[index];
//     final isSelected = index == _mainPlayerIndex;

//     return GestureDetector(
//       onTap: () => _onThumbnailTapped(index),
//       child: Container(
//         margin: const EdgeInsets.all(4.0),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isSelected ? AppTheme.secondary : Colors.transparent,
//             width: 3,
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         width: 150,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(5),
//           child: Stack(
//             children: [
//               _buildVideoPlayer(controller, index),
//               if (!isSelected && _cameraStatus[index])
//                 Container(color: Colors.black.withOpacity(0.4)),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   width: double.infinity,
//                   color: Colors.black.withOpacity(0.6),
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Text(
//                     _cameraNames[index],
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGridCamera(int index) {
//     final controller = _controllers[index];

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _mainPlayerIndex = index;
//           _isGridView = false;
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: AppTheme.secondary.withOpacity(0.5),
//             width: 1,
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(7),
//           child: Stack(
//             children: [
//               _buildVideoPlayer(controller, index),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   width: double.infinity,
//                   color: Colors.black.withOpacity(0.7),
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: Text(
//                     _cameraNames[index],
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
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
