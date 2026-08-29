import 'package:shared_preferences/shared_preferences.dart';

class GameStats {
  static const String bestScoreKey = 'neon_best_score';
  static const String bestLevelKey = 'neon_best_level';
  static const String bestComboKey = 'neon_best_combo';
  static const String bricksKey = 'neon_total_bricks';
  static const String gamesKey = 'neon_games_played';
  static const String winsKey = 'neon_games_won';

  int bestScore;
  int bestLevel;
  int bestCombo;
  int totalBricks;
  int gamesPlayed;
  int gamesWon;

  GameStats({
    this.bestScore = 0,
    this.bestLevel = 1,
    this.bestCombo = 0,
    this.totalBricks = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
  });

  static Future<GameStats> load() async {
    final prefs = await SharedPreferences.getInstance();

    return GameStats(
      bestScore: prefs.getInt(bestScoreKey) ?? 0,
      bestLevel: prefs.getInt(bestLevelKey) ?? 1,
      bestCombo: prefs.getInt(bestComboKey) ?? 0,
      totalBricks: prefs.getInt(bricksKey) ?? 0,
      gamesPlayed: prefs.getInt(gamesKey) ?? 0,
      gamesWon: prefs.getInt(winsKey) ?? 0,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(bestScoreKey, bestScore);
    await prefs.setInt(bestLevelKey, bestLevel);
    await prefs.setInt(bestComboKey, bestCombo);
    await prefs.setInt(bricksKey, totalBricks);
    await prefs.setInt(gamesKey, gamesPlayed);
    await prefs.setInt(winsKey, gamesWon);
  }

  Future<void> registerGame() async {
    gamesPlayed++;
    await save();
  }

  Future<void> registerWin() async {
    gamesWon++;
    await save();
  }

  Future<void> registerBrick() async {
    totalBricks++;
  }

  Future<void> updateBest({
    required int score,
    required int level,
    required int combo,
  }) async {
    bool changed = false;

    if (score > bestScore) {
      bestScore = score;
      changed = true;
    }

    if (level > bestLevel) {
      bestLevel = level;
      changed = true;
    }

    if (combo > bestCombo) {
      bestCombo = combo;
      changed = true;
    }

    if (changed) {
      await save();
    }
  }
}
