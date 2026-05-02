import '../enums/difficulty.dart';
import '../enums/limit_mode.dart';

class GameConfig {
  final Difficulty difficulty;
  final int codeLength;
  final int? maxAttempts;
  final Duration? timeLimit;
  final LimitMode limitMode;
  final bool autoCheckTable;

  const GameConfig({
    required this.difficulty,
    required this.codeLength,
    required this.maxAttempts,
    required this.timeLimit,
    required this.limitMode,
    required this.autoCheckTable,
  });

  factory GameConfig.defaults(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.beginner => const GameConfig(
        difficulty: Difficulty.beginner,
        codeLength: 2,
        maxAttempts: 20,
        timeLimit: Duration(minutes: 5),
        limitMode: LimitMode.attemptsOnly,
        autoCheckTable: true,
      ),
      Difficulty.normal => const GameConfig(
        difficulty: Difficulty.normal,
        codeLength: 3,
        maxAttempts: 12,
        timeLimit: Duration(minutes: 3),
        limitMode: LimitMode.attemptsAndTime,
        autoCheckTable: true,
      ),
      Difficulty.expert => const GameConfig(
        difficulty: Difficulty.expert,
        codeLength: 4,
        maxAttempts: 7,
        timeLimit: Duration(minutes: 2),
        limitMode: LimitMode.attemptsAndTime,
        autoCheckTable: false,
      ),
    };
  }

  GameConfig copyWith({LimitMode? limitMode, bool? autoCheckTable}) {
    final mode = limitMode ?? this.limitMode;
    return GameConfig(
      difficulty: difficulty,
      codeLength: codeLength,
      maxAttempts: mode == LimitMode.timeOnly ? null : maxAttempts,
      timeLimit: mode == LimitMode.attemptsOnly ? null : timeLimit,
      limitMode: mode,
      autoCheckTable: autoCheckTable ?? this.autoCheckTable,
    );
  }
}
