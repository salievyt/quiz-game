import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum SoundType {
  correct,
  wrong,
  achievement,
  levelUp,
  click,
  gameOver,
}

enum MusicType {
  game,
  relax,
}

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) stopMusic();
  }

  bool _musicEnabled = true;
  bool _isPlayingMusic = false;
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool get musicEnabled => _musicEnabled;
  bool get isPlayingMusic => _isPlayingMusic;

  // Фоновая музыка
  Future<void> playMusic(MusicType type) async {
    if (!_musicEnabled || _isPlayingMusic) return;
    try {
      _isPlayingMusic = true;
      await _musicPlayer.setVolume(0.3);
      // Для реальной музыки добавьте аудиофайл в assets
    } catch (_) { _isPlayingMusic = false; }
  }

  Future<void> stopMusic() async {
    if (!_isPlayingMusic) return;
    try { await _musicPlayer.stop(); _isPlayingMusic = false; } catch (_) {}
  }

  Future<void> pauseMusic() async {
    if (!_isPlayingMusic) return;
    try { await _musicPlayer.pause(); } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!_isPlayingMusic || !_musicEnabled) return;
    try { await _musicPlayer.resume(); } catch (_) {}
  }

  // Используем системные звуки вместо аудиофайлов
  Future<void> play(SoundType type) async {
    if (!_soundEnabled) return;

    try {
      // Используем системные звуки iOS/Android через HapticFeedback
      switch (type) {
        case SoundType.correct:
          await HapticFeedback.lightImpact();
          await _playSystemSound('correct');
          break;
        case SoundType.wrong:
          await HapticFeedback.heavyImpact();
          await _playSystemSound('wrong');
          break;
        case SoundType.achievement:
          await HapticFeedback.mediumImpact();
          await _playSystemSound('achievement');
          break;
        case SoundType.levelUp:
          await HapticFeedback.mediumImpact();
          await _playSystemSound('levelup');
          break;
        case SoundType.click:
          await HapticFeedback.selectionClick();
          break;
        case SoundType.gameOver:
          await HapticFeedback.heavyImpact();
          await _playSystemSound('gameover');
          break;
      }
    } catch (_) {
      // Игнорируем ошибки
    }
  }

  Future<void> _playSystemSound(String type) async {
    // Воспроизводим вибрацию вместо звуковых файлов
    // Это работает на всех устройствах без необходимости добавлять аудиофайлы
    
    if (_vibrationEnabled) {
      switch (type) {
        case 'correct':
          await HapticFeedback.lightImpact();
          break;
        case 'wrong':
          await HapticFeedback.heavyImpact();
          break;
        case 'achievement':
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          break;
        case 'levelup':
          for (int i = 0; i < 3; i++) {
            await HapticFeedback.mediumImpact();
            await Future.delayed(const Duration(milliseconds: 150));
          }
          break;
        case 'gameover':
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 200));
          await HapticFeedback.mediumImpact();
          break;
      }
    }
  }

  void dispose() {
    _player.dispose();
    _effectsPlayer.dispose();
    _musicPlayer.dispose();
  }
}
