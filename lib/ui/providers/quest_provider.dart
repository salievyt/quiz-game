import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuestType {
  playGames,
  correctAnswers,
  perfectGames,
  points,
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int requirement;
  final int reward;
  final String icon;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirement,
    required this.reward,
    required this.icon,
  });

  static List<Quest> get dailyQuests => [
    const Quest(
      id: 'daily_play_1',
      title: 'Первая игра',
      description: 'Сыграй 1 игру',
      type: QuestType.playGames,
      requirement: 1,
      reward: 25,
      icon: '🎮',
    ),
    const Quest(
      id: 'daily_play_3',
      title: 'Три игры',
      description: 'Сыграй 3 игры',
      type: QuestType.playGames,
      requirement: 3,
      reward: 50,
      icon: '🎯',
    ),
    const Quest(
      id: 'daily_correct_10',
      title: 'Знаток',
      description: 'Дай 10 правильных ответов',
      type: QuestType.correctAnswers,
      requirement: 10,
      reward: 30,
      icon: '✅',
    ),
    const Quest(
      id: 'daily_perfect_1',
      title: 'Перфекционист',
      description: 'Выиграй 1 игру без ошибок',
      type: QuestType.perfectGames,
      requirement: 1,
      reward: 75,
      icon: '💯',
    ),
    const Quest(
      id: 'daily_points_100',
      title: 'Набор очков',
      description: 'Набери 100 очков',
      type: QuestType.points,
      requirement: 100,
      reward: 40,
      icon: '⭐',
    ),
  ];
}

class QuestProvider extends ChangeNotifier {
  static const String _questProgressKey = 'quest_progress';
  static const String _lastQuestDateKey = 'last_quest_date';

  List<Quest> _todayQuests = [];
  Map<String, int> _progress = {};
  Set<String> _completedQuests = {};
  bool _isInitialized = false;

  List<Quest> get todayQuests => _todayQuests;
  Map<String, int> get progress => _progress;
  Set<String> get completedQuests => _completedQuests;
  bool get isInitialized => _isInitialized;

  bool isQuestCompleted(String id) => _completedQuests.contains(id);

  int getQuestProgress(Quest quest) {
    return _progress[quest.id] ?? 0;
  }

  double getQuestProgressPercent(Quest quest) {
    if (isQuestCompleted(quest.id)) return 1.0;
    final current = getQuestProgress(quest);
    return (current / quest.requirement).clamp(0.0, 1.0);
  }

  int get completedCount => _completedQuests.length;
  int get totalQuests => _todayQuests.length;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDateStr = prefs.getString(_lastQuestDateKey);
      final today = _getTodayDateString();

      // Если новый день - сбрасываем квесты
      if (lastDateStr != today) {
        _todayQuests = _generateDailyQuests();
        _progress = {};
        _completedQuests = {};
        
        await prefs.setString(_lastQuestDateKey, today);
        await prefs.setString(_questProgressKey, jsonEncode({}));
        await prefs.setString('${_questProgressKey}_completed', jsonEncode([]));
      } else {
        // Загружаем прогресс
        _todayQuests = _generateDailyQuests();
        
        final progressJson = prefs.getString(_questProgressKey);
        if (progressJson != null) {
          final decoded = jsonDecode(progressJson) as Map<String, dynamic>;
          _progress = decoded.map((k, v) => MapEntry(k, v as int));
        }

        final completedJson = prefs.getString('${_questProgressKey}_completed');
        if (completedJson != null) {
          final decoded = jsonDecode(completedJson) as List;
          _completedQuests = decoded.map((e) => e.toString()).toSet();
        }
      }
    } catch (e) {
      _todayQuests = _generateDailyQuests();
      _progress = {};
      _completedQuests = {};
    }

    _isInitialized = true;
    notifyListeners();
  }

  List<Quest> _generateDailyQuests() {
    final allQuests = Quest.dailyQuests;
    allQuests.shuffle();
    return allQuests.take(4).toList();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<int> updateProgress({
    int gamesPlayed = 0,
    int correctAnswers = 0,
    int perfectGames = 0,
    int points = 0,
  }) async {
    int totalReward = 0;

    for (final quest in _todayQuests) {
      if (_completedQuests.contains(quest.id)) continue;

      int currentProgress = _progress[quest.id] ?? 0;
      int newProgress = currentProgress;

      switch (quest.type) {
        case QuestType.playGames:
          newProgress += gamesPlayed;
          break;
        case QuestType.correctAnswers:
          newProgress += correctAnswers;
          break;
        case QuestType.perfectGames:
          newProgress += perfectGames;
          break;
        case QuestType.points:
          newProgress += points;
          break;
      }

      _progress[quest.id] = newProgress;

      // Проверяем выполнение
      if (newProgress >= quest.requirement && !_completedQuests.contains(quest.id)) {
        _completedQuests.add(quest.id);
        totalReward += quest.reward;
      }
    }

    if (_progress.isNotEmpty || _completedQuests.isNotEmpty) {
      await _saveProgress();
      notifyListeners();
    }

    return totalReward;
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_questProgressKey, jsonEncode(_progress));
      await prefs.setString(
        '${_questProgressKey}_completed', 
        jsonEncode(_completedQuests.toList()),
      );
    } catch (e) {
      debugPrint('Error saving quest progress: $e');
    }
  }

  // Сброс для тестирования
  Future<void> resetDailyQuests() async {
    _todayQuests = _generateDailyQuests();
    _progress = {};
    _completedQuests = {};
    await _saveProgress();
    notifyListeners();
  }
}
