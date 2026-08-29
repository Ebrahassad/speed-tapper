import 'dart:math';

import '../models/power_up.dart';

class PowerUpEngine {
  PowerUpEngine._();

  static final Random _random = Random();

  static PowerUpType randomType() {
    final value = _random.nextInt(100);

    if (value < 20) {
      return PowerUpType.multiBall;
    }

    if (value < 35) {
      return PowerUpType.bigPaddle;
    }

    if (value < 48) {
      return PowerUpType.slowBall;
    }

    if (value < 61) {
      return PowerUpType.fireBall;
    }

    if (value < 73) {
      return PowerUpType.extraLife;
    }

    if (value < 87) {
      return PowerUpType.magnet;
    }

    return PowerUpType.bomb;
  }

  static PowerUp? trySpawn({
    required double x,
    required double y,
    double chance = 0.18,
  }) {
    if (_random.nextDouble() > chance) {
      return null;
    }

    return PowerUp(
      x: x,
      y: y,
      type: randomType(),
    );
  }

  static void update(
    List<PowerUp> powerUps,
    double canvasHeight,
  ) {
    for (int i = powerUps.length - 1; i >= 0; i--) {
      final power = powerUps[i];

      power.y += power.speed;

      if (power.y - power.size > canvasHeight) {
        powerUps.removeAt(i);
      }
    }
  }
}
