import 'package:flutter/material.dart';
import 'dart:math';

class RotatingSignal extends StatefulWidget {
  final double size;
  final bool animate;
  final Color color;

  const RotatingSignal({
    this.size = 50,
    this.animate = true,
    this.color = Colors.orange,
    super.key,
  });

  @override
  _RotatingSignalState createState() => _RotatingSignalState();
}

class _RotatingSignalState extends State<RotatingSignal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant RotatingSignal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RotatingSignalPainter(_controller.value, widget.color),
        );
      },
    );
  }
}

class _RotatingSignalPainter extends CustomPainter {
  final double progress; // 0.0 bis 1.0
  final Color color;

  _RotatingSignalPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const segments = 16; // Anzahl der Segmente
    const sweep = 2 * pi / segments;

    for (int i = 0; i < segments; i++) {
      double angle = i * sweep - pi / 2;
      double fade = ((i / segments - progress) % 1.0).clamp(0.0, 1.0);
      paint.color = color.withOpacity(fade); // <- hier wird die übergebene Farbe verwendet
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        sweep * 0.8, // Abstand zwischen Segmenten
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RotatingSignalPainter oldDelegate) => true;
}
