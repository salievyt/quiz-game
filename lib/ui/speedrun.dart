import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_progress_bar/progress_bar.dart';

import '../models/question.dart';
import 'ResultScreen.dart';

class Speedrun extends StatefulWidget {
  const Speedrun({super.key});

  @override
  State<Speedrun> createState() => _SpeedrunState();
}

class _SpeedrunState extends State<Speedrun> {
  int _timeLeft = 60;
  late Timer _timer;
  bool _isGameOver = false;
  late List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadRandomQuestion();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        _finishGame();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  final Random _random = Random();

  void _loadRandomQuestion() {
    setState(() {
      _currentIndex = _random.nextInt(_questions.length);
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
    if (_isGameOver) return;

    final question = _questions[_currentIndex];

    if (selectedIndex == question.correctIndex) {
      _score++;
    }

    _loadRandomQuestion();
  }

  void _showCupertinoExitDialog(BuildContext context) {
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

  void _showMaterialExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
          onPressed: () {
            if(Platform.isAndroid){
              _showMaterialExitDialog(context);
            }else if(Platform.isIOS){
              _showCupertinoExitDialog(context);
            }
          },
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
                    "$_timeLeft",
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
