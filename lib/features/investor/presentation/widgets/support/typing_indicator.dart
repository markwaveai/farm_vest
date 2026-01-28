import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final String? avatarUrl; // optional profile image
  final double avatarSize;

  const TypingIndicator({super.key, this.avatarUrl, this.avatarSize = 28});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
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

  Widget _dot(int index) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: CircleAvatar(radius: 3, backgroundColor: Colors.deepPurple),
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: widget.avatarSize / 2,
        backgroundImage: NetworkImage(widget.avatarUrl!),
        backgroundColor: Colors.grey.shade200,
      );
    }

    // Fallback avatar
    return CircleAvatar(
      radius: widget.avatarSize / 2,
      backgroundColor: Colors.deepPurple.withOpacity(0.1),
      child: const Icon(
        Icons.support_agent_sharp,
        color: Colors.deepPurple,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(),
        const SizedBox(width: 8),
        Row(children: [_dot(0), _dot(1), _dot(2)]),
      ],
    );
  }
}
