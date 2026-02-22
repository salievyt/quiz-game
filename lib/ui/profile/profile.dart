import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/ui/profile/settings.dart';
import 'package:quiz/ui/providers/game_provider.dart';
import 'package:quiz/ui/profile/achievements_screen.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final progress = gameProvider.progress;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FB);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    // Форматирование очков
    String formatPoints(int points) {
      if (points >= 1000) {
        return '${(points / 1000).toStringAsFixed(1)}K';
      }
      return points.toString();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Профиль",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Settings(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            /// 👤 Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFF7ED421),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                // Индикатор уровня
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "LVL ${progress.level}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              "Игрок",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 5),

            // Прогресс до следующего уровня
            Column(
              children: [
                Text(
                  "${progress.totalPoints} очков",
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.levelProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF7ED421),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "До следующего уровня: ${progress.pointsForNextLevel - (progress.totalPoints % progress.pointsForNextLevel)} очков",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// 📊 Stats
            Row(
              children: [
                _StatCard(
                  title: "Игры", 
                  value: progress.gamesPlayed.toString(),
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                _StatCard(
                  title: "Очки", 
                  value: formatPoints(progress.totalPoints),
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                _StatCard(
                  title: "Точность", 
                  value: "${(progress.accuracy * 100).toStringAsFixed(0)}%",
                  cardColor: cardColor,
                  textColor: textColor,
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// 🏆 Achievements
            _SectionTitle(
              title: "Достижения", 
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // Показываем разблокированные ачивки
            _AchievementsPreview(
              unlockedCount: gameProvider.unlockedAchievements.length,
              totalCount: gameProvider.allAchievements.length,
              cardColor: cardColor,
              textColor: textColor,
              isDark: isDark,
            ),

            const SizedBox(height: 30),

            /// ⚙️ Actions
            _ActionButton(
              icon: Icons.emoji_events,
              text: "Все достижения",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                );
              },
              cardColor: cardColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.leaderboard,
              text: "Таблица лидеров",
              onTap: () {},
              cardColor: cardColor,
              textColor: textColor,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.logout,
              text: "Выйти",
              isDestructive: true,
              onTap: () {},
              cardColor: cardColor,
              textColor: textColor,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// 📊 Карточка статистики
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color cardColor;
  final Color textColor;

  const _StatCard({
    required this.title, 
    required this.value,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🏆 Заголовок секции
class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;
  final VoidCallback? onTap;

  const _SectionTitle({
    required this.title, 
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text("Смотреть все"),
          ),
      ],
    );
  }
}

// Предпросмотр ачивок
class _AchievementsPreview extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const _AchievementsPreview({
    required this.unlockedCount,
    required this.totalCount,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text("🏆", style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$unlockedCount / $totalCount разблокировано",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: totalCount > 0 ? unlockedCount / totalCount : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
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

// Кнопки действий
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color cardColor;
  final Color textColor;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : textColor,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isDestructive ? Colors.red : textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
      ),
    );
  }
}