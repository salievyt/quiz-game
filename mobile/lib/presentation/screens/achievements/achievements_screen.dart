import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/domain/providers/game_provider.dart';
import 'package:quiz/domain/entities/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF4F6FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;

    final gameData = ref.watch(gameProvider).value;
    final achievements = Achievement.all;
    final unlockedCount = gameData?.unlockedAchievements.length ?? 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Достижения',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Открыто: $unlockedCount / ${achievements.length}',
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = achievements[index];
                    final notifier = ref.read(gameProvider.notifier);
                    final isUnlocked =
                        notifier.isAchievementUnlocked(achievement.id);
                    final progressValue =
                        notifier.getAchievementProgress(achievement);

                    return _AchievementCard(
                      achievement: achievement,
                      isUnlocked: isUnlocked,
                      progress: progressValue,
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    );
                  },
                  childCount: achievements.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? cardColor : cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: isUnlocked && achievement.isRare
            ? Border.all(color: Colors.amber, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFF7ED421).withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 24,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked ? textColor : secondaryTextColor,
                        ),
                      ),
                    ),
                    if (achievement.isRare && isUnlocked)
                      const Text('⭐', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(fontSize: 13, color: secondaryTextColor),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF7ED421)),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUnlocked) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: Color(0xFF7ED421), size: 22),
          ],
        ],
      ),
    );
  }
}
