import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/domain/entities/quest.dart';

class QuestNotifier extends AsyncNotifier<QuestData> {
  static const String _questProgressKey = 'quest_progress';
  static const String _lastQuestDateKey = 'last_quest_date';

  @override
  Future<QuestData> build() async {
    List<Quest> todayQuests = [];
    Map<String, int> progress = {};
    Set<String> completedQuests = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDateStr = prefs.getString(_lastQuestDateKey);
      final today = _getTodayDateString();

      todayQuests = _generateDailyQuests();

      if (lastDateStr == today) {
        final progressJson = prefs.getString(_questProgressKey);
        if (progressJson != null) {
          final decoded = jsonDecode(progressJson) as Map<String, dynamic>;
          progress = decoded.map((k, v) => MapEntry(k, v as int));
        }

        final completedJson =
            prefs.getString('${_questProgressKey}_completed');
        if (completedJson != null) {
          final decoded = jsonDecode(completedJson) as List;
          completedQuests = decoded.map((e) => e.toString()).toSet();
        }
      } else {
        await prefs.setString(_lastQuestDateKey, today);
        await prefs.setString(_questProgressKey, jsonEncode({}));
        await prefs.setString('${_questProgressKey}_completed', jsonEncode([]));
      }
    } catch (e) {
      todayQuests = _generateDailyQuests();
      progress = {};
      completedQuests = {};
    }

    return QuestData(
      todayQuests: todayQuests,
      progress: progress,
      completedQuests: completedQuests,
    );
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

  bool isQuestCompleted(String id) =>
      state.value?.completedQuests.contains(id) ?? false;

  int getQuestProgress(Quest quest) =>
      state.value?.progress[quest.id] ?? 0;

  double getQuestProgressPercent(Quest quest) {
    if (isQuestCompleted(quest.id)) return 1.0;
    final current = getQuestProgress(quest);
    return (current / quest.requirement).clamp(0.0, 1.0);
  }

  int get completedCount => state.value?.completedQuests.length ?? 0;
  int get totalQuests => state.value?.todayQuests.length ?? 0;

  Future<int> updateProgress({
    int gamesPlayed = 0,
    int correctAnswers = 0,
    int perfectGames = 0,
    int points = 0,
  }) async {
    final current = state.value;
    if (current == null) return 0;

    int totalReward = 0;
    final newProgress = Map<String, int>.from(current.progress);
    final newCompleted = Set<String>.from(current.completedQuests);

    for (final quest in current.todayQuests) {
      if (newCompleted.contains(quest.id)) continue;

      int currentVal = newProgress[quest.id] ?? 0;
      int newVal = currentVal;

      switch (quest.type) {
        case QuestType.playGames:
          newVal += gamesPlayed;
          break;
        case QuestType.correctAnswers:
          newVal += correctAnswers;
          break;
        case QuestType.perfectGames:
          newVal += perfectGames;
          break;
        case QuestType.points:
          newVal += points;
          break;
      }

      newProgress[quest.id] = newVal;

      if (newVal >= quest.requirement && !newCompleted.contains(quest.id)) {
        newCompleted.add(quest.id);
        totalReward += quest.reward;
      }
    }

    state = AsyncData(current.copyWith(
      progress: newProgress,
      completedQuests: newCompleted,
    ));

    await _saveProgress(newProgress, newCompleted);
    return totalReward;
  }

  Future<void> _saveProgress(
      Map<String, int> progress, Set<String> completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_questProgressKey, jsonEncode(progress));
      await prefs.setString(
          '${_questProgressKey}_completed', jsonEncode(completed.toList()));
    } catch (e) {
      debugPrint('Error saving quest progress: $e');
    }
  }

  Future<void> resetDailyQuests() async {
    state = AsyncData(QuestData(
      todayQuests: _generateDailyQuests(),
      progress: {},
      completedQuests: {},
    ));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_questProgressKey, jsonEncode({}));
      await prefs.setString(
          '${_questProgressKey}_completed', jsonEncode([]));
    } catch (e) {
      // ignore
    }
  }
}

@immutable
class QuestData {
  final List<Quest> todayQuests;
  final Map<String, int> progress;
  final Set<String> completedQuests;

  const QuestData({
    this.todayQuests = const [],
    this.progress = const {},
    this.completedQuests = const {},
  });

  QuestData copyWith({
    List<Quest>? todayQuests,
    Map<String, int>? progress,
    Set<String>? completedQuests,
  }) {
    return QuestData(
      todayQuests: todayQuests ?? this.todayQuests,
      progress: progress ?? this.progress,
      completedQuests: completedQuests ?? this.completedQuests,
    );
  }
}

final questProvider =
    AsyncNotifierProvider<QuestNotifier, QuestData>(QuestNotifier.new);
