import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends AsyncNotifier<Locale> {
  static const String _localeKey = 'locale_code';
  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];

  @override
  Future<Locale> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localeKey);
      if (code != null) {
        return Locale(code);
      }
    } catch (e) {
      // ignore
    }
    return const Locale('ru');
  }

  Future<void> setLocale(Locale locale) async {
    if (state.value == locale) return;
    state = AsyncData(locale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // ignore
    }
  }
}

final localeProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
