import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class CCTVMainScreen extends ConsumerStatefulWidget {
  const CCTVMainScreen({super.key});

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

  VlcPlayerController? _controller;
  int? _activeCameraIndex;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Start with the first camera in grid view (not playing yet)
  }

  Future<void> _initializePlayer(int index) async {
    // If there's an existing controller, dispose it first properly with safety checks
    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        await _controller!.stop();
      }
      await _controller!.dispose();
      _controller = null;
    }

    setState(() {
      _activeCameraIndex = index;
      _controller = VlcPlayerController.network(
        _videoUrls[index],
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(300), // Low latency as suggested
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true), // Stable for mobile networks
          ]),
        ),
      );
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      if (_controller!.value.isInitialized) {
        _controller!.stop();
      }
      _controller!.dispose();
    }
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
          style: const TextStyle(
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
              if (_controller != null) {
                if (_controller!.value.isInitialized) {
                  _controller!.stop();
                }
                _controller!.dispose();
                _controller = null;
              }
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
              icon: const Icon(
                Icons.grid_view_rounded,
                color: AppTheme.secondary,
                size: 26,
              ),
              onPressed: () {
                setState(() => _isGridView = true);
                if (_controller != null) {
                  if (_controller!.value.isInitialized) {
                    _controller!.stop();
                  }
                  _controller!.dispose();
                  _controller = null;
                }
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.green, radius: 4),
                SizedBox(width: 8),
                Text(
                  'AVAILABLE LIVE UNITS',
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Text(
                _cameraNames[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
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
    if (_controller == null) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VlcPlayer(
                    controller: _controller!,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.secondary,
                      ),
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
                      child: const Row(
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            color: Colors.white,
                            size: 10,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Switch Unit',
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _videoUrls.length,
            itemBuilder: (context, index) {
              final isSelected = index == _activeCameraIndex;
              return GestureDetector(
                onTap: () => _onCameraSelected(index),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
        const Spacer(),
      ],
    );
  }
}
