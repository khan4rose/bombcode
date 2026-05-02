import 'dart:math';

List<int> generateAnswer({required int length, Random? random}) {
  final source = List<int>.generate(10, (index) => index);
  final rng = random ?? Random();
  final answer = <int>[];

  while (answer.length < length) {
    final pick = source.removeAt(rng.nextInt(source.length));
    answer.add(pick);
  }

  return answer;
}
