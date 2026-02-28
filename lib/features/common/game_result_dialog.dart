import 'package:flutter/material.dart';
import 'package:quiz/core/utils/app_colors.dart';

class GameResultDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int points;
  final int coins;
  final int? questReward;
  final bool isPerfect;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const GameResultDialog({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.points,
    required this.coins,
    this.questReward,
    required this.isPerfect,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.text(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isPerfect ? "Идеально! 🎉" : "Игра окончена 🎉",
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Результат: $score из $totalQuestions", style: TextStyle(fontSize: 16, color: textColor)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ResultBadge(icon: "⭐", value: "+$points", label: "очков"),
              const SizedBox(width: 12),
              _ResultBadge(icon: "🪙", value: "+$coins", label: "монет"),
            ],
          ),
          if (questReward != null && questReward! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: Text("🎁 +$questReward за квесты!", style: const TextStyle(color: Color(0xFFFFD700))),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: onPlayAgain, child: const Text("Играть снова")),
        TextButton(onPressed: onExit, child: const Text("Выйти")),
      ],
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _ResultBadge({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF7ED421).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7ED421))),
          ]),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
