import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameHapticEvent { keypad, delete, submit, success, failure, critical }

class GameHaptics {
  GameHaptics._();

  static final instance = GameHaptics._();
  static const vibrationEnabledKey = 'boomcode.settings.vibration_enabled';
  static const defaultVibrationEnabled = true;

  bool? _cachedEnabled;

  Future<bool> loadEnabled() async {
    if (_cachedEnabled case final cached?) {
      return cached;
    }
    final prefs = await SharedPreferences.getInstance();
    _cachedEnabled =
        prefs.getBool(vibrationEnabledKey) ?? defaultVibrationEnabled;
    return _cachedEnabled!;
  }

  Future<void> saveEnabled(bool enabled) async {
    _cachedEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(vibrationEnabledKey, enabled);
  }

  Future<void> playKeypad() => _play(GameHapticEvent.keypad);
  Future<void> playDelete() => _play(GameHapticEvent.delete);
  Future<void> playSubmit() => _play(GameHapticEvent.submit);
  Future<void> playSuccess() => _play(GameHapticEvent.success);
  Future<void> playFailure() => _play(GameHapticEvent.failure);
  Future<void> playCritical() => _play(GameHapticEvent.critical);

  Future<void> _play(GameHapticEvent event) async {
    final enabled = await loadEnabled();
    if (!enabled) {
      return;
    }

    try {
      final feedback = switch (event) {
        GameHapticEvent.keypad => HapticFeedback.selectionClick,
        GameHapticEvent.delete ||
        GameHapticEvent.submit => HapticFeedback.lightImpact,
        GameHapticEvent.success ||
        GameHapticEvent.failure ||
        GameHapticEvent.critical => HapticFeedback.mediumImpact,
      };
      await feedback();
    } catch (error, stackTrace) {
      debugPrint('Game haptic failed: $event\n$error\n$stackTrace');
    }
  }
}
