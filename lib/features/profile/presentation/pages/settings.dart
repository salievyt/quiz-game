import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/ui/providers/theme_provider.dart';
import 'package:quiz/ui/services/sound_manager.dart';
import 'package:quiz/core/providers/locale_provider.dart';
import 'package:quiz/features/profile/presentation/pages/language_settings_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SoundManager _soundManager = SoundManager();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _soundEnabled = _soundManager.soundEnabled;
    _vibrationEnabled = _soundManager.vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FB);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Настройки",
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [

          _sectionTitle("Аккаунт", textColor),
          _settingsTile(
            icon: Icons.person,
            title: "Редактировать профиль",
            onTap: () {},
            cardColor: cardColor,
            textColor: textColor,
          ),
          _settingsTile(
            icon: Icons.lock,
            title: "Сменить пароль",
            onTap: () {},
            cardColor: cardColor,
            textColor: textColor,
          ),

          const SizedBox(height: 25),

          _sectionTitle("Игровые настройки", textColor),
          _switchTile(
            icon: Icons.volume_up,
            title: "Звук",
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _soundManager.setSoundEnabled(value);
            },
            cardColor: cardColor,
            textColor: textColor,
          ),
          _switchTile(
            icon: Icons.vibration,
            title: "Вибрация",
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
              _soundManager.setVibrationEnabled(value);
              if (value) {
                _soundManager.play(SoundType.click);
              }
            },
            cardColor: cardColor,
            textColor: textColor,
          ),

          const SizedBox(height: 25),

          _sectionTitle("Уведомления", textColor),
          _switchTile(
            icon: Icons.notifications,
            title: "Push-уведомления",
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            cardColor: cardColor,
            textColor: textColor,
          ),

          const SizedBox(height: 25),

          _sectionTitle("Внешний вид", textColor),
          _switchTile(
            icon: Icons.dark_mode,
            title: "Тёмная тема",
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
              _soundManager.play(SoundType.click);
            },
            cardColor: cardColor,
            textColor: textColor,
          ),
          _settingsTile(
            icon: Icons.language,
            title: "Язык",
            subtitle: context.watch<LocaleProvider>().getLocaleName(
              context.watch<LocaleProvider>().locale.languageCode
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()),
              );
            },
            cardColor: cardColor,
            textColor: textColor,
          ),

          const SizedBox(height: 25),

          _sectionTitle("О приложении", textColor),
          _settingsTile(
            icon: Icons.info_outline,
            title: "Версия 2.0.0",
            onTap: () {},
            cardColor: cardColor,
            textColor: textColor,
          ),
          _settingsTile(
            icon: Icons.privacy_tip,
            title: "Политика конфиденциальности",
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Политика конфиденциальности"),
                  content: const Text("Вы принимаете условия политики конфиденциальности"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Отмена"),
                    ),
                  ]
                )
              );
            },
            cardColor: cardColor,
            textColor: textColor,
          ),

          const SizedBox(height: 30),

          _dangerButton(cardColor),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 12)) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        activeColor: const Color(0xFF7ED421),
      ),
    );
  }

  Widget _dangerButton(Color cardColor) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Выйти из аккаунта?"),
            content: const Text("Вы уверены, что хотите выйти?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Отмена"),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Выйти",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            "Выйти из аккаунта",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}