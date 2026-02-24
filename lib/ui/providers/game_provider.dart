import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/models/player_progress.dart';
import 'package:quiz/models/achievement.dart';

class GameProvider extends ChangeNotifier {
  static const String _progressKey = 'player_progress';
  static const String _achievementsKey = 'unlocked_achievements';

  PlayerProgress _progress = PlayerProgress();
  Set<String> _unlockedAchievements = {};
  List<Achievement> _newAchievements = [];
  bool _isInitialized = false;

  PlayerProgress get progress => _progress;
  Set<String> get unlockedAchievements => _unlockedAchievements;
  List<Achievement> get newAchievements => _newAchievements;
  List<Achievement> get allAchievements => Achievement.all;
  bool get isInitialized => _isInitialized;

  // Очки за правильный ответ
  static const int pointsPerCorrectAnswer = 10;
  static const int bonusForPerfectGame = 50;
  static const int streakBonus = 5;

  // Рассчитать монеты из очков (баллы / 10)
  int calculateCoins(int points) {
    return points ~/ 10;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Загружаем прогресс
      final progressJson = prefs.getString(_progressKey);
      if (progressJson != null) {
        _progress = PlayerProgress.fromJson(
          jsonDecode(progressJson) as Map<String, dynamic>,
        );
      }

      // Загружаем ачивки
      final achievementsList = prefs.getStringList(_achievementsKey);
      if (achievementsList != null) {
        _unlockedAchievements = achievementsList.toSet();
      }
    } catch (e) {
      _progress = PlayerProgress();
      _unlockedAchievements = {};
    }

    _isInitialized = true;
    notifyListeners();
  }

  void clearNewAchievements() {
    _newAchievements = [];
    notifyListeners();
  }

  Future<PlayerProgress> finishGame({
    required int correctAnswers,
    required int totalAnswers,
    required bool isPerfect,
  }) async {
    _newAchievements = [];

    // Рассчитываем очки
    int earnedPoints = correctAnswers * pointsPerCorrectAnswer;
    if (isPerfect) {
      earnedPoints += bonusForPerfectGame;
    }

    // Обновляем прогресс
    final newStreak = isPerfect ? _progress.currentStreak + 1 : 0;
    final newBestStreak = newStreak > _progress.bestStreak 
        ? newStreak 
        : _progress.bestStreak;

    int newTotalPoints = _progress.totalPoints + earnedPoints;
    int newLevel = _calculateLevel(newTotalPoints);

    _progress = _progress.copyWith(
      totalPoints: newTotalPoints,
      level: newLevel,
      gamesPlayed: _progress.gamesPlayed + 1,
      correctAnswers: _progress.correctAnswers + correctAnswers,
      totalAnswers: _progress.totalAnswers + totalAnswers,
      bestStreak: newBestStreak,
      currentStreak: newStreak,
      lastPlayedAt: DateTime.now(),
    );

    // Проверяем ачивки
    await _checkAchievements(isPerfect: isPerfect);
    
    // Сохраняем
    await _saveProgress();

    notifyListeners();
    return _progress;
  }

  int _calculateLevel(int points) {
    // Каждый уровень требует level * 100 очков
    int level = 1;
    int requiredPoints = 100;
    
    while (points >= requiredPoints) {
      level++;
      requiredPoints += level * 100;
    }
    
    return level;
  }

  Future<void> _checkAchievements({bool isPerfect = false}) async {
    final unlockedNew = <String>[];

    for (final achievement in Achievement.all) {
      if (_unlockedAchievements.contains(achievement.id)) continue;

      bool isUnlocked = false;

      switch (achievement.type) {
        case AchievementType.gamesPlayed:
          isUnlocked = _progress.gamesPlayed >= achievement.requirement;
          break;
        case AchievementType.correctAnswers:
          isUnlocked = _progress.correctAnswers >= achievement.requirement;
          break;
        case AchievementType.streak:
          isUnlocked = _progress.bestStreak >= achievement.requirement;
          break;
        case AchievementType.perfectGame:
          // Нужно отслеживать общее количество идеальных игр
          // Пока упрощенно
          isUnlocked = isPerfect && _progress.gamesPlayed >= achievement.requirement - 1;
          break;
        case AchievementType.points:
          isUnlocked = _progress.totalPoints >= achievement.requirement;
          break;
        case AchievementType.level:
          isUnlocked = _progress.level >= achievement.requirement;
          break;
        case AchievementType.categoryMaster:
          // Для категорий нужно отслеживать отдельно
          break;
      }

      if (isUnlocked) {
        _unlockedAchievements.add(achievement.id);
        unlockedNew.add(achievement.id);
        _newAchievements.add(achievement);
      }
    }

    if (unlockedNew.isNotEmpty) {
      await _saveAchievements();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, jsonEncode(_progress.toJson()));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_achievementsKey, _unlockedAchievements.toList());
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  // Сброс прогресса (для тестирования)
  Future<void> resetProgress() async {
    _progress = PlayerProgress();
    _unlockedAchievements = {};
    _newAchievements = [];
    
    await _saveProgress();
    await _saveAchievements();
    notifyListeners();
  }

  bool isAchievementUnlocked(String id) => _unlockedAchievements.contains(id);

  double getAchievementProgress(Achievement achievement) {
    if (_unlockedAchievements.contains(achievement.id)) return 1.0;

    double progress = 0.0;
    switch (achievement.type) {
      case AchievementType.gamesPlayed:
        progress = _progress.gamesPlayed / achievement.requirement;
        break;
      case AchievementType.correctAnswers:
        progress = _progress.correctAnswers / achievement.requirement;
        break;
      case AchievementType.streak:
        progress = _progress.bestStreak / achievement.requirement;
        break;
      case AchievementType.perfectGame:
        // Упрощенно
        progress = 0;
        break;
      case AchievementType.points:
        progress = _progress.totalPoints / achievement.requirement;
        break;
      case AchievementType.level:
        progress = _progress.level / achievement.requirement;
        break;
      case AchievementType.categoryMaster:
        progress = 0;
        break;
    }

    return progress.clamp(0.0, 1.0);
  }
}
