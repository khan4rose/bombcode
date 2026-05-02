import 'judge_result.dart';

class GuessRecord {
  final List<int> guess;
  final JudgeResult result;
  final int attemptNumber;
  final int elapsedSeconds;

  const GuessRecord({
    required this.guess,
    required this.result,
    required this.attemptNumber,
    required this.elapsedSeconds,
  });
}
