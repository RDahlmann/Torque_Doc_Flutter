import 'package:flutter/material.dart';
import 'package:torquedoc/styles/app_colors.dart';

class FadingCircle extends StatefulWidget {
  final double size;
  const FadingCircle({this.size = 50, super.key});

  @override
  _FadingCircleState createState() => _FadingCircleState();
}

class _FadingCircleState extends State<FadingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Dauer für einen Farbwechsel
    )..repeat(reverse: true); // wiederholt hin und her

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: AppColors.darkblue,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _colorAnimation.value,
          ),
        );
      },
    );
  }
}
