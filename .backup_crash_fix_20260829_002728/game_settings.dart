import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  static const String _soundKey = 'neon_sound_enabled';
  static const String _musicKey = 'neon_music_enabled';
  static const String _vibrationKey = 'neon_vibration_enabled';

  static const String _highScoreKey = 'neon_high_score';
  static const String _bestLevelKey = 'neon_best_level';

  bool soundEnabled;
  bool musicEnabled;
  bool vibrationEnabled;

  int highScore;
  int bestLevel;

  GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.highScore = 0,
    this.bestLevel = 1,
  });

  static Future<GameSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return GameSettings(
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      musicEnabled: prefs.getBool(_musicKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
      highScore: prefs.getInt(_highScoreKey) ?? 0,
      bestLevel: prefs.getInt(_bestLevelKey) ?? 1,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_soundKey, soundEnabled);
    await prefs.setBool(_musicKey, musicEnabled);
    await prefs.setBool(_vibrationKey, vibrationEnabled);

    await prefs.setInt(_highScoreKey, highScore);
    await prefs.setInt(_bestLevelKey, bestLevel);
  }

  Future<void> saveScore(int score, int level) async {
    bool changed = false;

    if (score > highScore) {
      highScore = score;
      changed = true;
    }

    if (level > bestLevel) {
      bestLevel = level;
      changed = true;
    }

    if (changed) {
      await save();
    }
  }

  Future<void> resetProgress() async {
    highScore = 0;
    bestLevel = 1;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_highScoreKey);
    await prefs.remove(_bestLevelKey);
  }
}
