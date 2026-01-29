import 'package:flutter/material.dart';

class ChatFancyLoader extends StatefulWidget {
  final Color color;
  const ChatFancyLoader({super.key, required this.color});

  @override
  State<ChatFancyLoader> createState() => _ChatFancyLoaderState();
}

class _ChatFancyLoaderState extends State<ChatFancyLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(3, (index) {
          final delay = index * 0.2;
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final value =
                  (_controller.value + delay) % 1.0;
              final scale = 0.5 + (value * 0.5);
              final opacity = 1.0 - value;
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
