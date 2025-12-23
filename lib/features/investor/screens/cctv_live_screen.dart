import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_theme.dart';

class CCTVLiveScreen extends StatefulWidget {
  const CCTVLiveScreen({super.key});

  @override
  State<CCTVLiveScreen> createState() => _CCTVLiveScreenState();
}

class _CCTVLiveScreenState extends State<CCTVLiveScreen> {
  final List<String> _videoUrls = [
    'http://161.97.182.208:8888/stream1/index.m3u8',
    'http://161.97.182.208:8888/stream2/index.m3u8',
    'http://161.97.182.208:8888/stream3/index.m3u8',
    'http://161.97.182.208:8888/stream4/index.m3u8',
  ];

  late List<VideoPlayerController> _controllers;
  int _mainPlayerIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controllers = _videoUrls
        .map((url) => VideoPlayerController.networkUrl(Uri.parse(url)))
        .toList();

    Future.wait(_controllers.map((controller) => controller.initialize())).then(
      (_) {
        for (var controller in _controllers) {
          controller.play();
          controller.setLooping(true);
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
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
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Camera ${_mainPlayerIndex + 1}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildVideoPlayer(_controllers[_mainPlayerIndex]),
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
              ),
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

  Widget _buildVideoPlayer(VideoPlayerController controller) {
    return AspectRatio(aspectRatio: 16 / 9, child: VideoPlayer(controller));
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
              _buildVideoPlayer(controller),
              if (!isSelected) Container(color: Colors.black.withOpacity(0.4)),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Camera ${index + 1}',
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
}
