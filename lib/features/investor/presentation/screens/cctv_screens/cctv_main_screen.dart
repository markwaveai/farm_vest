import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:farm_vest/core/theme/app_theme.dart';
import 'package:farm_vest/core/localization/translation_helpers.dart';
class CCTVMainScreen extends ConsumerStatefulWidget {
  CCTVMainScreen({super.key});

  @override
  ConsumerState<CCTVMainScreen> createState() => _CCTVMainScreenState();
}

class _CCTVMainScreenState extends ConsumerState<CCTVMainScreen> {
  // Provided test URLs
  final List<String> _videoUrls = [
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', // Public Demo Feed
    'rtsp://admin:12345@192.168.1.100:554/Streaming/Channels/101', // Local Cam 1
    'rtsp://admin:12345@192.168.1.100:554/Streaming/Channels/102', // Local Cam 2
    'rtsp://admin:12345@192.168.1.100:554/Streaming/Channels/103', // Local Cam 3
    'rtsp://admin:12345@192.168.1.100:554/Streaming/Channels/104', // Local Cam 4
  ];

  final List<String> _cameraNames = [
    'Public Quality Test',
    'Main Entrance Cam',
    'Shed A View',
    'Shed B View',
    'Loading Dock Cam',
  ];

  VideoPlayerController? _controller;
  int? _activeCameraIndex;
  bool _isGridView = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Start with the first camera in grid view (not playing yet)
  }

  Future<void> _initializePlayer(int index) async {
    // If there's an existing controller, dispose it first properly with safety checks
    if (_controller != null) {
      final oldController = _controller!;
      _controller = null;
      _isInitialized = false;
      await oldController.dispose();
    }

    // Create new controller
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_videoUrls[index]),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    setState(() {
      _activeCameraIndex = index;
      _controller = controller;
    });

    try {
      await controller.initialize();
      await controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onCameraSelected(int index) {
    setState(() {
      _isGridView = false;
    });
    _initializePlayer(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          _isGridView
              ? 'Select Camera Unit'
              : _cameraNames[_activeCameraIndex ?? 0],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (!_isGridView) {
              setState(() => _isGridView = true);
              _controller?.pause();
              _controller?.dispose();
              _controller = null;
              _isInitialized = false;
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/customer-dashboard'); // Fallback if no history
              }
            }
          },
        ),
        actions: [
          if (!_isGridView)
            IconButton(
              icon: Icon(
                Icons.grid_view_rounded,
                color: AppTheme.secondary,
                size: 26,
              ),
              onPressed: () {
                setState(() => _isGridView = true);
                _controller?.pause();
                _controller?.dispose();
                _controller = null;
                _isInitialized = false;
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isGridView ? _buildGridView() : _buildFocusedView(),
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.green, radius: 4),
                SizedBox(width: 8),
                Text(
                  'AVAILABLE LIVE UNITS'.tr(ref),
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _videoUrls.length,
              itemBuilder: (context, index) => _buildCameraCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCard(int index) {
    return GestureDetector(
      onTap: () => _onCameraSelected(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppTheme.secondary.withOpacity(0.8),
                  size: 40,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Text(
                _cameraNames[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusedView() {
    if (_controller == null) return SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_isInitialized)
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.secondary,
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LIVE'.tr(ref),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Horizontal list of other cameras
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Switch Unit'.tr(ref),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: _videoUrls.length,
            itemBuilder: (context, index) {
              final isSelected = index == _activeCameraIndex;
              return GestureDetector(
                onTap: () => _onCameraSelected(index),
                child: Container(
                  width: 120,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.secondary : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.secondary : Colors.white10,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _cameraNames[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Spacer(),
      ],
    );
  }
}
