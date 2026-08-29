import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;

  double dx;
  double dy;

  double size;
  double alpha;
  double rotation = 0;
  double rotationSpeed = 0;

  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
    this.alpha = 1.0,
  });
}
