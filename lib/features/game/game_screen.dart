import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/utils/timer_formatter.dart';
import '../../core/widgets/app_background.dart';
import '../../data/local_record_repository.dart';
import '../../domain/enums/game_over_reason.dart';
import '../../domain/enums/game_status.dart';
import '../../domain/models/game_config.dart';
import '../home/home_screen.dart';
import 'game_controller.dart';
import 'widgets/asset_frame.dart';
import 'widgets/check_table.dart';
import 'widgets/code_slots.dart';
import 'widgets/game_asset_paths.dart';
import 'widgets/guess_history_list.dart';
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
          body: AppBackground(
            dim: true,
            lightText: true,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _GameplayView(controller: controller);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameplayView extends StatelessWidget {
  final GameController controller;

  const _GameplayView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final compact = height < 760;
        final padding = (width * 0.03).clamp(8.0, 14.0).toDouble();
        final gap = compact ? 4.0 : 5.0;
        final contentWidth = width - padding * 2;
        final heroHeight = (contentWidth * 405 / 720)
            .clamp(168.0, 202.0)
            .toDouble();
        final codeHeight = (contentWidth * 180 / 680)
            .clamp(48.0, 56.0)
            .toDouble();
        final keypadHeight = compact ? 200.0 : 204.0;
        final historyMinHeight = compact ? 108.0 : 124.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(padding, 4, padding, padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: heroHeight,
                child: _BombHeroView(controller: controller),
              ),
              SizedBox(height: gap),
              SizedBox(
                height: codeHeight,
                child: CodeSlots(
                  length: controller.config!.codeLength,
                  digits: controller.currentGuess,
                ),
              ),
              SizedBox(height: gap),
              SizedBox(
                height: keypadHeight,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.74,
                    child: NumberKeypad(
                      usedDigits: controller.currentGuess.toSet(),
                      onDigit: controller.inputDigit,
                      onDelete: controller.deleteDigit,
                      onSubmit: controller.canSubmit
                          ? controller.submitGuess
                          : null,
                    ),
                  ),
                ),
              ),
              SizedBox(height: gap),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: historyMinHeight),
                    child: FractionallySizedBox(
                      widthFactor: 0.90,
                      heightFactor: 1,
                      alignment: Alignment.topCenter,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: GuessHistoryList(
                              history: controller.history,
                            ),
                          ),
                          Positioned(
                            top: 21,
                            right: 12,
                            child: _CheckTableIconButton(controller),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BombHeroView extends StatelessWidget {
  final GameController controller;

  const _BombHeroView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AssetFrame(
      assetPath: _heroAsset,
      fit: BoxFit.contain,
      backing: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.92,
            colors: [
              Colors.black.withValues(alpha: 0.30),
              Colors.black.withValues(alpha: 0.14),
              Colors.transparent,
            ],
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(68, 62, 68, 44),
      child: Row(
        children: [
          Expanded(
            child: _BombHudPanel(
              label: 'LEFT',
              color: _stageColor,
              child: _AttemptsLed(
                remaining: controller.remainingAttempts,
                total: controller.config!.maxAttempts,
                enabled: controller.usesAttempts,
                color: _stageColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BombHudPanel(
              label: 'TIME',
              color: _stageColor,
              child: _LedText(
                controller.usesTime
                    ? _formatHudSeconds(controller.remainingSeconds)
                    : '--:--',
                color: _stageColor,
                fontSize: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _heroAsset {
    return switch (_stage) {
      _BombHeroStage.stable => GameAssetPaths.bombHeroStable,
      _BombHeroStage.caution => GameAssetPaths.bombHeroCaution,
      _BombHeroStage.danger => GameAssetPaths.bombHeroDanger,
      _BombHeroStage.critical => GameAssetPaths.bombHeroCritical,
    };
  }

  Color get _stageColor {
    return switch (_stage) {
      _BombHeroStage.stable => const Color(0xFF33D17A),
      _BombHeroStage.caution => const Color(0xFFFFD54A),
      _BombHeroStage.danger => const Color(0xFFFF8A3D),
      _BombHeroStage.critical => const Color(0xFFFF3B30),
    };
  }

  _BombHeroStage get _stage {
    final cfg = controller.config!;
    final risks = <double>[];

    if (controller.usesAttempts) {
      final total = cfg.maxAttempts;
      if (total != null && total > 0) {
        final remaining = controller.remainingAttempts ?? total;
        risks.add(1 - (remaining / total).clamp(0.0, 1.0));
      }
    }

    if (controller.usesTime) {
      final total = cfg.timeLimit?.inSeconds;
      if (total != null && total > 0) {
        final remaining = controller.remainingSeconds ?? total;
        risks.add(1 - (remaining / total).clamp(0.0, 1.0));
      }
    }

    final risk = risks.isEmpty ? 0.0 : risks.reduce((a, b) => a > b ? a : b);
    if (risk >= 0.82) {
      return _BombHeroStage.critical;
    }
    if (risk >= 0.62) {
      return _BombHeroStage.danger;
    }
    if (risk >= 0.36) {
      return _BombHeroStage.caution;
    }
    return _BombHeroStage.stable;
  }
}

enum _BombHeroStage { stable, caution, danger, critical }

class _BombHudPanel extends StatelessWidget {
  final String label;
  final Color color;
  final Widget child;

  const _BombHudPanel({
    required this.label,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: _PanelText(label, color: color, fontSize: 10, centered: true),
        ),
        Center(child: child),
      ],
    );
  }
}

class _AttemptsLed extends StatelessWidget {
  final int? remaining;
  final int? total;
  final bool enabled;
  final Color color;

  const _AttemptsLed({
    required this.remaining,
    required this.total,
    required this.enabled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final totalAttempts = total;
    if (!enabled || totalAttempts == null || totalAttempts == 0) {
      return _LedText('--', color: color, fontSize: 30);
    }

    final left = (remaining ?? totalAttempts).clamp(0, totalAttempts).toInt();
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: left.toString().padLeft(2, '0'),
              style: TextStyle(fontSize: 34, color: color),
            ),
            TextSpan(
              text: ' /$totalAttempts',
              style: TextStyle(fontSize: 16, color: color),
            ),
          ],
        ),
        maxLines: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
          shadows: [
            Shadow(color: Color(0xFFFF2A1B), blurRadius: 10),
            Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}

class _LedText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const _LedText(this.text, {required this.color, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
          shadows: [
            Shadow(color: color.withValues(alpha: 0.55), blurRadius: 12),
            const Shadow(
              color: Colors.black,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatHudSeconds(int? seconds) {
  if (seconds == null) {
    return '--:--';
  }
  final safeSeconds = seconds < 0 ? 0 : seconds;
  final minutes = safeSeconds ~/ 60;
  final rest = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${rest.toString().padLeft(2, '0')}';
}

class _CheckTableIconButton extends StatelessWidget {
  final GameController controller;

  const _CheckTableIconButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppText.checkTable,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openCheckTable(context),
        child: Opacity(
          opacity: 0.98,
          child: SizedBox(
            width: 46,
            height: 46,
            child: CustomPaint(
              painter: const _CheckTableButtonFramePainter(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 6,
                    right: 7,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.82),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF3B30,
                            ).withValues(alpha: 0.32),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const SizedBox(width: 4, height: 4),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.44),
                      ),
                      child: const SizedBox(width: 16, height: 2),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(
                        GameAssetPaths.checkTableBulbIcon,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) {
                          return const CustomPaint(
                            painter: _CheckTableBulbFallbackPainter(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCheckTable(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              height: 220,
              child: CheckTable(controller: controller),
            ),
          ),
        );
      },
    );
  }
}

class _CheckTableBulbFallbackPainter extends CustomPainter {
  const _CheckTableBulbFallbackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glow = Paint()
      ..color = const Color(0xFFFFB52C).withValues(alpha: 0.24)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final fill = Paint()
      ..color = const Color(0xFFFFC247).withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final rim = Paint()
      ..color = const Color(0xFFFFE39A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final base = Paint()
      ..color = const Color(0xFFC5CBD4).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final baseLine = Paint()
      ..color = const Color(0xFF3C4149).withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;

    final bulb = Path()
      ..moveTo(w * 0.50, h * 0.18)
      ..cubicTo(w * 0.30, h * 0.18, w * 0.27, h * 0.42, w * 0.39, h * 0.53)
      ..cubicTo(w * 0.44, h * 0.58, w * 0.44, h * 0.63, w * 0.44, h * 0.67)
      ..lineTo(w * 0.56, h * 0.67)
      ..cubicTo(w * 0.56, h * 0.63, w * 0.56, h * 0.58, w * 0.61, h * 0.53)
      ..cubicTo(w * 0.73, h * 0.42, w * 0.70, h * 0.18, w * 0.50, h * 0.18)
      ..close();
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.42),
        width: w * 0.74,
        height: h * 0.74,
      ),
      glow,
    );
    canvas.drawPath(bulb, fill);
    canvas.drawPath(bulb, rim);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.40, h * 0.68, w * 0.60, h * 0.82),
        Radius.circular(w * 0.03),
      ),
      base,
    );
    canvas.drawLine(
      Offset(w * 0.42, h * 0.73),
      Offset(w * 0.58, h * 0.73),
      baseLine,
    );
    canvas.drawLine(
      Offset(w * 0.43, h * 0.78),
      Offset(w * 0.57, h * 0.78),
      baseLine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckTableButtonFramePainter extends CustomPainter {
  const _CheckTableButtonFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outer = _octFramePath(Rect.fromLTWH(1.5, 1.5, w - 3, h - 3), 8);
    final inner = _octFramePath(Rect.fromLTWH(8, 8, w - 16, h - 16), 5);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.58)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(outer.shift(const Offset(0, 2)), shadow);

    canvas.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4A5058).withValues(alpha: 0.98),
            const Color(0xFF15191E),
            const Color(0xFF050607),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..color = const Color(0xFFE1E7EF).withValues(alpha: 0.34),
    );

    canvas.drawPath(
      inner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF15181C).withValues(alpha: 0.96),
            const Color(0xFF030405),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0xFFFF3B30).withValues(alpha: 0.38),
    );

    final accent = Paint()
      ..color = const Color(0xFFFF3B30).withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;
    final accentGlow = Paint()
      ..color = const Color(0xFFFF3B30).withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final topAccent = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.13),
        width: w * 0.28,
        height: 2.2,
      ),
      const Radius.circular(2),
    );
    final bottomAccent = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.88),
        width: w * 0.32,
        height: 2,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(topAccent, accentGlow);
    canvas.drawRRect(bottomAccent, accentGlow);
    canvas.drawRRect(topAccent, accent);
    canvas.drawRRect(bottomAccent, accent);

    final sideAccent = Paint()
      ..color = const Color(0xFFFF3B30).withValues(alpha: 0.34)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.08, h * 0.34),
      Offset(w * 0.08, h * 0.66),
      sideAccent,
    );
    canvas.drawLine(
      Offset(w * 0.92, h * 0.34),
      Offset(w * 0.92, h * 0.66),
      sideAccent,
    );

    final screw = Paint()..color = Colors.black.withValues(alpha: 0.62);
    for (final offset in [
      Offset(w * 0.18, h * 0.18),
      Offset(w * 0.82, h * 0.18),
      Offset(w * 0.18, h * 0.82),
      Offset(w * 0.82, h * 0.82),
    ]) {
      canvas.drawCircle(offset, 1.7, screw);
      canvas.drawCircle(
        offset,
        1.1,
        Paint()..color = const Color(0xFF78808A).withValues(alpha: 0.28),
      );
    }
  }

  Path _octFramePath(Rect rect, double cut) {
    return Path()
      ..moveTo(rect.left + cut, rect.top)
      ..lineTo(rect.right - cut, rect.top)
      ..lineTo(rect.right, rect.top + cut)
      ..lineTo(rect.right, rect.bottom - cut)
      ..lineTo(rect.right - cut, rect.bottom)
      ..lineTo(rect.left + cut, rect.bottom)
      ..lineTo(rect.left, rect.bottom - cut)
      ..lineTo(rect.left, rect.top + cut)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResultView extends StatelessWidget {
  final GameController controller;
  final VoidCallback onRestart;

  const _ResultView({required this.controller, required this.onRestart});

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: AspectRatio(
                aspectRatio: 680 / 560,
                child: AssetFrame(
                  assetPath: success
                      ? GameAssetPaths.resultModalSuccess
                      : GameAssetPaths.resultModalFailure,
                  padding: const EdgeInsets.fromLTRB(46, 34, 46, 42),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: success
                              ? const Color(0xFFE5FCFF)
                              : const Color(0xFFFFD8C4),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Fact(label: AppText.answer, value: answer),
                            _Fact(
                              label: AppText.attempts,
                              value: '${controller.history.length}',
                            ),
                            _Fact(
                              label: AppText.time,
                              value: formatSeconds(controller.elapsedSeconds),
                            ),
                          ],
                        ),
                      ),
                      _ModalActionButton(
                        assetPath: GameAssetPaths.modalPrimaryButton,
                        label: AppText.tryAgain,
                        onTap: onRestart,
                      ),
                      const SizedBox(height: 10),
                      _ModalActionButton(
                        assetPath: GameAssetPaths.modalSecondaryButton,
                        label: AppText.home,
                        onTap: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalActionButton extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;

  const _ModalActionButton({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: AssetFrame(
          assetPath: assetPath,
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final bool centered;

  const _PanelText(
    this.text, {
    this.color = Colors.white,
    required this.fontSize,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}
