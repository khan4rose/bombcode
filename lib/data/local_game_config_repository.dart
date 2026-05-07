import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/enums/difficulty.dart';
import '../domain/enums/limit_mode.dart';
import '../domain/models/game_config.dart';

class LocalGameConfigRepository {
  static const _key = 'boomcode.game_config.last';

  Future<GameConfig> loadLastConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return GameConfig.initialDefault();
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(json);
    } catch (_) {
      return GameConfig.initialDefault();
    }
  }

  Future<void> saveLastConfig(GameConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_toJson(config)));
  }

  Map<String, Object?> _toJson(GameConfig config) => {
    'difficulty': config.difficulty.name,
    'codeLength': config.codeLength,
    'maxAttempts': config.maxAttempts,
    'timeLimitSeconds': config.timeLimit?.inSeconds,
    'limitMode': config.limitMode.name,
    'autoCheckTable': config.autoCheckTable,
  };

  GameConfig _fromJson(Map<String, dynamic> json) {
    final difficulty = Difficulty.values.byName(json['difficulty'] as String);
    final codeLength = json['codeLength'] as int;
    final maxAttempts = json['maxAttempts'] as int?;
    final timeLimitSeconds = json['timeLimitSeconds'] as int?;
    final autoCheckTable = json['autoCheckTable'] as bool? ?? true;
    final storedModeName = json['limitMode'] as String?;
    final storedMode = storedModeName == null
        ? null
        : LimitMode.values.byName(storedModeName);

    final config = GameConfig.fromLimits(
      difficulty: difficulty,
      codeLength: codeLength,
      maxAttempts: maxAttempts,
      timeLimit: timeLimitSeconds == null
          ? null
          : Duration(seconds: timeLimitSeconds),
      autoCheckTable: autoCheckTable,
    );

    if (storedMode == null || storedMode == config.limitMode) {
      return config;
    }

    return GameConfig.fromLimits(
      difficulty: difficulty,
      codeLength: codeLength,
      maxAttempts:
          storedMode == LimitMode.timeOnly || storedMode == LimitMode.none
          ? null
          : maxAttempts,
      timeLimit:
          storedMode == LimitMode.attemptsOnly || storedMode == LimitMode.none
          ? null
          : config.timeLimit,
      autoCheckTable: autoCheckTable,
    );
  }
}
