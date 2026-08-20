import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/core/constants/app_constants.dart';
import 'package:quiz/domain/entities/player_progress.dart';
import 'package:quiz/domain/entities/achievement.dart';

class GameNotifier extends AsyncNotifier<PlayerGameData> {
  static const String _progressKey = 'player_progress';
  static const String _achievementsKey = 'unlocked_achievements';
  static const String _categoryProgressKey = 'category_progress';

  @override
  Future<PlayerGameData> build() async {
    PlayerProgress progress = PlayerProgress();
    Set<String> unlockedAchievements = {};
    Map<int, int> categoryProgress = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      if (progressJson != null) {
        progress = PlayerProgress.fromJson(
          jsonDecode(progressJson) as Map<String, dynamic>,
        );
      }
      final achievementsList = prefs.getStringList(_achievementsKey);
      if (achievementsList != null) {
        unlockedAchievements = achievementsList.toSet();
      }
      final catProgressJson = prefs.getString(_categoryProgressKey);
      if (catProgressJson != null) {
        final decoded = jsonDecode(catProgressJson) as Map<String, dynamic>;
        categoryProgress =
            decoded.map((k, v) => MapEntry(int.parse(k), v as int));
      }
    } catch (e) {
      progress = PlayerProgress();
      unlockedAchievements = {};
      categoryProgress = {};
    }

