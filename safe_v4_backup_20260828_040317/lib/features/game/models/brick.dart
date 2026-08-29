import 'package:flutter/material.dart';

class Brick {
  double x;
  double y;
  double width;
  double height;

  Color color;

  int hp;
  int maxHp;

  bool isBoss;

  // Pro boss state
  double velocityX = 0;
  double phase = 0;
  bool enraged = false;

  Brick({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    this.hp = 1,
    this.maxHp = 1,
    this.isBoss = false,
  });
}
