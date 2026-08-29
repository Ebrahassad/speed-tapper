import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../models/brick.dart';
import '../models/particle.dart';
import 'power_up_painter.dart';
import '../effects/pro_effects.dart';
import '../effects/ball_trail.dart';
import '../models/power_up.dart';

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
  final BallTrail ballTrail;

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
    required this.ballTrail,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintAtmosphere(canvas, size);
    _paintBricks(canvas);
    _paintBallTrail(canvas);
    _paintBall(canvas);
    _paintPaddle(canvas, size);
    PowerUpPainter.paint(canvas, powerUps);
    _paintParticles(canvas);
    ProEffects.paint(canvas, effects);
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final Paint background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF09051A),
          Color(0xFF050611),
          Color(0xFF02030A),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, background);
  }

  void _paintAtmosphere(Canvas canvas, Size size) {
    final Paint haze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.45),
        radius: 1.0,
        colors: [
          GameConstants.neonCyan.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, haze);

    final Paint pinkHaze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 0.2),
        radius: 0.9,
        colors: [
          GameConstants.neonPink.withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, pinkHaze);

    // Subtle futuristic grid.
    final Paint grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    const double spacing = 32;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        grid,
      );
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    // Horizon glow.
    final double horizon = size.height * 0.48;

    final Paint horizonGlow = Paint()
      ..color = GameConstants.neonCyan.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        horizon,
        size.width,
        2,
      ),
      horizonGlow,
    );
  }

  // ============================================================
  // BRICKS
  // ============================================================

  // ============================================================
  // BALL TRAIL
  // ============================================================

  void _paintBallTrail(Canvas canvas) {
    if (ballTrail.points.isEmpty) return;

    final Paint trailPaint = Paint()
      ..style = PaintingStyle.fill;

    for (final point in ballTrail.points) {
      if (point.alpha <= 0) continue;

      final double radius = ballRadius * point.scale;

      trailPaint.color = GameConstants.neonCyan.withValues(
        alpha: point.alpha * 0.35,
      );

      canvas.drawCircle(
        Offset(point.x, point.y),
        radius,
        trailPaint,
      );
    }
  }

  void _paintBricks(Canvas canvas) {
    for (final Brick brick in bricks) {
      final Rect rect = Rect.fromLTWH(
        brick.x,
        brick.y,
        brick.width,
        brick.height,
      );

      final RRect rounded = RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      );

      // Outer glow.
      final Paint glow = Paint()
        ..color = brick.color.withValues(
          alpha: GameConstants.brickGlowAlpha,
        )
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          GameConstants.brickGlowBlur,
        );

      canvas.drawRRect(rounded, glow);

      // Dark under-layer.
      final RRect shadowRect = RRect.fromRectAndRadius(
        rect.shift(const Offset(0, 2)),
        const Radius.circular(8),
      );

      canvas.drawRRect(
        shadowRect,
        Paint()..color = Colors.black.withValues(alpha: 0.55),
      );

      // Main gradient.
      final Paint body = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              Colors.white,
              brick.color,
              0.12,
            )!,
            brick.color,
            Color.lerp(
              Colors.black,
              brick.color,
              0.55,
            )!,
          ],
        ).createShader(rect);

      canvas.drawRRect(rounded, body);

      // Top highlight.
      final Paint highlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(
        rounded,
        highlight,
      );

      // HP indicator for strong bricks.
      if (brick.maxHp > 1 && !brick.isBoss) {
        final double ratio = (brick.hp / brick.maxHp).clamp(0.0, 1.0);

        final Paint hpBg = Paint()
          ..color = Colors.black.withValues(alpha: 0.35);

        final Paint hp = Paint()..color = Colors.white.withValues(alpha: 0.9);

        canvas.drawRect(
          Rect.fromLTWH(
            brick.x,
            brick.y + brick.height - 3,
            brick.width,
            3,
          ),
          hpBg,
        );

        canvas.drawRect(
          Rect.fromLTWH(
            brick.x,
            brick.y + brick.height - 3,
            brick.width * ratio,
            3,
          ),
          hp,
        );
      }

      if (brick.isBoss) {
        _paintBoss(canvas, brick);
      }
    }
  }

  void _paintBoss(Canvas canvas, Brick brick) {
    final double ratio = (brick.hp / brick.maxHp).clamp(0.0, 1.0);

    final Rect bar = Rect.fromLTWH(
      brick.x,
      brick.y - 12,
      brick.width,
      5,
    );

    final Paint bg = Paint()..color = Colors.white.withValues(alpha: 0.16);

    final Paint health = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF003C),
          Color(0xFFFF0055),
          Color(0xFFFFE600),
        ],
      ).createShader(bar);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bar,
        const Radius.circular(3),
      ),
      bg,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          brick.x,
          brick.y - 12,
          brick.width * ratio,
          5,
        ),
        const Radius.circular(3),
      ),
      health,
    );

    final Paint bossGlow = Paint()
      ..color = const Color(0xFFFF0055).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        7,
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          brick.x - 3,
          brick.y - 3,
          brick.width + 6,
          brick.height + 6,
        ),
        const Radius.circular(10),
      ),
      bossGlow,
    );
  }

  // ============================================================
  // BALL
  // ============================================================

  void _paintBall(Canvas canvas) {
    final Offset center = Offset(ballX, ballY);

    final Paint outerGlow = Paint()
      ..color = GameConstants.neonCyan.withValues(alpha: 0.55)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        GameConstants.ballGlowBlur,
      );

    canvas.drawCircle(
      center,
      ballRadius + 7,
      outerGlow,
    );

    final Paint glow = Paint()
      ..color = GameConstants.neonCyan.withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        7,
      );

    canvas.drawCircle(
      center,
      ballRadius + 3,
      glow,
    );

    final Paint ball = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.35),
        radius: 0.9,
        colors: [
          Colors.white,
          Color(0xFFE8FFFF),
          Color(0xFF5CFFFF),
          Color(0xFF00BFD6),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: ballRadius,
        ),
      );

    canvas.drawCircle(
      center,
      ballRadius,
      ball,
    );

    // Specular highlight.
    canvas.drawCircle(
      Offset(
        ballX - ballRadius * 0.28,
        ballY - ballRadius * 0.30,
      ),
      ballRadius * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  // ============================================================
  // PADDLE
  // ============================================================

  void _paintPaddle(
    Canvas canvas,
    Size size,
  ) {
    final double paddleY = size.height - GameConstants.paddleBottomOffset;

    final Rect rect = Rect.fromLTWH(
      paddleX,
      paddleY,
      paddleWidth,
      paddleHeight,
    );

    final RRect rounded = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12),
    );

    final Paint glow = Paint()
      ..color = GameConstants.neonCyan.withValues(alpha: 0.55)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        GameConstants.paddleGlowBlur,
      );

    canvas.drawRRect(
      rounded,
      glow,
    );

    final Paint body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFEFFFFF),
          Color(0xFF7AFFFF),
          Color(0xFF00E5FF),
          Color(0xFF008CA0),
        ],
      ).createShader(rect);

    canvas.drawRRect(
      rounded,
      body,
    );

    final Paint edge = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(
      rounded,
      edge,
    );

    // Center energy line.
    final Paint energy = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(
        paddleX + paddleWidth * 0.20,
        paddleY + paddleHeight * 0.35,
      ),
      Offset(
        paddleX + paddleWidth * 0.80,
        paddleY + paddleHeight * 0.35,
      ),
      energy,
    );
  }

  // ============================================================
  // PARTICLES
  // ============================================================

  void _paintParticles(Canvas canvas) {
    for (final Particle particle in particles) {
      if (particle.alpha <= 0) continue;

      final double alpha = particle.alpha.clamp(0.0, 1.0);

      final Paint glow = Paint()
        ..color = particle.color.withValues(
          alpha: alpha * 0.45,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          4,
        );

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size + 2,
        glow,
      );

      final Paint paint = Paint()
        ..color = particle.color.withValues(
          alpha: alpha,
        );

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant GamePainter oldDelegate,
  ) {
    return true;
  }
}
