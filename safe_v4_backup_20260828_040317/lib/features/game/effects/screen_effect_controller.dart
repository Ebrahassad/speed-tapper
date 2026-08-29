import 'dart:math';

class ScreenEffectController {
  double shake = 0;
  double flash = 0;

  final Random _random = Random();

  void hit({double amount = 1.5}) {
    shake = max(shake, amount);
  }

  void heavyHit() {
    shake = max(shake, 7);
    flash = max(flash, 0.22);
  }

  void update() {
    shake *= 0.82;
    flash *= 0.78;

    if (shake < 0.03) {
      shake = 0;
    }

    if (flash < 0.01) {
      flash = 0;
    }
  }

  double get offsetX {
    if (shake <= 0) return 0;

    return (_random.nextDouble() * 2 - 1) * shake;
  }

  double get offsetY {
    if (shake <= 0) return 0;

    return (_random.nextDouble() * 2 - 1) * shake;
  }
}
