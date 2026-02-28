import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/data/gamedata.dart';
import 'package:quiz/data/models/question.dart';
import 'package:quiz/models/achievement.dart';
import 'package:quiz/ui/providers/game_provider.dart';
import 'package:quiz/ui/providers/quest_provider.dart';
import 'package:quiz/ui/providers/coins_provider.dart';
import 'package:quiz/ui/providers/pet_provider.dart';
import 'package:quiz/ui/services/sound_manager.dart';
import 'package:quiz/features/common/dialogs/achievement_dialog.dart';
import 'package:my_progress_bar/progress_bar.dart';

class Game extends StatefulWidget {
  final int ID;
  const Game({super.key, required this.ID});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;
  final SoundManager _soundManager = SoundManager();
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questions = GameData.getQuiz(widget.ID);

    if (_questions.isEmpty) return;

    _questions.shuffle();
    _questions = _questions.take(12).toList();

    for (var q in _questions) {
      q.shuffleAnswers();
    }

    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
  }

  void _checkAnswer(int selectedIndex) {
    if (_answered || _questions.isEmpty) return;

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
    });

    final isCorrect = selectedIndex == _questions[_currentIndex].correctIndex;
    
    if (isCorrect) {
      _score++;
      _soundManager.play(SoundType.correct);
    } else {
      _soundManager.play(SoundType.wrong);
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        _finishGame();
      }
    });
  }

  Future<void> _finishGame() async {
    _soundManager.play(SoundType.gameOver);
    
    final isPerfect = _score == _questions.length;
    final gameProvider = context.read<GameProvider>();
    final questProvider = context.read<QuestProvider>();
    final coinsProvider = context.read<CoinsProvider>();
    final points = _score * 10 + (isPerfect ? 50 : 0);
    
    // Начисляем очки
    await gameProvider.finishGame(
      correctAnswers: _score,
      totalAnswers: _questions.length,
      isPerfect: isPerfect,
    );

    // Начисляем монеты (баллы / 10)
    final earnedCoins = gameProvider.calculateCoins(points);
    if (earnedCoins > 0) {
      await coinsProvider.addCoins(earnedCoins);
    }

    // Обновляем прогресс квестов
    final questReward = await questProvider.updateProgress(
      gamesPlayed: 1,
      correctAnswers: _score,
      perfectGames: isPerfect ? 1 : 0,
      points: points,
    );

    final newAchievements = gameProvider.newAchievements;

    if (mounted) {
      // Показываем результат с монетами
      _showResultWithCoins(points, earnedCoins, isPerfect, newAchievements, questReward);
    }
  }

  void _showResultWithCoins(int points, int coins, bool isPerfect, List<Achievement> achievements, int questReward) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isPerfect ? "Идеально! 🎉" : "Игра окончена 🎉",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Результат: $_score из ${_questions.length}",
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ResultBadge(icon: "⭐", value: "+$points", label: "очков"),
                const SizedBox(width: 12),
                _ResultBadge(icon: "🪙", value: "+$coins", label: "монет"),
              ],
            ),
            if (questReward > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("🎁 +$questReward за квесты!", 
                  style: const TextStyle(color: Color(0xFFFFD700))),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (achievements.isNotEmpty) {
                _soundManager.play(SoundType.achievement);
                _showAchievementsDialog(achievements);
              } else {
                setState(() => _loadQuestions());
              }
            },
            child: const Text("Играть снова"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Выйти"),
          ),
        ],
      ),
    );
  }

  // Виджет для отображения очков/монет в результатах
  Widget _ResultBadge({required String icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7ED421).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7ED421),
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showQuestRewardDialog(int reward, List<Achievement> achievements) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎁", style: TextStyle(fontSize: 50)),
            const SizedBox(height: 16),
            const Text(
              "Награда за квесты!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "+$reward очков",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (achievements.isNotEmpty) {
                _soundManager.play(SoundType.achievement);
                _showAchievementsDialog(achievements);
              } else {
                Platform.isIOS ? _showCupertinoResult() : _showMaterialResult();
              }
            },
            child: const Text("Продолжить"),
          ),
        ],
      ),
    );
  }

  void _showAchievementsDialog(List<Achievement> achievements) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AchievementDialog(
        achievements: achievements,
        onContinue: () {
          Navigator.pop(context);
          Platform.isIOS ? _showCupertinoResult() : _showMaterialResult();
        },
      ),
    );
  }

  void _showCupertinoExitDialog() {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Выйти из игры?"),
        content: const Text("Ваш прогресс будет потерян."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Нет"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Да"),
          ),
        ],
      ),
    );
  }

  void _showMaterialExitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Выйти из игры?"),
        content: const Text("Ваш прогресс будет потерян."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Нет"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Да"),
          ),
        ],
      ),
    );
  }

  void _showCupertinoResult() {
    final isPerfect = _score == _questions.length;
    final points = _score * 10 + (isPerfect ? 50 : 0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: Text(isPerfect ? "Идеально! 🎉" : "Игра окончена 🎉"),
        content: Column(
          children: [
            Text("Ваш результат: $_score из ${_questions.length}"),
            const SizedBox(height: 8),
            Text(
              "+$points очков",
              style: const TextStyle(
                color: Color(0xFF7ED421),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _loadQuestions();
              });
            },
            child: const Text("Играть снова"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Выйти"),
          ),
        ],
      ),
    );
  }

  void _showMaterialResult() {
    final isPerfect = _score == _questions.length;
    final points = _score * 10 + (isPerfect ? 50 : 0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(isPerfect ? "Идеально! 🎉" : "Игра окончена 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Ваш результат: $_score из ${_questions.length}"),
            const SizedBox(height: 8),
            Text(
              "+$points очков",
              style: const TextStyle(
                color: Color(0xFF7ED421),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _loadQuestions();
              });
            },
            child: const Text("Играть снова"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Выйти"),
          ),
        ],
      ),
    );
  }

  Color _getAnswerColor(int index) {
    if (!_answered) return const Color(0xFF7ED421);
    
    final correctIndex = _questions[_currentIndex].correctIndex;
    
    if (index == correctIndex) {
      return Colors.green;
    } else if (index == _selectedAnswer) {
      return Colors.red;
    }
    return Colors.grey.withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FB);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            "В этой категории пока нет вопросов",
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        ),
      );
    }

    if (_currentIndex >= _questions.length) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text("Ошибка индекса", style: TextStyle(color: textColor)),
        ),
      );
    }

    final question = _questions[_currentIndex];

    // Получаем питомца
    final petProvider = context.watch<PetProvider>();
    final pet = petProvider.currentPet;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text("Игра"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Platform.isIOS
                ? _showCupertinoExitDialog()
                : _showMaterialExitDialog();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: HorizontalProgressBar(
                    maxValue: _questions.length.toDouble(),
                    currentPosition: (_currentIndex + 1).toDouble(),
                    progressColor: const Color(0xFF7ED421),
                    thumbColor: const Color(0xFF7ED421),
                    trackHeight: 10,
                    bufferedPosition: _questions.length.toDouble(),
                    bufferedColor: const Color(0xFFEBEBEB),
                    onChanged: (double value) {},
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF7ED421),
                  child: Text(
                    "${_currentIndex + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Питомец
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pet.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                Text(
                  "Смотрит за тобой!",
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              question.question,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            Column(
              children: List.generate(
                question.answers.length,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: _answered ? null : () => _checkAnswer(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getAnswerColor(index),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: _getAnswerColor(index),
                    ),
                    child: Text(
                      question.answers[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pet.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  "Очки: $_score",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}