import 'dart:math';
import 'package:flutter/material.dart';

class ProEffect {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final double size;
  final Color color;
  final bool ring;

  ProEffect({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
    required this.color,
    this.ring = false,
  }) : maxLife = life;
}

class ProEffects {
  ProEffects._();

  static final Random random = Random();

  static void burst(
    List<ProEffect> effects, {
    required double x,
    required double y,
    required Color color,
    int count = 18,
    double power = 6,
  }) {
    for (int i = 0; i < count; i++) {
      final angle = random.nextDouble() * pi * 2;
      final speed = power * (0.35 + random.nextDouble());

      effects.add(
        ProEffect(
          x: x,
          y: y,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          life: 0.55 + random.nextDouble() * 0.45,
          size: 2 + random.nextDouble() * 4,
          color: color,
        ),
      );
    }

    effects.add(
      ProEffect(
        x: x,
        y: y,
        vx: 0,
        vy: 0,
        life: 0.35,
        size: 8,
        color: color,
        ring: true,
      ),
    );
  }

  static void update(List<ProEffect> effects) {
    for (int i = effects.length - 1; i >= 0; i--) {
      final e = effects[i];

      e.x += e.vx;
      e.y += e.vy;

      e.vx *= 0.985;
      e.vy *= 0.985;
      e.vy += 0.08;

      e.life -= 0.016;

      if (e.life <= 0) {
        effects.removeAt(i);
      }
    }
  }

  static void paint(Canvas canvas, List<ProEffect> effects) {
    for (final e in effects) {
      if (e.life <= 0) continue;

      final alpha = (e.life / e.maxLife).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = e.color.withValues(alpha: alpha)
        ..style = e.ring ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = e.ring ? 2.0 : 1.0
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          e.ring ? 8 : 4,
        );

      if (e.ring) {
        canvas.drawCircle(
          Offset(e.x, e.y),
          e.size * (1.0 + (1.0 - alpha) * 2.0),
          paint,
        );
      } else {
        canvas.drawCircle(
          Offset(e.x, e.y),
          e.size * alpha,
          paint,
        );
      }
    }
  }
}
