import 'package:flutter/material.dart';
import '../models/power_up.dart';
import 'power_up_painter.dart';
import '../effects/ball_trail.dart';
import '../effects/pro_effects.dart';

import '../../../core/constants/game_constants.dart';
import '../models/brick.dart';
import '../models/particle.dart';

class GamePainter extends CustomPainter {
  final double paddleX;
  final double paddleWidth;
  final double paddleHeight;

  final double ballX;
  final double ballY;
  final double ballRadius;

  final List<Brick> bricks;
  final List<Particle> particles;
  final List<PowerUp> powerUps;
  final List<ProEffect> effects;

  GamePainter({
    required this.paddleX,
    required this.paddleWidth,
    required this.paddleHeight,
    required this.ballX,
    required this.ballY,
    required this.ballRadius,
    required this.bricks,
    required this.particles,
    required this.powerUps,
    required this.effects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintBricks(canvas);
    _paintBall(canvas);
    _paintPaddle(canvas, size);
    _paintParticles(canvas);
    PowerUpPainter.paint(canvas, powerUps);
    _paintProEffects(canvas);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final Paint background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          GameConstants.backgroundTop,
          GameConstants.backgroundBottom,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      background,
    );
  }

  void _paintBricks(Canvas canvas) {
    for (final Brick brick in bricks) {
      final RRect rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          brick.x,
          brick.y,
          brick.width,
          brick.height,
        ),
        const Radius.circular(7),
      );

      final Paint glow = Paint()
        ..color = brick.color.withValues(
          alpha: GameConstants.brickGlowAlpha,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          GameConstants.brickGlowBlur,
        );

      canvas.drawRRect(rect, glow);

      final Paint paint = Paint()..color = brick.color;

      canvas.drawRRect(rect, paint);

      if (brick.isBoss) {
        _paintBossHealth(canvas, brick);

        final pulse = 0.5 +
            0.5 *
                sin(
                  DateTime.now().millisecondsSinceEpoch * 0.006,
                );

        final bossGlow = Paint()
          ..color = brick.color.withValues(
            alpha: 0.18 + pulse * 0.16,
          )
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            18 + pulse * 8,
          );

        canvas.drawRRect(
          rect,
          bossGlow,
        );

        final core = Paint()
          ..color = Colors.white.withValues(
            alpha: 0.12 + pulse * 0.10,
          );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              brick.x + 3,
              brick.y + 3,
              brick.width > 6 ? brick.width - 6 : 0,
              brick.height > 6 ? brick.height - 6 : 0,
            ),
            const Radius.circular(5),
          ),
          core,
        );
      }
    }
  }

  void _paintBossHealth(Canvas canvas, Brick brick) {
    final double ratio = (brick.hp / brick.maxHp).clamp(0.0, 1.0);

    final Paint background = Paint()
      ..color = Colors.white.withValues(alpha: 0.18);

    final Paint health = Paint()..color = Colors.white;

    final Rect bar = Rect.fromLTWH(
      brick.x,
      brick.y - 9,
      brick.width,
      4,
    );

    canvas.drawRect(bar, background);

    canvas.drawRect(
      Rect.fromLTWH(
        brick.x,
        brick.y - 9,
        brick.width * ratio,
        4,
      ),
      health,
    );
  }

  void _paintBall(Canvas canvas) {
    final Paint glow = Paint()
      ..color = GameConstants.neonCyan.withValues(
        alpha: GameConstants.ballGlowAlpha,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        GameConstants.ballGlowBlur,
      );

    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius + 3,
      glow,
    );

    final Paint ball = Paint()
      ..shader = const RadialGradient(
        colors: [
          Colors.white,
          Color(0xFFE8FFFF),
          GameConstants.neonCyan,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(ballX, ballY),
          radius: ballRadius,
        ),
      );

    canvas.drawCircle(
      Offset(ballX, ballY),
      ballRadius,
      ball,
    );
  }

  void _paintPaddle(Canvas canvas, Size size) {
    final double paddleY = size.height - GameConstants.paddleBottomOffset;

    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        paddleX,
        paddleY,
        paddleWidth,
        paddleHeight,
      ),
      const Radius.circular(12),
    );

    final Paint glow = Paint()
      ..color = GameConstants.neonCyan.withValues(
        alpha: GameConstants.paddleGlowAlpha,
      )
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        GameConstants.paddleGlowBlur,
      );

    canvas.drawRRect(rect, glow);

    final Paint paddle = Paint()
      ..shader = const LinearGradient(
        colors: [
          GameConstants.neonCyan,
          Color(0xFF8AFFFF),
          GameConstants.neonCyan,
        ],
      ).createShader(
        Rect.fromLTWH(
          paddleX,
          paddleY,
          paddleWidth,
          paddleHeight,
        ),
      );

    canvas.drawRRect(rect, paddle);
  }

  void _paintParticles(Canvas canvas) {
    for (final Particle particle in particles) {
      if (particle.alpha <= 0) continue;

      final Paint paint = Paint()
        ..color = particle.color.withValues(
          alpha: particle.alpha.clamp(0.0, 1.0),
        );

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  void _paintProEffects(Canvas canvas) {
    ProEffects.paint(canvas, effects);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}
