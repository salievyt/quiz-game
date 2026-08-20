import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/core/services/sound_manager.dart';
import 'package:quiz/data/models/game_data.dart' as data;
import 'package:quiz/data/models/question.dart';
import 'package:quiz/domain/providers/game_provider.dart';
import 'package:quiz/domain/providers/quest_provider.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int id;

  const GameScreen({super.key, required this.id});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _selectedAnswer = -1;
  bool _answered = false;
  bool _isFinished = false;

  int _timeLeft = 30;
  Timer? _timer;
  final bool _timerEnabled = true;

  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final gameData = data.GameData();
    _questions = gameData.getQuestions(widget.id);
    _questions.shuffle();
    if (_questions.length > 10) {
      _questions = _questions.sublist(0, 10);
    }
    for (final q in _questions) {
      q.shuffleAnswers();
    }
    _startTimer();
  }

  void _startTimer() {
    if (!_timerEnabled) return;
    _timeLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        _onTimeUp();
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _onTimeUp() {
    _timer?.cancel();
    _selectedAnswer = -1;
    _answered = true;
    _soundManager.play(SoundType.wrong);
    Future.delayed(const Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    _timer?.cancel();
    setState(() {
      _selectedAnswer = index;
      _answered = true;

      if (index == _questions[_currentIndex].correctIndex) {
        _correctAnswers++;
        _soundManager.play(SoundType.correct);
      } else {
        _soundManager.play(SoundType.wrong);
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = -1;
        _answered = false;
      });
      _startTimer();
    } else {
      _finishGame();
    }
  }

  Future<void> _finishGame() async {
    _timer?.cancel();
    setState(() => _isFinished = true);

    final isPerfect = _correctAnswers == _questions.length;

    await ref.read(gameProvider.notifier).finishGame(
          correctAnswers: _correctAnswers,
          totalAnswers: _questions.length,
          isPerfect: isPerfect,
          categoryId: widget.id,
        );

    final questReward = await ref.read(questProvider.notifier).updateProgress(
          gamesPlayed: 1,
          correctAnswers: _correctAnswers,
          perfectGames: isPerfect ? 1 : 0,
          points: _correctAnswers * 10,
        );

    if (isPerfect) {
      _soundManager.play(SoundType.levelUp);
    }

    final totalPoints = ref.read(gameProvider).value?.progress.totalPoints ?? 0;
    if (!mounted) return;
    _showResultDialog(totalPoints, questReward);
  }

  void _showResultDialog(int totalPoints, int questReward) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPerfect = _correctAnswers == _questions.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPerfect ? '🎉 Идеально!' : '🏆 Игра окончена!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Правильных ответов: $_correctAnswers / ${_questions.length}',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Очки: +${_correctAnswers * 10}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF7ED421)),
            ),
            if (isPerfect) ...[
              const SizedBox(height: 4),
              const Text(
                'Бонус за идеальную игру: +50',
                style: TextStyle(fontSize: 16, color: Color(0xFF7ED421)),
              ),
            ],
            if (questReward > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Награда за квесты: +$questReward',
                style: const TextStyle(fontSize: 16, color: Colors.amber),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7ED421),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('На главную', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.grey[100]!;

    if (_isFinished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          onPressed: () {
            _timer?.cancel();
            context.pop();
          },
          icon: Icon(Icons.close, color: textColor),
        ),
        title: Text(
          '${_currentIndex + 1} / ${_questions.length}',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        actions: [
          if (_timerEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '$_timeLeft сек',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _timeLeft <= 5 ? Colors.red : textColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: cardColor,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF7ED421)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                question.question,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: question.answers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AnswerButton(
                        text: question.answers[index],
                        index: index,
                        isSelected: _selectedAnswer == index,
                        isCorrect: index == question.correctIndex,
                        answered: _answered,
                        isDark: isDark,
                        onTap: () => _selectAnswer(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool answered;
  final bool isDark;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.answered,
    required this.isDark,
    required this.onTap,
  });

  Color _backgroundColor() {
    if (!answered) {
      return isDark ? const Color(0xFF1A1A2E) : Colors.grey[100]!;
    }
    if (isSelected && isCorrect) return const Color(0xFF7ED421);
    if (isSelected && !isCorrect) return Colors.red;
    if (isCorrect) return const Color(0xFF7ED421).withValues(alpha: 0.3);
    return isDark ? const Color(0xFF1A1A2E) : Colors.grey[100]!;
  }

  Color _textColor() {
    if (!answered) return isDark ? Colors.white : Colors.black87;
    if ((isSelected && isCorrect) || (isCorrect && answered)) {
      return Colors.white;
    }
    if (isSelected && !isCorrect) return Colors.white;
    return isDark ? Colors.grey : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !answered
                ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                : _textColor(),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _textColor()),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: _textColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: _textColor()),
              ),
            ),
            if (answered && isCorrect)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
            if (answered && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
