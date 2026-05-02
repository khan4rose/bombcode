import 'package:bombcode/core/utils/judge_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('judges Access and Trace examples', () {
    final cases = [
      ([1, 2, 3, 4], [1, 2, 3, 4], 4, 0),
      ([1, 2, 3, 4], [1, 2, 4, 3], 2, 2),
      ([1, 2, 3, 4], [5, 6, 7, 8], 0, 0),
      ([1, 2, 3, 4], [4, 3, 2, 1], 0, 4),
      ([1, 2, 3, 4], [1, 0, 3, 5], 2, 0),
    ];

    for (final item in cases) {
      final result = judgeCode(answer: item.$1, guess: item.$2);
      expect(result.access, item.$3);
      expect(result.trace, item.$4);
    }
  });
}
