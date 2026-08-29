import 'dart:math';

import 'package:flutter/material.dart';

class NeonBackgroundPainter extends CustomPainter {
  final double time;

  NeonBackgroundPainter({
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A0718),
          Color(0xFF05050D),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, background);

    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(
        alpha: 0.045,
      )
      ..strokeWidth = 1;

    const spacing = 42.0;

    final offset = (time * 18) % spacing;

    for (double y = offset; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    final glow = Paint()
      ..color = const Color(0xFF00E5FF).withValues(
        alpha: 0.05,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        45,
      );

    canvas.drawCircle(
      Offset(
        size.width * 0.5,
        size.height * 0.25 + sin(time * 0.8) * 30,
      ),
      size.width * 0.32,
      glow,
    );
  }

  @override
  bool shouldRepaint(
    covariant NeonBackgroundPainter oldDelegate,
  ) {
    return oldDelegate.time != time;
  }
}
