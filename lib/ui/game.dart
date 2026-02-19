import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/data/gamedata.dart';
import 'package:quiz/models/question.dart';
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
  }

  void _checkAnswer(int selectedIndex) {
    if (_questions.isEmpty) return;

    if (selectedIndex == _questions[_currentIndex].correctIndex) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Platform.isIOS ? _showCupertinoResult() : _showMaterialResult();
    }
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Игра окончена 🎉"),
        content: Text("Ваш результат: $_score из ${_questions.length}"),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Игра окончена 🎉"),
        content: Text("Ваш результат: $_score из ${_questions.length}"),
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

  @override
  Widget build(BuildContext context) {
    // 🔒 Защита от пустых данных
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "В этой категории пока нет вопросов",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    if (_currentIndex >= _questions.length) {
      return const Scaffold(
        body: Center(
          child: Text("Ошибка индекса"),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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

            const SizedBox(height: 40),

            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
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
}