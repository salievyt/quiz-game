import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_progress_bar/progress_bar.dart';

import 'package:quiz/data/models/question.dart';
import '../../data/gamedata.dart';
import '../utils/ResultScreen.dart';

class Speedrun extends StatefulWidget {
  const Speedrun({super.key});

  @override
  State<Speedrun> createState() => _SpeedrunState();
}

class _SpeedrunState extends State<Speedrun> {
  int _timeLeft = 0;
  int _timeBack = 60;
  late Timer _timer;
  bool _isGameOver = false;

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  void _loadQuestions() {
    // Берём ВСЕ вопросы из GameData
    _questions = GameData.getQuiz(9);
    _questions.shuffle();

    // Перемешиваем ответы
    for (var q in _questions) {
      q.shuffleAnswers();
    }

    if (_questions.isNotEmpty) {
      _currentIndex = _random.nextInt(_questions.length);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 60) {
        _finishGame();
      } else {
        setState(() {
          _timeLeft++;
          _timeBack--;
        });
      }
    });
  }

  void _loadRandomQuestion() {
    if (_questions.isEmpty) return;

    setState(() {
      int newIndex;
      do {
        newIndex = _random.nextInt(_questions.length);
      } while (newIndex == _currentIndex);

      _currentIndex = newIndex;
    });
  }

  void _finishGame() {
    _timer.cancel();
    _isGameOver = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(score: _score),
      ),
    );
  }

  void _checkAnswer(int selectedIndex) {
    if (_isGameOver || _questions.isEmpty) return;

    final question = _questions[_currentIndex];

    if (selectedIndex == question.correctIndex) {
      _score++;
    }

    _loadRandomQuestion();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
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
          );
        }

        return AlertDialog(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Нет вопросов"),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F9FB),
        title: const Text("Speedrun"),
        centerTitle: true,
        leading: IconButton(
          onPressed: _showExitDialog,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            /// Таймер
            Row(
              children: [
                Expanded(
                  child: HorizontalProgressBar(
                    maxValue: 60,
                    currentPosition: _timeLeft.toDouble(),
                    progressColor: const Color(0xFF7ED421),
                    thumbColor: const Color(0xFF7ED421),
                    trackHeight: 10,
                    bufferedPosition: 60,
                    bufferedColor: const Color(0xFFEBEBEB),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF7ED421),
                  child: Text(
                    "$_timeBack",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// Вопрос
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            /// Ответы
            Column(
              children: List.generate(
                question.answers.length,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: () => _checkAnswer(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7ED421),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

            Text(
              "Очки: $_score",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}