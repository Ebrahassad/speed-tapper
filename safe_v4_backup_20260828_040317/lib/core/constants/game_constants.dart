import 'package:flutter/material.dart';

class GameConstants {
  GameConstants._();

  // ============================================================
  // APP
  // ============================================================

  static const String appName = 'Neon Breaker Pro';

  // ============================================================
  // GAME
  // ============================================================

  static const int startingLives = 3;
  static const int startingLevel = 1;
  static const int maximumLevel = 99;

  // ============================================================
  // BALL
  // ============================================================

  static const double ballRadius = 9.0;

  static const double baseBallHorizontalSpeed = 3.8;
  static const double baseBallVerticalSpeed = 4.8;
  static const double ballSpeedPerLevel = 0.16;

  static const double minimumBallHorizontalSpeed = 1.35;
  static const double maximumBallHorizontalSpeed = 7.5;
  static const double maximumBallVerticalSpeed = 9.0;

  static const double minBallSpeed = 4.6;
  static const double maxBallSpeed = 9.5;

  static const double paddleHitInfluence = 0.15;

  static const double paddleBounceMultiplier = 0.12;

  static const double minimumPaddleBounceAngle = 0.35;
  static const double maximumPaddleBounceAngle = 1.35;
  static const double paddleMinimumHitAngle = 0.18;

  static const double paddleCollisionEpsilon = 1.0;
  static const double brickCollisionEpsilon = 1.0;

  // ============================================================
  // PADDLE
  // ============================================================

  static const double defaultPaddleWidth = 108.0;
  static const double minimumPaddleWidth = 62.0;
  static const double paddleHeight = 15.0;

  static const double paddleBottomOffset = 82.0;
  static const double paddleWidthDecreasePerLevel = 3.0;

  // ============================================================
  // BRICKS
  // ============================================================

  static const int brickColumns = 5;
  static const double brickPadding = 8.0;
  static const double brickHeight = 24.0;
  static const double brickTop = 90.0;

  static const int maximumNormalRows = 6;

  static const int normalBrickHitScore = 10;
  static const int normalBrickDestroyScore = 50;
  static const int nextLevelBonus = 200;
  static const int lifeLostPenalty = 0;

  static const int levelUpParticles = 24;

  // ============================================================
  // BOSS
  // ============================================================

  static const int bossEveryLevels = 3;

  static const double bossWidth = 160.0;
  static const double bossHeight = 50.0;
  static const double bossY = 100.0;

  static const int bossBaseHealth = 15;
  static const int bossHealthPerLevel = 5;

  static const int bossDestroyBonus = 500;

  // ============================================================
  // COMBO
  // ============================================================

  static const int comboStart = 0;
  static const int comboMaxMultiplier = 8;
  static const int comboBonusPerHit = 7;
  static const int comboTimeoutFrames = 150;

  // ============================================================
  // PARTICLES
  // ============================================================

  static const double particleGravity = 0.055;

  static const int particlesPerHit = 16;
  static const double particleMaxSize = 5.5;
  static const double particleBaseSize = 2.5;
  static const double particleVelocityRange = 8.0;
  static const double particleFadeSpeed = 0.035;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundTop = Color(0xFF0A0A16);
  static const Color backgroundBottom = Color(0xFF05050D);

  static const Color panelColor = Color(0xCC0D0B1E);

  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPink = Color(0xFFFF007F);
  static const Color neonYellow = Color(0xFFFFE600);
  static const Color neonGreen = Color(0xFF00FF66);

  static const List<Color> brickColors = [
    neonPink,
    neonCyan,
    neonYellow,
    neonGreen,
  ];

  // ============================================================
  // GLOW
  // ============================================================

  static const double brickGlowAlpha = 0.55;
  static const double brickGlowBlur = 12.0;

  static const double ballGlowAlpha = 0.85;
  static const double ballGlowBlur = 18.0;

  static const double paddleGlowAlpha = 0.85;
  static const double paddleGlowBlur = 16.0;

  // ============================================================
  // UI
  // ============================================================

  static const double hudTop = 40.0;
  static const double hudHorizontalPadding = 18.0;
  static const double buttonRadius = 30.0;

  // ============================================================
  // PRO GAME FEEL
  // ============================================================

  static const double ballAcceleration = 0.0025;
  static const double ballMaxSpeedPro = 10.0;
  static const double ballMinVerticalRatio = 0.32;
  static const double ballMaxVerticalRatio = 0.92;

  static const double paddleInfluencePro = 0.34;
  static const double paddleEdgeBoost = 0.16;

  static const double screenShakeSmall = 2.0;
  static const double screenShakeMedium = 5.0;
  static const double screenShakeBoss = 8.0;

  static const int comboMax = 8;
  static const int comboThreshold = 3;

  static const double bossMoveSpeed = 1.25;
  static const double bossMoveAmplitude = 55.0;

  static const double particlePhysicsGravity = 0.07;

  static const int particlesNormalHit = 14;
  static const int particlesDestroy = 28;
  static const int particlesBoss = 42;

  static const int bossPhaseOne = 70;
  static const int bossPhaseTwo = 40;
  static const int bossPhaseThree = 15;

  static const double safeFrameDelta = 0.016;
}
