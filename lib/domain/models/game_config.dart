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

  factory GameConfig.initialDefault() {
    return const GameConfig(
      difficulty: Difficulty.normal,
      codeLength: 3,
      maxAttempts: null,
      timeLimit: null,
      limitMode: LimitMode.none,
      autoCheckTable: true,
    );
  }

  factory GameConfig.fromLimits({
    required Difficulty difficulty,
    required int codeLength,
    required int? maxAttempts,
    required Duration? timeLimit,
    required bool autoCheckTable,
  }) {
    final usesAttempts = maxAttempts != null && maxAttempts > 0;
    final usesTime = timeLimit != null && timeLimit.inSeconds > 0;
    final mode = switch ((usesAttempts, usesTime)) {
      (false, false) => LimitMode.none,
      (true, false) => LimitMode.attemptsOnly,
      (false, true) => LimitMode.timeOnly,
      (true, true) => LimitMode.attemptsAndTime,
    };

    return GameConfig(
      difficulty: difficulty,
      codeLength: codeLength,
      maxAttempts: usesAttempts ? maxAttempts : null,
      timeLimit: usesTime ? timeLimit : null,
      limitMode: mode,
      autoCheckTable: autoCheckTable,
    );
  }

  GameConfig copyWith({
    int? codeLength,
    Object? maxAttempts = _sentinel,
    Object? timeLimit = _sentinel,
    bool? autoCheckTable,
  }) {
    return GameConfig.fromLimits(
      difficulty: difficulty,
      codeLength: codeLength ?? this.codeLength,
      maxAttempts: identical(maxAttempts, _sentinel)
          ? this.maxAttempts
          : maxAttempts as int?,
      timeLimit: identical(timeLimit, _sentinel)
          ? this.timeLimit
          : timeLimit as Duration?,
      autoCheckTable: autoCheckTable ?? this.autoCheckTable,
    );
  }
}

const _sentinel = Object();