    return PlayerGameData(
      progress: progress,
      unlockedAchievements: unlockedAchievements,
      newAchievements: const [],
      categoryProgress: categoryProgress,
    );
  }

  int calculateCoins(int points) => points ~/ AppConstants.coinsPerPoint;

  void clearNewAchievements() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(newAchievements: []));
  }

  /// Записать прогресс по категории: answeredCorrect — сколько правильных из 10
  Future<void> recordCategoryGame({
    required int categoryId,
    required int answeredCorrect,
    required int totalAnswered,
  }) async {
    final current = state.value;
    if (current == null) return;

    final newCatProgress = Map<int, int>.from(current.categoryProgress);
    final prev = newCatProgress[categoryId] ?? 0;
    // Суммируем количество уникальных пройденных вопросов
    // Используем max, чтобы не терять прогресс при повторном прохождении
    final newTotal = prev + totalAnswered;
    newCatProgress[categoryId] = newTotal;

    state = AsyncData(current.copyWith(categoryProgress: newCatProgress));
    await _saveCategoryProgress(newCatProgress);
  }

  /// Получить количество пройденных вопросов в категории
  int getCategoryAnswered(int categoryId) {
    return state.value?.categoryProgress[categoryId] ?? 0;
  }

  /// Получить прогресс категории (0.0 - 1.0)
  double getCategoryProgressPercent(int categoryId, int totalQuestions) {
    final answered = getCategoryAnswered(categoryId);
    if (totalQuestions <= 0) return 0.0;
    return (answered / totalQuestions).clamp(0.0, 1.0);
  }

  Future<void> finishGame({
    required int correctAnswers,
    required int totalAnswers,
    required bool isPerfect,
    required int categoryId,
  }) async {
    final current = state.value ?? PlayerGameData();
    List<Achievement> newAchievements = [];

    int earnedPoints = correctAnswers * AppConstants.pointsPerCorrectAnswer;
    if (isPerfect) earnedPoints += AppConstants.bonusForPerfectGame;

    final newStreak = isPerfect ? current.progress.currentStreak + 1 : 0;
    final newBestStreak = newStreak > current.progress.bestStreak
        ? newStreak
        : current.progress.bestStreak;

    int newTotalPoints = current.progress.totalPoints + earnedPoints;
    int newLevel = _calculateLevel(newTotalPoints);

    final newProgress = current.progress.copyWith(
      totalPoints: newTotalPoints,
      level: newLevel,
      gamesPlayed: current.progress.gamesPlayed + 1,
      correctAnswers: current.progress.correctAnswers + correctAnswers,
      totalAnswers: current.progress.totalAnswers + totalAnswers,
      bestStreak: newBestStreak,
      currentStreak: newStreak,
      lastPlayedAt: DateTime.now(),
    );

    final (unlocked, newAch) = _checkAchievements(
      progress: newProgress,
      unlockedAchievements: current.unlockedAchievements,
      isPerfect: isPerfect,
    );
    newAchievements = newAch;

    // Обновляем прогресс категории
    final newCatProgress = Map<int, int>.from(current.categoryProgress);
    final prev = newCatProgress[categoryId] ?? 0;
    newCatProgress[categoryId] = prev + totalAnswers;

    state = AsyncData(PlayerGameData(
      progress: newProgress,
      unlockedAchievements: unlocked,
      newAchievements: newAchievements,
      categoryProgress: newCatProgress,
    ));

    await _saveProgress(newProgress);
    if (newAch.isNotEmpty) await _saveAchievements(unlocked);
    await _saveCategoryProgress(newCatProgress);
  }

  int _calculateLevel(int points) {
    int level = 1;
    int requiredPoints = 100;
    while (points >= requiredPoints) {
      level++;
      requiredPoints += level * 100;
    }
    return level;
  }

  (Set<String>, List<Achievement>) _checkAchievements({
    required PlayerProgress progress,
    required Set<String> unlockedAchievements,
    bool isPerfect = false,
  }) {
    final unlocked = Set<String>.from(unlockedAchievements);
    final newAch = <Achievement>[];

    for (final achievement in Achievement.all) {
      if (unlocked.contains(achievement.id)) continue;

      bool isUnlocked = false;
      switch (achievement.type) {
        case AchievementType.gamesPlayed:
          isUnlocked = progress.gamesPlayed >= achievement.requirement;
          break;
        case AchievementType.correctAnswers:
          isUnlocked = progress.correctAnswers >= achievement.requirement;
          break;
        case AchievementType.streak:
          isUnlocked = progress.bestStreak >= achievement.requirement;
          break;
        case AchievementType.perfectGame:
          isUnlocked = isPerfect &&
              progress.gamesPlayed >= achievement.requirement - 1;
          break;
        case AchievementType.points:
          isUnlocked = progress.totalPoints >= achievement.requirement;
          break;
        case AchievementType.level:
          isUnlocked = progress.level >= achievement.requirement;
          break;
        case AchievementType.categoryMaster:
          break;
      }

      if (isUnlocked) {
        unlocked.add(achievement.id);
        newAch.add(achievement);
      }
    }

    return (unlocked, newAch);
  }

  Future<void> _saveProgress(PlayerProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  Future<void> _saveAchievements(Set<String> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_achievementsKey, achievements.toList());
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  Future<void> _saveCategoryProgress(Map<int, int> catProgress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = catProgress.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_categoryProgressKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('Error saving category progress: $e');
    }
  }

  Future<void> resetProgress() async {
    state = AsyncData(PlayerGameData());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
      await prefs.remove(_achievementsKey);
      await prefs.remove(_categoryProgressKey);
    } catch (e) {
      debugPrint('Error resetting progress: $e');
    }
  }

  bool isAchievementUnlocked(String id) =>
      state.value?.unlockedAchievements.contains(id) ?? false;

  double getAchievementProgress(Achievement achievement) {
    final data = state.value;
    if (data == null) return 0.0;
    if (data.unlockedAchievements.contains(achievement.id)) return 1.0;

    double progress = 0.0;
    switch (achievement.type) {
      case AchievementType.gamesPlayed:
        progress = data.progress.gamesPlayed / achievement.requirement;
        break;
      case AchievementType.correctAnswers:
        progress = data.progress.correctAnswers / achievement.requirement;
        break;
      case AchievementType.streak:
        progress = data.progress.bestStreak / achievement.requirement;
        break;
      case AchievementType.perfectGame:
        progress = 0;
        break;
      case AchievementType.points:
        progress = data.progress.totalPoints / achievement.requirement;
        break;
      case AchievementType.level:
        progress = data.progress.level / achievement.requirement;
        break;
      case AchievementType.categoryMaster:
        progress = 0;
        break;
    }
    return progress.clamp(0.0, 1.0);
  }
}

@immutable
class PlayerGameData {
  final PlayerProgress progress;
  final Set<String> unlockedAchievements;
  final List<Achievement> newAchievements;
  final Map<int, int> categoryProgress;

  PlayerGameData({
    this.progress = const PlayerProgress(),
    Set<String>? unlockedAchievements,
    List<Achievement>? newAchievements,
    Map<int, int>? categoryProgress,
  })  : unlockedAchievements = unlockedAchievements ?? {},
        newAchievements = newAchievements ?? [],
        categoryProgress = categoryProgress ?? {};

  PlayerGameData copyWith({
    PlayerProgress? progress,
    Set<String>? unlockedAchievements,
    List<Achievement>? newAchievements,
    Map<int, int>? categoryProgress,
  }) {
    return PlayerGameData(
      progress: progress ?? this.progress,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      newAchievements: newAchievements ?? this.newAchievements,
      categoryProgress: categoryProgress ?? this.categoryProgress,
    );
  }
}

final gameProvider =
    AsyncNotifierProvider<GameNotifier, PlayerGameData>(GameNotifier.new);
