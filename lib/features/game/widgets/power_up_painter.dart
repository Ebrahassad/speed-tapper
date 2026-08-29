import 'package:flutter/material.dart';

import '../models/power_up.dart';

class PowerUpPainter {
  PowerUpPainter._();

  static void paint(
    Canvas canvas,
    List<PowerUp> powerUps,
  ) {
    for (final power in powerUps) {
      final center = Offset(
        power.x,
        power.y,
      );

      final glow = Paint()
        ..color = power.color.withValues(
          alpha: 0.45,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12,
        );

      canvas.drawCircle(
        center,
        power.size * 0.75,
        glow,
      );

      final body = Paint()..color = power.color;

      canvas.drawCircle(
        center,
        power.size * 0.55,
        body,
      );

      final text = TextPainter(
        text: TextSpan(
          text: power.label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      text.paint(
        canvas,
        Offset(
          power.x - text.width / 2,
          power.y - text.height / 2,
        ),
      );
    }
  }
}
