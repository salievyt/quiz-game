import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivesProvider extends ChangeNotifier {
  static const String _livesKey = 'player_lives';
  static const String _maxLivesKey = 'max_lives';
  static const String _lastRestoreKey = 'last_lives_restore';

  static const int _maxLives = 5;
  static const Duration _restoreTime = Duration(hours: 1);

  int _lives = 5;
  DateTime? _lastRestoreTime;
  bool _isInitialized = false;

  int get lives => _lives;
  int get maxLives => _maxLives;
  bool get canPlay => _lives > 0;
  bool get isInitialized => _isInitialized;

  // Сколько жизней нужно для макс.
  int get livesToMax => _maxLives - _lives;

  // Прогресс восстановления (0.0 - 1.0)
  double get restoreProgress {
    if (_lives >= _maxLives) return 1.0;
    if (_lastRestoreTime == null) return 0.0;
    
    final timePassed = DateTime.now().difference(_lastRestoreTime!);
    final progress = timePassed.inMinutes / _restoreTime.inMinutes;
    return progress.clamp(0.0, 1.0);
  }

  // Время до следующей жизни
  String get timeToNextLife {
    if (_lives >= _maxLives) return "Полные";
    if (_lastRestoreTime == null) return "1 час";
    
    final timePassed = DateTime.now().difference(_lastRestoreTime!);
    final minutesLeft = _restoreTime.inMinutes - timePassed.inMinutes;
    
    if (minutesLeft <= 0) return "Скоро";
    if (minutesLeft < 60) return "$minutesLeft мин";
    return "${(minutesLeft / 60).ceil()} час";
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      _lives = prefs.getInt(_livesKey) ?? _maxLives;
      
      final lastRestoreStr = prefs.getString(_lastRestoreKey);
      if (lastRestoreStr != null) {
        _lastRestoreTime = DateTime.tryParse(lastRestoreStr);
      }

      // Проверяем нужно ли восстановить жизни
      await _checkAndRestoreLives();
    } catch (e) {
      _lives = _maxLives;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _checkAndRestoreLives() async {
    if (_lives >= _maxLives) return;
    if (_lastRestoreTime == null) {
      _lives = 1;
      _lastRestoreTime = DateTime.now();
      await _saveLives();
      return;
    }

    final timePassed = DateTime.now().difference(_lastRestoreTime!);
    final livesToRestore = timePassed.inMinutes ~/ _restoreTime.inMinutes;

    if (livesToRestore > 0) {
      _lives = (_lives + livesToRestore).clamp(0, _maxLives);
      
      if (_lives < _maxLives) {
        _lastRestoreTime = DateTime.now();
      }
      
      await _saveLives();
    }
  }

  bool useLife() {
    if (_lives <= 0) return false;
    _lives--;
    _saveLives();
    notifyListeners();
    return true;
  }

  Future<void> addLives(int amount) async {
    _lives = (_lives + amount).clamp(0, _maxLives);
    await _saveLives();
    notifyListeners();
  }

  Future<void> buyLives(int cost) async {
    // Это вызывается из CoinsProvider
    if (_lives < _maxLives) {
      _lives++;
      await _saveLives();
      notifyListeners();
    }
  }

  Future<void> _saveLives() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_livesKey, _lives);
      await prefs.setInt(_maxLivesKey, _maxLives);
      if (_lastRestoreTime != null) {
        await prefs.setString(_lastRestoreKey, _lastRestoreTime!.toIso8601String());
      }
    } catch (e) {
      debugPrint('Error saving lives: $e');
    }
  }

  // Сброс для тестирования
  Future<void> reset() async {
    _lives = _maxLives;
    _lastRestoreTime = null;
    await _saveLives();
    notifyListeners();
  }
}
