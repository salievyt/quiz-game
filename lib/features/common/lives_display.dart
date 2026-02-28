import 'package:flutter/material.dart';
import 'package:quiz/core/utils/app_colors.dart';

class LivesDisplay extends StatelessWidget {
  final int lives;
  final int maxLives;
  final String timeLeft;

  const LivesDisplay({
    super.key,
    required this.lives,
    required this.maxLives,
    this.timeLeft = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('❤️ $lives/$maxLives', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          if (timeLeft.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(timeLeft, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
          ],
        ],
      ),
    );
  }
}
