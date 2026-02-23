import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/models/achievement.dart';
import 'package:quiz/ui/providers/game_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FB);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    // Группируем ачивки по категориям
    final groupedAchievements = <AchievementType, List<Achievement>>{};
    for (final achievement in Achievement.all) {
      groupedAchievements.putIfAbsent(achievement.type, () => []).add(achievement);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Достижения",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Общий прогресс
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text("🏆", style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${gameProvider.unlockedAchievements.length} / ${Achievement.all.length}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "достижений разблокировано",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: groupedAchievements.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _getTypeName(entry.key),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    ...entry.value.map((achievement) {
                      final isUnlocked = gameProvider.isAchievementUnlocked(achievement.id);
                      final progress = gameProvider.getAchievementProgress(achievement);
                      
                      return _AchievementCard(
                        achievement: achievement,
                        isUnlocked: isUnlocked,
                        progress: progress,
                        cardColor: cardColor,
                        textColor: textColor,
                        isDark: isDark,
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeName(AchievementType type) {
    switch (type) {
      case AchievementType.gamesPlayed:
        return "🎮 Игры";
      case AchievementType.correctAnswers:
        return "✅ Правильные ответы";
      case AchievementType.streak:
        return "🔥 Серии побед";
      case AchievementType.perfectGame:
        return "💯 Идеальные игры";
      case AchievementType.points:
        return "⭐ Очки";
      case AchievementType.level:
        return "📈 Уровни";
      case AchievementType.categoryMaster:
        return "👑 Категории";
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: achievement.isRare && isUnlocked
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : null,
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
          // Иконка
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? (achievement.isRare
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF7ED421))
                  : (isDark ? Colors.grey[800] : Colors.grey[300]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isUnlocked
                  ? Text(achievement.icon, style: const TextStyle(fontSize: 24))
                  : const Icon(Icons.lock, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? textColor : textColor.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        achievement.isRare 
                            ? const Color(0xFFFFD700) 
                            : const Color(0xFF7ED421),
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Статус
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 20),
            ),
        ],
      ),
    );
  }
}
