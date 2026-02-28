import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyBonusProvider extends ChangeNotifier {
  static const String _lastLoginKey = 'last_login_date';
  static const String _streakKey = 'login_streak';
  static const String _totalBonusKey = 'total_bonus_received';

  int _currentStreak = 0;
  int _totalBonusReceived = 0;
  bool _canClaimBonus = false;
  bool _isInitialized = false;

  int get currentStreak => _currentStreak;
  int get totalBonusReceived => _totalBonusReceived;
  bool get canClaimBonus => _canClaimBonus;
  bool get isInitialized => _isInitialized;

  // Награда за каждый день серии
  int get todayBonus => (_currentStreak + 1) * 10;

  // Бонус за максимальную серию
  int get streakBonus {
    if (_currentStreak >= 30) return 500;
    if (_currentStreak >= 14) return 200;
    if (_currentStreak >= 7) return 100;
    if (_currentStreak >= 3) return 50;
    return 0;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginStr = prefs.getString(_lastLoginKey);
      final today = _getTodayDateString();

      _currentStreak = prefs.getInt(_streakKey) ?? 0;
      _totalBonusReceived = prefs.getInt(_totalBonusKey) ?? 0;

      if (lastLoginStr == null) {
        // Первый вход
        _canClaimBonus = true;
      } else if (lastLoginStr == today) {
        // Уже получал бонус сегодня
        _canClaimBonus = false;
      } else {
        // Проверяем, был ли вход вчера
        final yesterday = _getYesterdayDateString();
        if (lastLoginStr == yesterday) {
          // Серия продолжается
          _canClaimBonus = true;
        } else {
          // Серия сломана
          _currentStreak = 0;
          _canClaimBonus = true;
        }
      }
    } catch (e) {
      _canClaimBonus = true;
      _currentStreak = 0;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<int> claimBonus() async {
    if (!_canClaimBonus) return 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayDateString();

      // Обновляем серию
      _currentStreak++;
      
      // Начисляем бонус
      int bonus = todayBonus;
      
      // Добавляем бонус за серию
      if (streakBonus > 0 && (_currentStreak == 3 || _currentStreak == 7 || _currentStreak == 14 || _currentStreak == 30)) {
        bonus += streakBonus;
      }

      _totalBonusReceived += bonus;

      // Сохраняем
      await prefs.setString(_lastLoginKey, today);
      await prefs.setInt(_streakKey, _currentStreak);
      await prefs.setInt(_totalBonusKey, _totalBonusReceived);

      _canClaimBonus = false;
      notifyListeners();

      return bonus;
    } catch (e) {
      debugPrint('Error claiming bonus: $e');
      return 0;
    }
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getYesterdayDateString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  // Получить название серии
  String get streakTitle {
    if (_currentStreak >= 30) return "Легенда 💎";
    if (_currentStreak >= 14) return "Мастер ⭐";
    if (_currentStreak >= 7) return "Фанат 🔥";
    if (_currentStreak >= 3) return "Постоялец 👤";
    return "Новичок 🌱";
  }

  // Сброс (для тестирования)
  Future<void> reset() async {
    _currentStreak = 0;
    _canClaimBonus = true;
    _totalBonusReceived = 0;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLoginKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_totalBonusKey);
    
    notifyListeners();
  }
}
