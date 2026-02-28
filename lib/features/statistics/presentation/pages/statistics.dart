import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/ui/providers/game_provider.dart';
import 'package:quiz/ui/providers/coins_provider.dart';
import 'package:quiz/ui/providers/lives_provider.dart';
import 'package:quiz/ui/providers/quest_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FB);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final gameProvider = context.watch<GameProvider>();
    final coinsProvider = context.watch<CoinsProvider>();
    final livesProvider = context.watch<LivesProvider>();
    final questProvider = context.watch<QuestProvider>();
    
    final progress = gameProvider.progress;
    final accuracy = progress.accuracy;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          "Статистика",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _MainStatsCard(
              bestScore: progress.bestStreak * 10,
              accuracy: accuracy,
              totalPoints: progress.totalPoints,
              cardColor: cardColor,
            ),
            const SizedBox(height: 20),
            _StatCard(
              icon: Icons.sports_esports_rounded,
              title: "Игр сыграно",
              value: progress.gamesPlayed.toString(),
              color: Colors.blue,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.local_fire_department_rounded,
              title: "Лучшая серия",
              value: progress.bestStreak.toString(),
              color: Colors.orange,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.percent_rounded,
              title: "Точность",
              value: "${(accuracy * 100).toInt()}%",
              color: Colors.green,
              progress: accuracy,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.monetization_on_rounded,
              title: "Монет",
              value: coinsProvider.formattedCoins,
              color: const Color(0xFFFFD700),
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.favorite_rounded,
              title: "Жизни",
              value: "${livesProvider.lives}/${livesProvider.maxLives}",
              color: Colors.red,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.emoji_events_rounded,
              title: "Квестов сегодня",
              value: "${questProvider.completedCount}/${questProvider.totalQuests}",
              color: Colors.purple,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _MainStatsCard extends StatelessWidget {
  final int bestScore;
  final double accuracy;
  final int totalPoints;
  final Color cardColor;

  const _MainStatsCard({
    required this.bestScore,
    required this.accuracy,
    required this.totalPoints,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF9C6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Всего очков", style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text("Уровень ${totalPoints > 0 ? (totalPoints ~/ 100) + 1 : 1}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text("$totalPoints", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: accuracy, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 6),
          ),
          const SizedBox(height: 8),
          Text("Точность ${(accuracy * 100).toInt()}%", style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final double? progress;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.progress,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: TextStyle(fontSize: 16, color: textColor))),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}