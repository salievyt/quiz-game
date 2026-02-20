import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ResultScreen extends StatelessWidget {
  final int score;

  const ResultScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Время вышло!",
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 20),
            Text(
              "Твой результат: $score",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Играть снова"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7ED421),
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}