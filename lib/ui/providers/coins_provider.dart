import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinsProvider extends ChangeNotifier {
  static const String _coinsKey = 'player_coins';
  static const String _totalEarnedKey = 'total_coins_earned';

  int _coins = 0;
  int _totalEarned = 0;
  bool _isInitialized = false;

  int get coins => _coins;
  int get totalEarned => _totalEarned;
  bool get isInitialized => _isInitialized;

  // Получить форматрованные монеты (напр. 1.5K)
  String get formattedCoins {
    if (_coins >= 1000000) {
      return '${(_coins / 1000000).toStringAsFixed(1)}M';
    }
    if (_coins >= 1000) {
      return '${(_coins / 1000).toStringAsFixed(1)}K';
    }
    return _coins.toString();
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt(_coinsKey) ?? 0;
      _totalEarned = prefs.getInt(_totalEarnedKey) ?? 0;
    } catch (e) {
      _coins = 0;
      _totalEarned = 0;
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Добавить монеты (заработанные в игре)
  Future<void> addCoins(int amount) async {
    _coins += amount;
    _totalEarned += amount;
    await _saveCoins();
    notifyListeners();
  }

  // Добавить монеты из баллов (баллы / 10)
  int calculateCoinsFromPoints(int points) {
    return points ~/ 10;
  }

  // Потратить монеты (возвращает true если успешно)
  bool spendCoins(int amount) {
    if (_coins < amount) return false;
    _coins -= amount;
    _saveCoins();
    notifyListeners();
    return true;
  }

  // Проверка хватает ли монет
  bool canAfford(int amount) => _coins >= amount;

  Future<void> _saveCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_coinsKey, _coins);
      await prefs.setInt(_totalEarnedKey, _totalEarned);
    } catch (e) {
      debugPrint('Error saving coins: $e');
    }
  }

  // Сброс для тестирования
  Future<void> reset() async {
    _coins = 0;
    _totalEarned = 0;
    await _saveCoins();
    notifyListeners();
  }

  // Бесплатные монеты (для тестирования)
  Future<void> addFreeCoins() async {
    await addCoins(1000);
  }
}
