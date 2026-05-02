import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/utils/timer_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';
import '../../data/local_record_repository.dart';
import '../../domain/enums/game_over_reason.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/models/game_config.dart';
import '../home/home_screen.dart';
import 'game_controller.dart';
import 'widgets/check_table.dart';
import 'widgets/code_slots.dart';
import 'widgets/guess_history_list.dart';
import 'widgets/limit_status_bar.dart';
import 'widgets/number_keypad.dart';

class GameScreen extends StatefulWidget {
  final GameConfig config;

  const GameScreen({super.key, required this.config});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController controller;
  final repository = LocalRecordRepository();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    controller = GameController()..start(widget.config);
    controller.addListener(_saveFinishedRecord);
  }

  Future<void> _saveFinishedRecord() async {
    if (_saved) {
      return;
    }
    if (controller.status == GameStatus.success ||
        controller.status == GameStatus.failed) {
      _saved = true;
      await repository.saveRecord(controller.buildRecord());
    }
  }

  @override
  void dispose() {
    controller.removeListener(_saveFinishedRecord);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final status = controller.status;
        if (status == GameStatus.success || status == GameStatus.failed) {
          return _ResultView(
            controller: controller,
            onRestart: () {
              _saved = false;
              controller.restartSameConfig();
            },
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              '${AppText.difficultyLabel(widget.config.difficulty.name)} / ${AppText.limitModeLabel(widget.config.limitMode.name)}',
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: status == GameStatus.paused
                    ? AppText.resume
                    : AppText.pause,
                onPressed: status == GameStatus.paused
                    ? controller.resume
                    : controller.pause,
                icon: Icon(
                  status == GameStatus.paused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
              ),
            ],
          ),
          body: AppBackground(
            dim: true,
            lightText: true,
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.all(r.c(14)),
                children: [
                  LimitStatusBar(controller: controller),
                  const SizedBox(height: 16),
                  if (status == GameStatus.paused)
                    FilledButton.icon(
                      onPressed: controller.resume,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(AppText.resume),
                    )
                  else ...[
                    CodeSlots(
                      length: widget.config.codeLength,
                      digits: controller.currentGuess,
                    ),
                    const SizedBox(height: 16),
                    NumberKeypad(
                      usedDigits: controller.currentGuess.toSet(),
                      onDigit: controller.inputDigit,
                      onDelete: controller.deleteDigit,
                      onSubmit: controller.canSubmit
                          ? controller.submitGuess
                          : null,
                    ),
                  ],
                  const SizedBox(height: 20),
                  CheckTable(controller: controller),
                  const SizedBox(height: 20),
                  GuessHistoryList(history: controller.history),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultView extends StatelessWidget {
  final GameController controller;
  final VoidCallback onRestart;

  const _ResultView({required this.controller, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final success = controller.status == GameStatus.success;
    final reason = controller.gameOverReason;
    final answer = controller.answer.join();
    final title = success ? 'CODE UNLOCKED' : 'ACCESS DENIED';
    final message = switch (reason) {
      GameOverReason.solved => AppText.missionComplete,
      GameOverReason.attemptsExhausted => AppText.attemptsUsedUp,
      GameOverReason.timeExpired => AppText.timeExpired,
      null => '',
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: AppBackground(
        dim: true,
        lightText: true,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(r.c(22)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  success ? Icons.verified_rounded : Icons.lock_rounded,
                  size: 92,
                  color: success ? Colors.green.shade300 : Colors.red.shade300,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                _Fact(label: AppText.answer, value: answer),
                _Fact(
                  label: AppText.attempts,
                  value: '${controller.history.length}',
                ),
                _Fact(
                  label: AppText.time,
                  value: formatSeconds(controller.elapsedSeconds),
                ),
                _Fact(
                  label: AppText.difficulty,
                  value: AppText.difficultyLabel(
                    controller.config!.difficulty.name,
                  ),
                ),
                _Fact(
                  label: AppText.limit,
                  value: AppText.limitModeLabel(
                    controller.config!.limitMode.name,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(AppText.tryAgain),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(AppText.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
