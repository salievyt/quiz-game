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
    _questions = GameData.getQuiz(widget.ID);
    _questions.shuffle();

    for (var q in _questions) {
      q.shuffleAnswers();
    }
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Выйти из игры?"),
          content: Text("Ваш прогресс будет потерян."),
          actions: [
            TextButton(
              child: Text("Нет"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Да"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _checkAnswer(int selectedIndex) {
    if (selectedIndex ==
        _questions[_currentIndex].correctIndex) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
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
                _currentIndex = 0;
                _score = 0;
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
    final question = _questions[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Игра"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _showAlertDialog(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [

            /// Progress
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
                    bufferedColor: const Color(0xFFEBEBEB), onChanged: (double value) {  },
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

            /// Question
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            /// Answers
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