import 'package:flutter/material.dart';

class LoadingDotsWave extends StatefulWidget {
  final Color color;
  final double size;

  const LoadingDotsWave({
    super.key,
    this.color = Colors.white,
    this.size = 8.0,
  });

  @override
  State<LoadingDotsWave> createState() => _LoadingDotsWaveState();
}

class _LoadingDotsWaveState extends State<LoadingDotsWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Let's stick to a simpler logic that is guaranteed to work without math imports or complex logic issues
  Widget _buildSimpleDot(int index) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildSimpleDot(0), _buildSimpleDot(1), _buildSimpleDot(2)],
    );
  }
}
