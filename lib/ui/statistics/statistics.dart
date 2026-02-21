import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final int gamesPlayed = 42;
    final int bestScore = 18;
    final int bestStreak = 7;
    final double accuracy = 0.82;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Статистика"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            /// 🔥 Главная карточка
            _MainStatsCard(
              bestScore: bestScore,
              accuracy: accuracy,
            ),

            const SizedBox(height: 20),

            /// 📈 Остальная статистика
            _StatCard(
              icon: Icons.sports_esports_rounded,
              title: "Games Played",
              value: gamesPlayed.toString(),
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _StatCard(
              icon: Icons.local_fire_department_rounded,
              title: "Best Streak",
              value: bestStreak.toString(),
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _StatCard(
              icon: Icons.percent_rounded,
              title: "Accuracy",
              value: "${(accuracy * 100).toInt()}%",
              color: Colors.green,
              progress: accuracy,
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

  const _MainStatsCard({
    required this.bestScore,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A5AE0),
            Color(0xFF9C6BFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Best Score",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$bestScore",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: accuracy,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "Accuracy ${(accuracy * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.white70,
            ),
          )
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

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height : 12),
            LinearProgressIndicator(value: progress),
          ]
        ],
      ),
    );
  }
}