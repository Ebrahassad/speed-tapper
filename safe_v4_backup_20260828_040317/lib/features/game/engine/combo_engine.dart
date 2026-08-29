class ComboEngine {
  int combo = 0;
  int multiplier = 1;
  int timer = 0;

  final int timeoutFrames;
  final int maximumMultiplier;

  ComboEngine({
    this.timeoutFrames = 180,
    this.maximumMultiplier = 8,
  });

  void reset() {
    combo = 0;
    multiplier = 1;
    timer = 0;
  }

  void hit() {
    combo++;
    timer = timeoutFrames;

    multiplier = 1 + (combo ~/ 3);

    if (multiplier > maximumMultiplier) {
      multiplier = maximumMultiplier;
    }
  }

  void update() {
    if (timer <= 0) {
      return;
    }

    timer--;

    if (timer <= 0) {
      reset();
    }
  }

  int get bonus {
    return multiplier * 5;
  }

  bool get active {
    return combo > 1 && timer > 0;
  }
}
