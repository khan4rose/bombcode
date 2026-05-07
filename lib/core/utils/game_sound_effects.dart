import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameSoundEffect { keypad, delete, submit, success, failure }

class GameSoundEffects {
  GameSoundEffects._();

  static final instance = GameSoundEffects._();
  static const soundVolumeKey = 'boomcode.settings.sound_volume';
  static const defaultSoundVolume = 0.7;

  double? _cachedSoundVolume;

  Future<double> loadSoundVolume() async {
    if (_cachedSoundVolume case final cached?) {
      return cached;
    }
    final prefs = await SharedPreferences.getInstance();
    final volume = prefs.getDouble(soundVolumeKey) ?? defaultSoundVolume;
    _cachedSoundVolume = _normalizeVolume(volume);
    return _cachedSoundVolume!;
  }

  Future<void> saveSoundVolume(double value) async {
    final volume = _normalizeVolume(value);
    _cachedSoundVolume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(soundVolumeKey, volume);
  }

  Future<void> playKeypad() => _play(GameSoundEffect.keypad);
  Future<void> playDelete() => _play(GameSoundEffect.delete);
  Future<void> playSubmit() => _play(GameSoundEffect.submit);
  Future<void> playSuccess() => _play(GameSoundEffect.success);
  Future<void> playFailure() => _play(GameSoundEffect.failure);

  Future<void> _play(GameSoundEffect effect) async {
    final volume = await loadSoundVolume();
    if (volume <= 0) {
      return;
    }

    try {
      await SystemSound.play(_systemSoundFor(effect));
    } catch (error, stackTrace) {
      debugPrint('Game sound effect failed: $effect\n$error\n$stackTrace');
    }
  }

  SystemSoundType _systemSoundFor(GameSoundEffect effect) {
    return switch (effect) {
      GameSoundEffect.keypad ||
      GameSoundEffect.delete ||
      GameSoundEffect.submit => SystemSoundType.click,
      GameSoundEffect.success ||
      GameSoundEffect.failure => SystemSoundType.alert,
    };
  }

  double _normalizeVolume(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }
}
