import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz/ui/providers/game_provider.dart';
import 'package:quiz/ui/providers/quest_provider.dart';
import 'package:quiz/features/profile/presentation/pages/settings.dart';
import 'package:quiz/features/profile/presentation/pages/achievements_screen.dart';
import 'package:quiz/features/profile/presentation/pages/quests_screen.dart';
import 'package:quiz/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:quiz/features/chat/presentation/pages/user_chat_screen.dart';
import 'package:quiz/features/chat/presentation/pages/admin_chat_dashboard.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final authViewModel = context.watch<AuthViewModel>();
    final progress = gameProvider.progress;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF0F0F1A)
        : const Color(0xFFF4F6FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // App Bar Replacement
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Профиль",
                        style: GoogleFonts.sen(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      _GlassIconButton(
                        icon: Icons.settings_rounded,
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Settings()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// 👤 Avatar and Level
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7ED421), Color(0xFF4A90E2)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF7ED421,
                              ).withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: isDark
                              ? const Color(0xFF1A1A2E)
                              : Colors.white,
                          child: Text(
                            authViewModel.profile?.username
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                "U",
                            style: GoogleFonts.sen(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFD700,
                                ).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
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

                  const SizedBox(height: 20),

                  Text(
                    authViewModel.profile?.username ?? "Игрок",
                    style: GoogleFonts.sen(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Progress Bar
                  _GlassContainer(
                    isDark: isDark,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ваш Прогресс",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "${progress.totalPoints} pts",
                              style: const TextStyle(
                                color: Color(0xFF7ED421),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.levelProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7ED421),
                                    Color(0xFF4A90E2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "До LVL ${progress.level + 1} осталось ${progress.pointsForNextLevel - (progress.totalPoints % progress.pointsForNextLevel)} очков",
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      _CompactStatCard(
                        title: "Игры",
                        value: progress.gamesPlayed.toString(),
                        icon: Icons.sports_esports_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _CompactStatCard(
                        title: "Место",
                        value: "#12", // TODO: Fetch real rank if possible
                        icon: Icons.emoji_events_rounded,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _CompactStatCard(
                        title: "Точность",
                        value:
                            "${(progress.accuracy * 100).toStringAsFixed(0)}%",
                        icon: Icons.insights_rounded,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Actions
                  Column(
                    children: [
                      _ActionTile(
                        icon: Icons.assignment_rounded,
                        title: "Ежедневные квесты",
                        subtitle:
                            "${context.watch<QuestProvider>().completedCount} / ${context.watch<QuestProvider>().totalQuests} выполнено",
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuestsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.workspace_premium_rounded,
                        title: "Достижения",
                        subtitle:
                            "${gameProvider.unlockedAchievements.length} / ${gameProvider.allAchievements.length} открыто",
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AchievementsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      if (authViewModel.profile != null)
                        _ActionTile(
                          icon: Icons.support_agent_rounded,
                          title: authViewModel.profile!.isSupport
                              ? "Админ Панель"
                              : "Поддержка",
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => authViewModel.profile!.isSupport
                                    ? const AdminChatDashboard()
                                    : const UserChatScreen(),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.logout_rounded,
                        title: "Выйти",
                        isDark: isDark,
                        isDestructive: true,
                        onTap: () async {
                          await authViewModel.logout();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsets padding;

  const _GlassContainer({
    required this.child,
    required this.isDark,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
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
          child: child,
        ),
      ),
    );
  }
}

class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;

  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _GlassContainer(
        isDark: isDark,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF7ED421).withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.sen(
                fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isDark,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassContainer(
        isDark: isDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : const Color(0xFF7ED421))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF7ED421),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red
                          : (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
