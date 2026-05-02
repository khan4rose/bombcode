import 'package:bombcode/domain/enums/difficulty.dart';
import 'package:bombcode/domain/enums/game_over_reason.dart';
import 'package:bombcode/domain/enums/game_status.dart';
import 'package:bombcode/domain/enums/limit_mode.dart';
import 'package:bombcode/domain/models/game_config.dart';
import 'package:bombcode/features/game/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GameConfig config(LimitMode mode) {
    return GameConfig(
      difficulty: Difficulty.beginner,
      codeLength: 4,
      maxAttempts: mode == LimitMode.timeOnly ? null : 1,
      timeLimit: mode == LimitMode.attemptsOnly
          ? null
          : const Duration(seconds: 1),
      limitMode: mode,
      autoCheckTable: true,
    );
  }

  test('success wins before attempt exhaustion', () {
    final controller = GameController()..start(config(LimitMode.attemptsOnly));
    controller.answer = [1, 2, 3, 4];
    for (final digit in [1, 2, 3, 4]) {
      controller.inputDigit(digit);
    }
    controller.submitGuess();
    expect(controller.status, GameStatus.success);
    expect(controller.gameOverReason, GameOverReason.solved);
  });

  test('attempts only fails when attempts reach zero', () {
    final controller = GameController()..start(config(LimitMode.attemptsOnly));
    controller.answer = [1, 2, 3, 4];
    for (final digit in [5, 6, 7, 8]) {
      controller.inputDigit(digit);
    }
    controller.submitGuess();
    expect(controller.status, GameStatus.failed);
    expect(controller.gameOverReason, GameOverReason.attemptsExhausted);
  });

  test('time only fails when timer reaches zero', () {
    final controller = GameController()..start(config(LimitMode.timeOnly));
    controller.tickOneSecond();
    expect(controller.status, GameStatus.failed);
    expect(controller.gameOverReason, GameOverReason.timeExpired);
    controller.dispose();
  });

  test('pause stops manual ticking', () {
    final controller = GameController()..start(config(LimitMode.timeOnly));
    controller.pause();
    controller.tickOneSecond();
    expect(controller.remainingSeconds, 1);
    expect(controller.status, GameStatus.paused);
    controller.dispose();
  });
}
