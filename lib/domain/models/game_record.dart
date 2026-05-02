import '../enums/difficulty.dart';
import '../enums/limit_mode.dart';

class GameRecord {
  final Difficulty difficulty;
  final LimitMode limitMode;
  final int codeLength;
  final int attemptsUsed;
  final int? maxAttempts;
  final int elapsedSeconds;
  final int? timeLimitSeconds;
  final DateTime playedAt;
  final bool success;

  const GameRecord({
    required this.difficulty,
    required this.limitMode,
    required this.codeLength,
    required this.attemptsUsed,
    required this.maxAttempts,
    required this.elapsedSeconds,
    required this.timeLimitSeconds,
    required this.playedAt,
    required this.success,
  });

  Map<String, Object?> toJson() => {
    'difficulty': difficulty.name,
    'limitMode': limitMode.name,
    'codeLength': codeLength,
    'attemptsUsed': attemptsUsed,
    'maxAttempts': maxAttempts,
    'elapsedSeconds': elapsedSeconds,
    'timeLimitSeconds': timeLimitSeconds,
    'playedAt': playedAt.toIso8601String(),
    'success': success,
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      limitMode: LimitMode.values.byName(json['limitMode'] as String),
      codeLength: json['codeLength'] as int,
      attemptsUsed: json['attemptsUsed'] as int,
      maxAttempts: json['maxAttempts'] as int?,
      elapsedSeconds: json['elapsedSeconds'] as int,
      timeLimitSeconds: json['timeLimitSeconds'] as int?,
      playedAt: DateTime.parse(json['playedAt'] as String),
      success: json['success'] as bool,
    );
  }
}
