import 'package:flutter/material.dart';

enum PowerUpType {
  multiBall,
  bigPaddle,
  slowBall,
  fireBall,
  extraLife,
  magnet,
  bomb,
}

class PowerUp {
  double x;
  double y;
  double size;
  double speed;

  final PowerUpType type;

  PowerUp({
    required this.x,
    required this.y,
    required this.type,
    this.size = 22,
    this.speed = 2.4,
  });

  Color get color {
    switch (type) {
      case PowerUpType.multiBall:
        return const Color(0xFF00E5FF);
      case PowerUpType.bigPaddle:
        return const Color(0xFF00FF66);
      case PowerUpType.slowBall:
        return const Color(0xFFAA66FF);
      case PowerUpType.fireBall:
        return const Color(0xFFFF5500);
      case PowerUpType.extraLife:
        return const Color(0xFFFF007F);
      case PowerUpType.magnet:
        return const Color(0xFFFFE600);
      case PowerUpType.bomb:
        return const Color(0xFFFF3355);
    }
  }

  String get label {
    switch (type) {
      case PowerUpType.multiBall:
        return '×3';
      case PowerUpType.bigPaddle:
        return 'W';
      case PowerUpType.slowBall:
        return 'S';
      case PowerUpType.fireBall:
        return 'F';
      case PowerUpType.extraLife:
        return '♥';
      case PowerUpType.magnet:
        return 'M';
      case PowerUpType.bomb:
        return 'B';
    }
  }
}
