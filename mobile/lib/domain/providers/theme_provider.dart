import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/core/theme/app_theme.dart';

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  static const String _themeKey = 'dark_mode';

  @override
  Future<ThemeMode> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      return isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      return ThemeMode.light;
    }
  }

  bool get isDarkMode => state.value == ThemeMode.dark;

  static ThemeData get lightTheme => AppTheme.lightTheme;
  static ThemeData get darkTheme => AppTheme.darkTheme;

  Future<void> toggleTheme() async {
    final current = state.value ?? ThemeMode.light;
    final next = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = AsyncData(next);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, next == ThemeMode.dark);
    } catch (e) {
      // ignore
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    final next = isDark ? ThemeMode.dark : ThemeMode.light;
    state = AsyncData(next);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      // ignore
    }
  }
}

final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
