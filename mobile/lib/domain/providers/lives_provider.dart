import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivesNotifier extends AsyncNotifier<LivesData> {
  static const String _livesKey = 'player_lives';
  static const String _lastLifeKey = 'last_life_time';
  static const int maxLives = 5;
  static const int refillMinutes = 30;

  @override
  Future<LivesData> build() async {
    int lives = maxLives;

    try {
      final prefs = await SharedPreferences.getInstance();
      lives = prefs.getInt(_livesKey) ?? maxLives;
      final lastLifeStr = prefs.getString(_lastLifeKey);

      if (lastLifeStr != null && lives < maxLives) {
        final lastLife = DateTime.tryParse(lastLifeStr);
        if (lastLife != null) {
          final elapsed = DateTime.now().difference(lastLife);
          final restored = elapsed.inMinutes ~/ refillMinutes;
          if (restored > 0) {
            lives = (lives + restored).clamp(0, maxLives);
          }
        }
      }
    } catch (e) {
      lives = maxLives;
    }

    return LivesData(lives: lives);
  }

  Future<bool> useLife() async {
    final current = state.value;
    if (current == null || current.lives <= 0) return false;

    final newLives = current.lives - 1;
    state = AsyncData(current.copyWith(lives: newLives));
    await _save(newLives);
    return true;
  }

  Future<void> addLife([int count = 1]) async {
    final current = state.value;
    if (current == null) return;

    final newLives = (current.lives + count).clamp(0, maxLives);
    state = AsyncData(current.copyWith(lives: newLives));
    await _save(newLives);
  }

  Future<void> _save(int lives) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_livesKey, lives);
      await prefs.setString(_lastLifeKey, DateTime.now().toIso8601String());
    } catch (e) {
      // ignore
    }
  }
}

class LivesData {
  final int lives;

  const LivesData({required this.lives});

  bool get isFull => lives >= LivesNotifier.maxLives;

  LivesData copyWith({int? lives}) {
    return LivesData(lives: lives ?? this.lives);
  }
}

final livesProvider =
    AsyncNotifierProvider<LivesNotifier, LivesData>(LivesNotifier.new);
