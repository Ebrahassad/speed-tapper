import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'features/game/widgets/power_up_painter.dart';
import 'features/game/effects/screen_effect_controller.dart';
import 'features/game/effects/ball_trail.dart';
import 'features/game/engine/combo_engine.dart';
import 'features/game/engine/power_up_engine.dart';
import 'features/game/models/power_up.dart';
import 'features/game/effects/pro_effects.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/ads/ads_manager.dart';
import 'features/game/models/brick.dart';
import 'features/game/models/particle.dart';
import 'core/audio/audio_manager.dart';
import 'core/settings/game_settings.dart';
import 'features/game/screens/settings_screen.dart';
import 'features/game/widgets/start_menu.dart';

import 'features/game/painters/game_painter.dart';
import 'core/constants/game_constants.dart';

Future<File> _crashLogFile() async {
  final dir = Directory('/data/data/com.ebrahassadi.neonbreaker/files');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return File('${dir.path}/crash.log');
}

Future<void> _writeCrash(Object error, StackTrace stack) async {
  try {
    final file = await _crashLogFile();
    await file.writeAsString(
      '\n\n========== CRASH ==========\n'
      'Time: ${DateTime.now().toIso8601String()}\n'
      'Error: $error\n'
      'StackTrace:\n$stack\n'
      '===========================\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {}
}

void main() {
  runZonedGuarded<void>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      _writeCrash(details.exceptionAsString(), details.stack ?? StackTrace.current);
      FlutterError.presentError(details);
    };

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    runApp(const NeonBreakerApp());
  }, (error, stack) {
    _writeCrash(error, stack);
  });
}

class NeonBreakerApp extends StatelessWidget {
  const NeonBreakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GameConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameConstants.backgroundBottom,
        colorScheme: const ColorScheme.dark(
          primary: GameConstants.neonCyan,
          secondary: GameConstants.neonPink,
          surface: GameConstants.panelColor,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSettings gameSettings;
  late AudioManager audioManager;
  bool settingsLoaded = false;
  bool isNewHighScore = false;

  // ============================================================
  // GAME STATE
  // ============================================================

  bool isPlaying = false;
  bool isPaused = false;
  bool isGameOver = false;
  bool _ballWasLost = false;

  // ============================================================
  // COMBO STATE
  // ============================================================

  int combo = GameConstants.comboStart;
  int comboMultiplier = 1;
  int comboTimer = 0;

  int score = 0;
  int highScore = 0;
  int lives = GameConstants.startingLives;
  int level = GameConstants.startingLevel;

  double canvasWidth = 360;
  double canvasHeight = 640;

  double paddleWidth = 100;
  double paddleHeight = GameConstants.paddleHeight;
  double paddleX = 130;

  double ballX = 180;
  double ballY = 500;
  double ballRadius = 8;

  double ballDx = 3.5;
  double ballDy = -4.5;

  final List<Brick> bricks = [];
  final List<Particle> particles = [];
  final List<PowerUp> powerUps = [];

  final ComboEngine proCombo = ComboEngine();

  final BallTrail ballTrail = BallTrail();

  final ScreenEffectController screenEffects = ScreenEffectController();

  double proTime = 0;

  int bestCombo = 0;

  bool countdownActive = false;
  int countdownValue = 0;

  bool fireBallActive = false;
  bool magnetActive = false;

  double originalPaddleWidth = 0;
  double powerUpTimer = 0;

  final List<ProEffect> proEffects = [];

  double screenShake = 0;
  double comboFlash = 0;
  double comboScale = 1.0;
  double bossPulse = 0;
  double gameTime = 0;

  Timer? gameTimer;

  @override
  void initState() {
    super.initState();

    _loadHighScore();
    _loadSettings();
    try {
      AdsManager.initialize();
    } catch (e, st) {
      _writeCrash('AdsManager.initialize failed: $e', st);
    }
  }

  Future<void> _loadSettings() async {
    try {
      final loaded = await GameSettings.load();
      if (!mounted) return;
      setState(() {
        gameSettings = loaded;
        audioManager = AudioManager(loaded);
        settingsLoaded = true;
      });
    } catch (e, st) {
      _writeCrash('GameSettings.load failed: $e', st);
      if (!mounted) return;
      setState(() {
        gameSettings = GameSettings();
        audioManager = AudioManager(gameSettings);
        settingsLoaded = true;
      });
    }
  }

  // ============================================================
  // ADS
  // ============================================================

  void _showInterstitial() {
    AdsManager.showInterstitial();
  }

  void _showRewardedAd() {
    AdsManager.showRewarded(
      onReward: () {
        if (!mounted) return;

        setState(() {
          lives++;
          isGameOver = false;
          isPlaying = true;
        });

        _resetBall();
        _startGameTimer();
      },
      onUnavailable: () {
        if (mounted) {
          _showMessage('الإعلان غير متاح حالياً');
        }
      },
    );
  }

  Future<void> _openSettings() async {
    if (!settingsLoaded || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          settings: gameSettings,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      highScore = gameSettings.highScore;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // HIGH SCORE
  // ============================================================

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      highScore = prefs.getInt('neon_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (score <= highScore) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'neon_high_score',
      score,
    );

    if (!mounted) return;

    setState(() {
      highScore = score;
    });
  }

  // ============================================================
  // LEVEL
  // ============================================================

  void _initializeLevel() {
    bricks.clear();
    particles.clear();
    proEffects.clear();
    screenShake = 0;
    comboFlash = 0;
    comboScale = 1.0;

    paddleWidth = max(
      GameConstants.minimumPaddleWidth,
      GameConstants.defaultPaddleWidth -
          (level * GameConstants.paddleWidthDecreasePerLevel),
    );

    paddleX = (canvasWidth - paddleWidth) / 2;

    _resetBall();

    final bool bossLevel = level % GameConstants.bossEveryLevels == 0;

    if (bossLevel) {
      final int hp = GameConstants.bossBaseHealth +
          (level * GameConstants.bossHealthPerLevel);

      bricks.add(
        Brick(
          x: canvasWidth / 2 - GameConstants.bossWidth / 2,
          y: GameConstants.bossY,
          width: GameConstants.bossWidth,
          height: GameConstants.bossHeight,
          color: const Color(0xFFFF0055),
          hp: hp,
          maxHp: hp,
          isBoss: true,
        ),
      );

      return;
    }

    final int rows = min(
      GameConstants.maximumNormalRows,
      3 + level,
    );

    const int cols = GameConstants.brickColumns;

    const double padding = GameConstants.brickPadding;

    final double brickWidth = (canvasWidth - (padding * (cols + 1))) / cols;

    const double brickHeight = GameConstants.brickHeight;

    const List<Color> neonColors = [
      Color(0xFFFF007F),
      Color(0xFF00E5FF),
      Color(0xFFFFE600),
      Color(0xFF00FF66),
    ];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final int hp = row == 0 && level > 2 ? 2 : 1;

        bricks.add(
          Brick(
            x: padding + col * (brickWidth + padding),
            y: GameConstants.brickTop + row * (brickHeight + padding),
            width: brickWidth,
            height: brickHeight,
            color: neonColors[row % neonColors.length],
            hp: hp,
            maxHp: hp,
          ),
        );
      }
    }
  }

