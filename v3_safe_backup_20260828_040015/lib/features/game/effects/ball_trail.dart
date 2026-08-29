import 'package:flutter/material.dart';

class BallTrailPoint {
  double x;
  double y;
  double alpha;

  BallTrailPoint({
    required this.x,
    required this.y,
    this.alpha = 1,
  });
}

class BallTrail {
  final List<BallTrailPoint> points = [];

  final int maximumPoints;

  BallTrail({
    this.maximumPoints = 14,
  });

  void add(double x, double y) {
    points.insert(
      0,
      BallTrailPoint(
        x: x,
        y: y,
      ),
    );

    if (points.length > maximumPoints) {
      points.removeLast();
    }
  }

  void update() {
    for (final point in points) {
      point.alpha *= 0.84;
    }

    points.removeWhere(
      (point) => point.alpha < 0.03,
    );
  }

  void clear() {
    points.clear();
  }

  void paint(
    Canvas canvas,
    Color color,
    double radius,
  ) {
    for (int i = points.length - 1; i >= 0; i--) {
      final point = points[i];

      final factor = (1 - i / maximumPoints).clamp(0.05, 1.0);

      final paint = Paint()
        ..color = color.withValues(
          alpha: point.alpha * factor * 0.42,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          5,
        );

      canvas.drawCircle(
        Offset(point.x, point.y),
        radius * factor,
        paint,
      );
    }
  }
}
