import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/domain/providers/theme_provider.dart';
import 'package:quiz/domain/providers/game_provider.dart';
import 'package:quiz/core/services/sound_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF4F6FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final soundManager = SoundManager();

    final themeMode = ref.watch(themeProvider).value ?? ThemeMode.light;
    final gameData = ref.watch(gameProvider).value;
    final progress = gameData?.progress;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Настройки',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),

              // Player Stats
              if (progress != null)
                _Section(
                  title: 'Статистика',
                  cardColor: cardColor,
                  children: [
                    _StatRow(
                      label: 'Уровень',
                      value: '${progress.level}',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _StatRow(
                      label: 'Очки',
                      value: '${progress.totalPoints}',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _StatRow(
                      label: 'Игры',
                      value: '${progress.gamesPlayed}',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _StatRow(
                      label: 'Точность',
                      value:
                          '${(progress.accuracy * 100).toStringAsFixed(0)}%',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _StatRow(
                      label: 'Лучшая серия',
                      value: '${progress.bestStreak}',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Theme
              _Section(
                title: 'Внешний вид',
                cardColor: cardColor,
                children: [
                  _SwitchRow(
                    title: 'Тёмная тема',
                    value: themeMode == ThemeMode.dark,
                    onChanged: (_) =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sound
              _Section(
                title: 'Звук',
                cardColor: cardColor,
                children: [
                  _SwitchRow(
                    title: 'Звуковые эффекты',
                    value: soundManager.soundEnabled,
                    onChanged: (v) {
                      setState(() => soundManager.setSoundEnabled(v));
                    },
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  _SwitchRow(
                    title: 'Вибрация',
                    value: soundManager.vibrationEnabled,
                    onChanged: (v) {
                      setState(() => soundManager.setVibrationEnabled(v));
                    },
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Danger Zone
              _Section(
                title: 'Данные',
                cardColor: cardColor,
                children: [
                  _ActionRow(
                    title: 'Сбросить прогресс',
                    icon: Icons.delete_outline,
                    iconColor: Colors.red,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    onTap: () => _showResetDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Version
              Center(
                child: Text(
                  'Quizzy v2.0.0',
                  style: TextStyle(color: secondaryTextColor, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        title: Text(
          'Сбросить прогресс?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Все ваши достижения и статистика будут удалены.',
          style: TextStyle(
              color: isDark ? Colors.grey[400]! : Colors.grey[600]!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(gameProvider.notifier).resetProgress();
              Navigator.of(context).pop();
            },
            child:
                const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Color cardColor;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.cardColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color secondaryTextColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 15, color: secondaryTextColor)),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;
  final Color secondaryTextColor;

  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: textColor)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF7ED421),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;

  const _ActionRow({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 15, color: iconColor)),
          ],
        ),
      ),
    );
  }
}
