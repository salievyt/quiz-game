import 'package:flutter/material.dart';
import 'dart:io';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool notificationsEnabled = true;
  bool darkMode = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Настройки",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [

          _sectionTitle("Аккаунт"),
          _settingsTile(
            icon: Icons.person,
            title: "Редактировать профиль",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.lock,
            title: "Сменить пароль",
            onTap: () {},
          ),

          const SizedBox(height: 25),

          _sectionTitle("Игровые настройки"),
          _switchTile(
            icon: Icons.volume_up,
            title: "Звук",
            value: soundEnabled,
            onChanged: (value) {
              setState(() => soundEnabled = value);
            },
          ),
          _switchTile(
            icon: Icons.vibration,
            title: "Вибрация",
            value: vibrationEnabled,
            onChanged: (value) {
              setState(() => vibrationEnabled = value);
            },
          ),

          const SizedBox(height: 25),

          _sectionTitle("Уведомления"),
          _switchTile(
            icon: Icons.notifications,
            title: "Push-уведомления",
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          const SizedBox(height: 25),

          _sectionTitle("Внешний вид"),
          _switchTile(
            icon: Icons.dark_mode,
            title: "Тёмная тема",
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
            },
          ),

          const SizedBox(height: 25),

          _sectionTitle("О приложении"),
          _settingsTile(
            icon: Icons.info_outline,
            title: "Версия 1.4.0",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.privacy_tip,
            title: "Политика конфиденциальности",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          _dangerButton(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        leading: Icon(icon, color: Colors.black),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        secondary: Icon(icon),
        title: Text(title),
        activeColor: const Color(0xFF7ED421),
      ),
    );
  }

  Widget _dangerButton() {
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
                onPressed: () {
                },
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
          color: Colors.red.withOpacity(0.1),
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