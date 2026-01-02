import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:farm_vest/core/theme/app_theme.dart';

class CCTVMainScreen extends StatefulWidget {
  const CCTVMainScreen({super.key});

  @override
  State<CCTVMainScreen> createState() => _CCTVMainScreenState();
}

class _CCTVMainScreenState extends State<CCTVMainScreen> {
  final List<String> _videoUrls = [
    'http://161.97.182.208:8888/stream1/index.m3u8',
    'http://161.97.182.208:8888/stream2/index.m3u8',
    'http://161.97.182.208:8888/stream3/index.m3u8',
    'http://161.97.182.208:8888/stream4/index.m3u8',
  ];

  final List<String> _cameraNames = [
    'Main Entrance',
    'Feeding Area',
    'Rest Area',
    'Water Station',
  ];

  late List<VideoPlayerController?> _controllers;
  int _mainPlayerIndex = 0;
  bool _isLoading = true;
  bool _isGridView = true;
  List<bool> _cameraStatus = []; // Track individual camera status
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _cameraStatus = List.generate(_videoUrls.length, (index) => false);

    print('=== CCTV Screen Initialization (Video Player) ===');
    print('Total cameras: ${_videoUrls.length}');

    _controllers = _videoUrls
        .map((url) => VideoPlayerController.network(url))
        .toList();

    // Initialize video controllers
    _initializeVideoControllers();
  }

  void _initializeVideoControllers() {
    print('Initializing video controllers...');

    for (int i = 0; i < _controllers.length; i++) {
      final controller = _controllers[i];
      if (controller == null) {
        print('Controller $i is null, skipping initialization');
        setState(() {
          _cameraStatus[i] = false;
        });
        continue;
      }

      print(
        'Setting up video camera $i (${_cameraNames[i]}): ${_videoUrls[i]}',
      );

      controller.addListener(() {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          print('Video Camera $i (${_cameraNames[i]}) is playing');
          setState(() {
            _cameraStatus[i] = true;
          });
        }
      });

      controller
          .initialize()
          .then((_) {
            print(
              'Video Camera $i (${_cameraNames[i]}) initialized successfully',
            );

            // Start playing immediately and also set up periodic restart for HLS
            controller.play();
            controller.setLooping(true);
            print(
              'Video Camera $i (${_cameraNames[i]}) play() called immediately',
            );

            // Set up periodic check to ensure video keeps playing (important for HLS)
            final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
              if (!mounted) {
                timer.cancel();
                return;
              }

              if (controller.value.isInitialized &&
                  !controller.value.isPlaying) {
                print(
                  'Video Camera $i (${_cameraNames[i]}) stopped playing, restarting...',
                );
                controller.play();
              }
            });
            _timers.add(timer);

            // Check if all cameras are done loading
            if (_cameraStatus.every((status) => status || !status)) {
              setState(() {
                _isLoading = false;
              });
              print('=== Video Initialization Complete ===');
            }
          })
          .catchError((error) {
            print(
              'Error initializing video camera $i (${_cameraNames[i]}): $error',
            );
            setState(() {
              _cameraStatus[i] = false;
            });

            // Check if all cameras are done loading (including failed ones)
            if (_cameraStatus.every(
              (status) => status == true || status == false,
            )) {
              setState(() {
                _isLoading = false;
              });
              print('Video initialization completed with some failures');
            }
          });
    }
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer.cancel();
    }
    for (var controller in _controllers) {
      if (controller != null) {
        try {
          controller.dispose();
        } catch (e) {
          print('Error disposing VLC controller: $e');
        }
      }
    }
    super.dispose();
  }

  void _onThumbnailTapped(int index) {
    setState(() {
      _mainPlayerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _isGridView ? 'All Cameras' : _cameraNames[_mainPlayerIndex],
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.video_call : Icons.grid_view,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _isGridView
            ? _buildGridView()
            : _buildMainView(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.white),
          SizedBox(height: 16),
          Text(
            'Loading Camera Feeds...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildVideoPlayer(
            _controllers[_mainPlayerIndex]!,
            _mainPlayerIndex,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _controllers.length,
            itemBuilder: (context, index) {
              return _buildThumbnail(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 16 / 9,
        ),
        itemCount: _controllers.length,
        itemBuilder: (context, index) {
          return _buildGridCamera(index);
        },
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController? controller, int cameraIndex) {
    print(
      'Building video player for camera $cameraIndex, status: ${_cameraStatus[cameraIndex]}',
    );

    if (!_cameraStatus[cameraIndex] || controller == null) {
      print(
        'Camera $cameraIndex is offline or controller is null, showing placeholder',
      );
      return Container(
        color: Colors.grey[800],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, color: Colors.red[400], size: 32),
              const SizedBox(height: 8),
              Text(
                'Camera Offline',
                style: TextStyle(color: Colors.red[400], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _cameraNames[cameraIndex],
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      print('Camera $cameraIndex video controller not initialized');
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
              SizedBox(height: 8),
              Text(
                'Connecting...',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    print('Camera $cameraIndex video is ready, showing video');
    print('Video is playing: ${controller.value.isPlaying}');
    print('Video size: ${controller.value.size}');

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio > 0
          ? controller.value.aspectRatio
          : 16 / 9,
      child: VideoPlayer(controller),
    );
  }

  Widget _buildThumbnail(int index) {
    final controller = _controllers[index];
    final isSelected = index == _mainPlayerIndex;

    return GestureDetector(
      onTap: () => _onThumbnailTapped(index),
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.secondary : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        width: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              _buildVideoPlayer(controller, index),
              if (!isSelected && _cameraStatus[index])
                Container(color: Colors.black.withOpacity(0.4)),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _cameraNames[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCamera(int index) {
    final controller = _controllers[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _mainPlayerIndex = index;
          _isGridView = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.secondary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            children: [
              _buildVideoPlayer(controller, index),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    _cameraNames[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
