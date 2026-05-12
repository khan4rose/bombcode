import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/utils/code_generator.dart';
import '../../core/utils/judge_code.dart';
import '../../domain/enums/digit_mark.dart';
import '../../domain/enums/game_over_reason.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/models/game_config.dart';
import '../../domain/models/game_record.dart';
import '../../domain/models/guess_record.dart';
import '../../domain/models/judge_result.dart';

class GameController extends ChangeNotifier {
  GameConfig? config;
  List<int> answer = const [];
  List<int> currentGuess = [];
  List<GuessRecord> history = [];
  Map<int, DigitMark> digitMarks = {
    for (var digit = 0; digit <= 9; digit++) digit: DigitMark.unknown,
  };
  int? remainingAttempts;
  int? remainingSeconds;
  int elapsedSeconds = 0;
  GameStatus status = GameStatus.ready;
  GameOverReason? gameOverReason;
  Timer? _timer;
  bool _timerStarted = false;

  bool get isComplete =>
      config != null && currentGuess.length == config!.codeLength;
  bool get usesAttempts => config?.maxAttempts != null;
  bool get usesTime => config?.timeLimit != null;
  bool get canSubmit => status == GameStatus.playing && isComplete;

  void start(GameConfig config) {
    _timer?.cancel();
    _timer = null;
    this.config = config;
    answer = generateAnswer(length: config.codeLength);
    currentGuess = [];
    history = [];
    digitMarks = {
      for (var digit = 0; digit <= 9; digit++) digit: DigitMark.unknown,
    };
    remainingAttempts = config.maxAttempts;
    remainingSeconds = config.timeLimit?.inSeconds;
    elapsedSeconds = 0;
    gameOverReason = null;
    status = GameStatus.playing;
    _timerStarted = false;
    notifyListeners();
  }

  void pause() {
    if (status != GameStatus.playing) {
      return;
    }
    status = GameStatus.paused;
    notifyListeners();
  }

  void resume() {
    if (status != GameStatus.paused) {
      return;
    }
    status = GameStatus.playing;
    notifyListeners();
  }

  void inputDigit(int digit) {
    final cfg = config;
    if (cfg == null || status != GameStatus.playing) {
      return;
    }
    if (currentGuess.length >= cfg.codeLength || currentGuess.contains(digit)) {
      return;
    }
    currentGuess = [...currentGuess, digit];
    _startTimerIfNeeded();
    notifyListeners();
  }

  void replaceDigitAt(int index, int digit) {
    final cfg = config;
    if (cfg == null || status != GameStatus.playing) {
      return;
    }
    if (index < 0 || index >= currentGuess.length || index >= cfg.codeLength) {
      return;
    }
    final existingIndex = currentGuess.indexOf(digit);
    if (existingIndex != -1 && existingIndex != index) {
      return;
    }
    if (currentGuess[index] == digit) {
      return;
    }
    final nextGuess = [...currentGuess];
    nextGuess[index] = digit;
    currentGuess = nextGuess;
    _startTimerIfNeeded();
    notifyListeners();
  }

  void setCurrentGuess(List<int> digits) {
    final cfg = config;
    if (cfg == null || status != GameStatus.playing) {
      return;
    }
    if (digits.length > cfg.codeLength ||
        digits.toSet().length != digits.length) {
      return;
    }
    if (_sameDigits(currentGuess, digits)) {
      return;
    }
    currentGuess = List<int>.of(digits);
    _startTimerIfNeeded();
    notifyListeners();
  }

  void deleteDigit() {
    if (status != GameStatus.playing || currentGuess.isEmpty) {
      return;
    }
    currentGuess = currentGuess.sublist(0, currentGuess.length - 1);
    notifyListeners();
  }

  void submitGuess() {
    final cfg = config;
    if (cfg == null || !canSubmit) {
      return;
    }

    final result = judgeCode(answer: answer, guess: currentGuess);
    history = [
      GuessRecord(
        guess: List<int>.unmodifiable(currentGuess),
        result: result,
        attemptNumber: history.length + 1,
        elapsedSeconds: elapsedSeconds,
      ),
      ...history,
    ];
    _updateAutoMarks(currentGuess, result);

    if (result.access == cfg.codeLength) {
      _finish(GameOverReason.solved);
      return;
    }

    if (usesAttempts) {
      remainingAttempts = (remainingAttempts ?? 0) - 1;
    }
    currentGuess = [];

    if (usesAttempts && remainingAttempts == 0) {
      _finish(GameOverReason.attemptsExhausted);
      return;
    }
    notifyListeners();
  }

  void markDigit(int digit) {
    final cfg = config;
    if (cfg == null || cfg.autoCheckTable) {
      return;
    }
    digitMarks = {...digitMarks, digit: digitMarks[digit]!.next};
    notifyListeners();
  }

  void tickOneSecond() {
    if (status != GameStatus.playing) {
      return;
    }
    if (usesTime && !_timerStarted) {
      return;
    }
    elapsedSeconds++;
    if (usesTime) {
      remainingSeconds = (remainingSeconds ?? 0) - 1;
      if (remainingSeconds == 0) {
        _finish(GameOverReason.timeExpired);
        return;
      }
    }
    notifyListeners();
  }

  void restartSameConfig() {
    final cfg = config;
    if (cfg != null) {
      start(cfg);
    }
  }

  GameRecord buildRecord() {
    final cfg = config!;
    return GameRecord(
      difficulty: cfg.difficulty,
      limitMode: cfg.limitMode,
      codeLength: cfg.codeLength,
      attemptsUsed: history.length,
      maxAttempts: cfg.maxAttempts,
      elapsedSeconds: elapsedSeconds,
      timeLimitSeconds: cfg.timeLimit?.inSeconds,
      playedAt: DateTime.now(),
      success: status == GameStatus.success,
    );
  }

  void _startTimerIfNeeded() {
    if (!usesTime || _timerStarted) {
      return;
    }
    _timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tickOneSecond());
  }

  void _finish(GameOverReason reason) {
    _timer?.cancel();
    _timer = null;
    gameOverReason = reason;
    status = reason == GameOverReason.solved
        ? GameStatus.success
        : GameStatus.failed;
    currentGuess = [];
    notifyListeners();
  }

  bool _sameDigits(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  void _updateAutoMarks(List<int> guess, JudgeResult result) {
    final cfg = config;
    if (cfg == null || !cfg.autoCheckTable) {
      return;
    }
    final next = Map<int, DigitMark>.from(digitMarks);
    if (result.access == 0 && result.trace == 0) {
      for (final digit in guess) {
        next[digit] = DigitMark.impossible;
      }
    } else {
      for (final digit in guess) {
        if (next[digit] == DigitMark.unknown) {
          next[digit] = DigitMark.possible;
        }
      }
    }
    digitMarks = next;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
