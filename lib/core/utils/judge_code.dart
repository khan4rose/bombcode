import '../../domain/models/judge_result.dart';

JudgeResult judgeCode({required List<int> answer, required List<int> guess}) {
  var access = 0;
  var trace = 0;

  for (var i = 0; i < guess.length; i++) {
    if (answer[i] == guess[i]) {
      access++;
    } else if (answer.contains(guess[i])) {
      trace++;
    }
  }

  return JudgeResult(access: access, trace: trace);
}