  // ============================================================
  // GAME CONTROL
  // ============================================================

  void startGame() {
    gameTimer?.cancel();

    setState(() {
      score = 0;
      lives = GameConstants.startingLives;
      level = GameConstants.startingLevel;

      isNewHighScore = false;
      isGameOver = false;
      isPaused = false;
      isPlaying = true;
    });

    proCombo.reset();
    powerUps.clear();
    ballTrail.clear();
    screenEffects.shake = 0;
    screenEffects.flash = 0;

    originalPaddleWidth = GameConstants.defaultPaddleWidth;

    _initializeLevel();
    _startGameTimer();
  }

  void _togglePause() {
    if (!isPlaying || isGameOver) return;

    audioManager.tap();

    setState(() {
      isPaused = !isPaused;
    });
  }

  void _startGameTimer() {
    gameTimer?.cancel();

    gameTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) {
        if (isPlaying && !isPaused) {
          _updateGame();
        }
      },
    );
  }

  void _resetBall() {
    ballX = canvasWidth / 2;
    ballY = canvasHeight - GameConstants.paddleBottomOffset - 40;

    final double levelSpeed = GameConstants.baseBallHorizontalSpeed +
        level * GameConstants.ballSpeedPerLevel;

    final double horizontal =
        max(GameConstants.minBallSpeed * 0.65, levelSpeed);

    final double vertical = max(GameConstants.minBallSpeed, levelSpeed);

    ballDx = (Random().nextBool() ? 1.0 : -1.0) * horizontal;

    ballDy = -vertical;

    _ballWasLost = false;
  }

  void _updateGame() {
    proTime += 0.016;

    screenEffects.update();

    // V3: animate boss safely during gameplay.
    _updateBoss();

    PowerUpEngine.update(
      powerUps,
      canvasHeight,
    );

    ballTrail.add(
      ballX,
      ballY,
    );

    ballTrail.update();

    proCombo.update();

    // V3: update professional visual effects every frame.
    ProEffects.update(proEffects);

    if (powerUpTimer > 0) {
      powerUpTimer -= 0.016;

      if (powerUpTimer <= 0) {
        paddleWidth = originalPaddleWidth;

        fireBallActive = false;
        magnetActive = false;
      }
    }

    if (!mounted) return;

    setState(() {
      final double previousBallY = ballY;

      ballX += ballDx;
      ballY += ballDy;

      // --------------------------------------------------------
      // WALLS
      // --------------------------------------------------------

      if (ballX - ballRadius <= 0) {
        ballX = ballRadius;
        ballDx = ballDx.abs();
      } else if (ballX + ballRadius >= canvasWidth) {
        ballX = canvasWidth - ballRadius;
        ballDx = -ballDx.abs();
      }

      if (ballY - ballRadius <= 0) {
        ballY = ballRadius;
        ballDy = ballDy.abs();
      }

      // --------------------------------------------------------
      // PADDLE
      // --------------------------------------------------------

      final double paddleY = canvasHeight - GameConstants.paddleBottomOffset;

      final bool paddleCollision = ballDy > 0 &&
          ballY + ballRadius >= paddleY &&
          previousBallY - ballRadius <= paddleY + paddleHeight &&
          ballX >= paddleX &&
          ballX <= paddleX + paddleWidth;

      if (paddleCollision) {
        ballY = paddleY - ballRadius - GameConstants.paddleCollisionEpsilon;

        final double paddleCenter = paddleX + paddleWidth / 2;

        final double relativeHit =
            ((ballX - paddleCenter) / (paddleWidth / 2)).clamp(-1.0, 1.0);

        final double currentSpeed = sqrt(ballDx * ballDx + ballDy * ballDy);

        double newDx =
            relativeHit * currentSpeed * GameConstants.paddleHitInfluence * 3.0;

        if (newDx.abs() < GameConstants.minimumBallHorizontalSpeed) {
          newDx = relativeHit >= 0
              ? GameConstants.minimumBallHorizontalSpeed
              : -GameConstants.minimumBallHorizontalSpeed;
        }

        newDx = newDx.clamp(
          -GameConstants.maximumBallHorizontalSpeed,
          GameConstants.maximumBallHorizontalSpeed,
        );

        final double remaining =
            max(0.1, currentSpeed * currentSpeed - newDx * newDx);

        ballDx = newDx;
        ballDy = -sqrt(remaining);

        final double totalSpeed = sqrt(
          ballDx * ballDx + ballDy * ballDy,
        );

        final double minimumVertical = totalSpeed * 0.32;

        if (ballDy.abs() < minimumVertical) {
          ballDy = -minimumVertical;

          final double horizontalSquared = max(
            0.5,
            totalSpeed * totalSpeed - ballDy * ballDy,
          );

          ballDx = (ballDx >= 0 ? 1 : -1) * sqrt(horizontalSquared);
        }

        audioManager.tap();

        if (gameSettings.vibrationEnabled) {
          audioManager.vibrate();
        }
      }

      // --------------------------------------------------------
      // LOST BALL
      // --------------------------------------------------------

      if (ballY - ballRadius > canvasHeight) {
        if (!_ballWasLost) {
          _ballWasLost = true;

          lives--;
          combo = GameConstants.comboStart;
          comboMultiplier = 1;
          comboTimer = 0;

          audioManager.strongVibration();

          if (lives <= 0) {
            _gameOver();
            return;
          }

          _resetBall();
        }
      }

      // --------------------------------------------------------
      // BRICK COLLISION
      // --------------------------------------------------------

      for (int i = bricks.length - 1; i >= 0; i--) {
        final Brick brick = bricks[i];

        final double left = brick.x - ballRadius;
        final double right = brick.x + brick.width + ballRadius;
        final double top = brick.y - ballRadius;
        final double bottom = brick.y + brick.height + ballRadius;

        final bool collision =
            ballX >= left && ballX <= right && ballY >= top && ballY <= bottom;

        if (!collision) continue;

        final double brickCenterX = brick.x + brick.width / 2;
        final double brickCenterY = brick.y + brick.height / 2;

        final double dx = ballX - brickCenterX;
        final double dy = ballY - brickCenterY;

        final double overlapX = (brick.width / 2 + ballRadius) - dx.abs();

        final double overlapY = (brick.height / 2 + ballRadius) - dy.abs();

        if (overlapX < overlapY) {
          ballDx = dx >= 0 ? ballDx.abs() : -ballDx.abs();

          ballX += dx >= 0
              ? overlapX + GameConstants.brickCollisionEpsilon
              : -(overlapX + GameConstants.brickCollisionEpsilon);
        } else {
          ballDy = dy >= 0 ? ballDy.abs() : -ballDy.abs();

          ballY += dy >= 0
              ? overlapY + GameConstants.brickCollisionEpsilon
              : -(overlapY + GameConstants.brickCollisionEpsilon);
        }

        brick.hp--;

        screenEffects.hit(
          amount: brick.isBoss ? 4.0 : 1.5,
        );

        combo++;
        proCombo.hit();
        bestCombo = proCombo.combo > bestCombo ? proCombo.combo : bestCombo;
        comboTimer = GameConstants.comboTimeoutFrames;
        comboMultiplier = min(
          GameConstants.comboMaxMultiplier,
          1 + combo ~/ 3,
        );

        final int comboBonus = comboMultiplier * GameConstants.comboBonusPerHit;

        score += GameConstants.normalBrickHitScore + comboBonus;

        _spawnParticles(
          brick.x + brick.width / 2,
          brick.y + brick.height / 2,
          brick.color,
        );

        audioManager.brickHit();

        if (gameSettings.vibrationEnabled) {
          audioManager.vibrate();
        }

        final power = PowerUpEngine.trySpawn(
          x: brick.x + brick.width / 2,
          y: brick.y + brick.height / 2,
        );

        if (power != null) {
          powerUps.add(power);
        }

        if (brick.hp <= 0) {
          bricks.removeAt(i);

          score += brick.isBoss
              ? GameConstants.bossDestroyBonus
              : GameConstants.normalBrickDestroyScore;
        }

        break;
      }

      // --------------------------------------------------------
      // COMBO TIMER
      // --------------------------------------------------------

      if (comboTimer > 0) {
        comboTimer--;

        if (comboTimer <= 0) {
          combo = 0;
          comboMultiplier = 1;
        }
      }

      // --------------------------------------------------------
      // NEXT LEVEL
      // --------------------------------------------------------

      if (bricks.isEmpty) {
        level = min(
          GameConstants.maximumLevel,
          level + 1,
        );

        score += GameConstants.nextLevelBonus;

        _spawnParticles(
          canvasWidth / 2,
          canvasHeight / 2,
          GameConstants.neonYellow,
        );

        _initializeLevel();
      }

      // --------------------------------------------------------
      // PARTICLES
      // --------------------------------------------------------

      for (int i = particles.length - 1; i >= 0; i--) {
        final Particle p = particles[i];

        p.dy += GameConstants.particleGravity;
        p.x += p.dx;
        p.y += p.dy;

        p.alpha -= GameConstants.particleFadeSpeed;

        if (p.alpha <= 0) {
          particles.removeAt(i);
        }
      }

      // Keep the ball velocity inside safe limits.
      final double velocity = sqrt(ballDx * ballDx + ballDy * ballDy);

      if (velocity > GameConstants.maxBallSpeed) {
        final double scale = GameConstants.maxBallSpeed / velocity;

        ballDx *= scale;
        ballDy *= scale;
      }
    });
  }

  void _updateBoss() {
    for (final brick in bricks) {
      if (!brick.isBoss) continue;

      brick.phase += 0.035;

      final center = canvasWidth / 2;
      final target =
          center + sin(brick.phase) * GameConstants.bossMoveAmplitude;

      final desiredX = target - brick.width / 2;

      final delta = desiredX - brick.x;

      brick.velocityX = brick.velocityX * 0.90 + delta * 0.08;

      brick.velocityX = brick.velocityX.clamp(
        -GameConstants.bossMoveSpeed * 3,
        GameConstants.bossMoveSpeed * 3,
      );

      brick.x += brick.velocityX;

      brick.x = brick.x.clamp(
        8.0,
        max(8.0, canvasWidth - brick.width - 8.0),
      );

      final ratio = brick.maxHp == 0 ? 0.0 : brick.hp / brick.maxHp;

      brick.enraged = ratio <= 0.45;

      bossPulse += brick.enraged ? 0.08 : 0.035;
    }
  }

  void _collectPowerUp(PowerUp power) {
    switch (power.type) {
      case PowerUpType.multiBall:
        // Safe fallback: add speed rather than
        // rewriting the entire multi-ball engine.
        ballDx *= 1.08;
        ballDy *= 1.08;
        powerUpTimer = 8;
        break;

      case PowerUpType.bigPaddle:
        paddleWidth = min(
          originalPaddleWidth * 1.65,
          canvasWidth * 0.72,
        );
        powerUpTimer = 10;
        break;

      case PowerUpType.slowBall:
        ballDx *= 0.70;
        ballDy *= 0.70;
        powerUpTimer = 8;
        break;

      case PowerUpType.fireBall:
        fireBallActive = true;
        powerUpTimer = 12;
        break;

      case PowerUpType.extraLife:
        lives++;
        break;

      case PowerUpType.magnet:
        magnetActive = true;
        powerUpTimer = 10;
        break;

      case PowerUpType.bomb:
        for (int i = bricks.length - 1; i >= 0; i--) {
          final brick = bricks[i];

          final dx = brick.x + brick.width / 2 - power.x;

          final dy = brick.y + brick.height / 2 - power.y;

          if (dx.abs() < 130 && dy.abs() < 100) {
            bricks.removeAt(i);
            score += GameConstants.normalBrickDestroyScore;
          }
        }

        screenEffects.heavyHit();
        break;
    }

    ProEffects.burst(
      proEffects,
      x: power.x,
      y: power.y,
      color: power.color,
      count: 24,
      power: 6,
    );
  }

  void _spawnParticles(
    double x,
    double y,
    Color color,
  ) {
    for (int i = 0; i < GameConstants.particlesPerHit; i++) {
      particles.add(
        Particle(
          x: x,
          y: y,
          dx: (Random().nextDouble() - 0.5) *
              GameConstants.particleVelocityRange,
          dy: (Random().nextDouble() - 0.5) *
              GameConstants.particleVelocityRange,
          size: Random().nextDouble() * GameConstants.particleMaxSize +
              GameConstants.particleBaseSize,
          color: color,
        ),
      );
    }
  }

  void _gameOver() {
    gameTimer?.cancel();

    setState(() {
      isPlaying = false;
      isGameOver = true;
    });

    _saveHighScore();

    _showInterstitial();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05050D),
      body: LayoutBuilder(
        builder: (context, constraints) {
          canvasWidth = constraints.maxWidth;

          canvasHeight = constraints.maxHeight;

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (!isPlaying || isPaused) {
                return;
              }

              setState(() {
                paddleX += details.delta.dx;

                paddleX = paddleX.clamp(
                  0.0,
                  canvasWidth - paddleWidth,
                );
              });
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: GamePainter(
                      paddleX: paddleX,
                      paddleWidth: paddleWidth,
                      paddleHeight: paddleHeight,
                      ballX: ballX,
                      ballY: ballY,
                      ballRadius: ballRadius,
                      bricks: bricks,
                      particles: particles,
                      powerUps: powerUps,
                      effects: proEffects,
                      ballTrail: ballTrail,
                    ),
                  ),
                ),

                // HUD
                Positioned(
                  top: 40,
                  left: 18,
                  right: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _neonText(
                        'النقاط $score',
                        const Color(
                          0xFF00E5FF,
                        ),
                      ),
                      _neonText(
                        'المستوى $level',
                        const Color(
                          0xFFFFE600,
                        ),
                      ),
                      _neonText(
                        '❤️ $lives',
                        const Color(
                          0xFFFF007F,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isPlaying && !isGameOver) _startScreen(),

                if (isPaused) _pauseScreen(),
                if (isGameOver) _gameOverScreen(),
                if (isPaused && isPlaying) _pauseScreen(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _neonText(
    String text,
    Color color,
  ) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: color,
            blurRadius: 12,
          ),
        ],
      ),
    );
  }

  Widget _startScreen() {
    if (!settingsLoaded) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00E5FF),
        ),
      );
    }

    return StartMenu(
      highScore: highScore,
      onPlay: startGame,
      onSettings: _openSettings,
    );
  }

  Widget _pauseScreen() {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: GameConstants.panelColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: GameConstants.neonCyan,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: GameConstants.neonCyan,
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: GameConstants.neonCyan,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _togglePause,
                child: const Text('متابعة ▶'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameOverScreen() {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0B1E),
            borderRadius: BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: const Color(
                0xFFFF007F,
              ),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFFF007F),
                blurRadius: 25,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFFF007F),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'النقاط: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton.icon(
                onPressed: _showRewardedAd,
                icon: const Icon(
                  Icons.movie,
                  color: Colors.black,
                ),
                label: const Text(
                  'شاهد إعلان + حياة ❤️',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFFFE600,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              OutlinedButton(
                onPressed: startGame,
                child: const Text(
                  'إعادة اللعب 🔄',
                  style: TextStyle(
                    color: Color(
                      0xFF00E5FF,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    gameTimer = null;
    isPlaying = false;
    isPaused = false;
    super.dispose();
  }
}
