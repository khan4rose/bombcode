import 'package:bombcode/data/local_game_config_repository.dart';
import 'package:bombcode/domain/enums/difficulty.dart';
import 'package:bombcode/domain/enums/limit_mode.dart';
import 'package:bombcode/domain/models/game_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads initial default when no config is saved', () async {
    SharedPreferences.setMockInitialValues({});

    final config = await LocalGameConfigRepository().loadLastConfig();

    expect(config.difficulty, Difficulty.normal);
    expect(config.maxAttempts, isNull);
    expect(config.timeLimit, isNull);
    expect(config.limitMode, LimitMode.none);
  });

  test('saves and loads last game config', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = LocalGameConfigRepository();
    final saved = GameConfig.fromLimits(
      difficulty: Difficulty.expert,
      codeLength: 4,
      maxAttempts: null,
      timeLimit: const Duration(minutes: 10),
      autoCheckTable: false,
    );

    await repository.saveLastConfig(saved);
    final loaded = await repository.loadLastConfig();

    expect(loaded.difficulty, Difficulty.expert);
    expect(loaded.codeLength, 4);
    expect(loaded.maxAttempts, isNull);
    expect(loaded.timeLimit, const Duration(minutes: 10));
    expect(loaded.limitMode, LimitMode.timeOnly);
    expect(loaded.autoCheckTable, isFalse);
  });
}
