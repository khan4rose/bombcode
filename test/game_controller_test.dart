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
      maxAttempts: switch (mode) {
        LimitMode.none || LimitMode.timeOnly => null,
        LimitMode.attemptsOnly || LimitMode.attemptsAndTime => 1,
      },
      timeLimit: switch (mode) {
        LimitMode.none || LimitMode.attemptsOnly => null,
        LimitMode.timeOnly ||
        LimitMode.attemptsAndTime => const Duration(seconds: 1),
      },
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

  test('time only waits for first input before ticking', () {
    final controller = GameController()..start(config(LimitMode.timeOnly));
    controller.tickOneSecond();
    expect(controller.status, GameStatus.playing);
    expect(controller.remainingSeconds, 1);

    controller.inputDigit(5);
    controller.tickOneSecond();
    expect(controller.status, GameStatus.failed);
    expect(controller.gameOverReason, GameOverReason.timeExpired);
    controller.dispose();
  });

  test('no limit mode does not fail from attempts or timer', () {
    final controller = GameController()..start(config(LimitMode.none));
    controller.answer = [1, 2, 3, 4];

    for (var round = 0; round < 3; round++) {
      for (final digit in [5, 6, 7, 8]) {
        controller.inputDigit(digit);
      }
      controller.submitGuess();
    }

    controller.tickOneSecond();
    expect(controller.status, GameStatus.playing);
    expect(controller.remainingAttempts, isNull);
    expect(controller.remainingSeconds, isNull);
    expect(controller.gameOverReason, isNull);
    expect(controller.history.length, 3);
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
