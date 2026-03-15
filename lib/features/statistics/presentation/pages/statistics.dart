import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz/ui/providers/game_provider.dart';
import 'package:quiz/ui/providers/coins_provider.dart';
import 'package:quiz/ui/providers/lives_provider.dart';
import 'package:quiz/ui/providers/quest_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF0F0F1A)
        : const Color(0xFFF4F6FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    final gameProvider = context.watch<GameProvider>();
    final coinsProvider = context.watch<CoinsProvider>();
    final livesProvider = context.watch<LivesProvider>();
    final questProvider = context.watch<QuestProvider>();

    final progress = gameProvider.progress;
    final accuracy = progress.accuracy;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F0F1A), const Color(0xFF1A1A2E)]
                    : [const Color(0xFFF4F6FA), const Color(0xFFE0E5EC)],
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Статистика",
                          style: GoogleFonts.sen(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "Твои успехи за всю историю игры",
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _MainGlassStatsCard(
                      accuracy: accuracy,
                      totalPoints: progress.totalPoints,
                      isDark: isDark,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                    delegate: SliverChildListDelegate([
                      _CompactStatTile(
                        icon: Icons.sports_esports_rounded,
                        title: "Игр сыграно",
                        value: progress.gamesPlayed.toString(),
                        color: Colors.blue,
                        isDark: isDark,
                      ),
                      _CompactStatTile(
                        icon: Icons.local_fire_department_rounded,
                        title: "Лучшая серия",
                        value: progress.bestStreak.toString(),
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                      _CompactStatTile(
                        icon: Icons.monetization_on_rounded,
                        title: "Монет",
                        value: coinsProvider.formattedCoins,
                        color: const Color(0xFFFFD700),
                        isDark: isDark,
                      ),
                      _CompactStatTile(
                        icon: Icons.favorite_rounded,
                        title: "Жизни",
                        value:
                            "${livesProvider.lives}/${livesProvider.maxLives}",
                        color: Colors.red,
                        isDark: isDark,
                      ),
                      _CompactStatTile(
                        icon: Icons.assignment_rounded,
                        title: "Квесты",
                        value:
                            "${questProvider.completedCount}/${questProvider.totalQuests}",
                        color: Colors.purple,
                        isDark: isDark,
                      ),
                      _CompactStatTile(
                        icon: Icons.percent_rounded,
                        title: "Точность",
                        value: "${(accuracy * 100).toInt()}%",
                        color: Colors.green,
                        isDark: isDark,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainGlassStatsCard extends StatelessWidget {
  final double accuracy;
  final int totalPoints;
  final bool isDark;

  const _MainGlassStatsCard({
    required this.accuracy,
    required this.totalPoints,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6A5AE0).withValues(alpha: 0.8),
                const Color(0xFF9C6BFF).withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A5AE0).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ВСЕГО ОЧКОВ",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$totalPoints",
                style: GoogleFonts.sen(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Точность ${(accuracy * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Уровень ${totalPoints > 0 ? (totalPoints ~/ 100) + 1 : 1}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: accuracy,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactStatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _CompactStatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.sen(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
