import 'package:flutter/services.dart';

import '../settings/game_settings.dart';

class AudioManager {
  AudioManager(this.settings);

  final GameSettings settings;

  Future<void> tap() async {
    if (!settings.soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> brickHit() async {
    if (!settings.soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> gameOver() async {
    if (!settings.soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  Future<void> vibrate() async {
    if (!settings.vibrationEnabled) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> strongVibration() async {
    if (!settings.vibrationEnabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> comboHit() async {
    if (!settings.soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> bossHit() async {
    if (!settings.soundEnabled) return;
    await SystemSound.play(SystemSoundType.alert);
  }
}
