import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/feedback/game_haptics.dart';
import '../../core/utils/game_sound_effects.dart';
import '../../core/utils/timer_formatter.dart';
import '../../core/widgets/app_background.dart';
import '../../data/local_record_repository.dart';
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
  final _sounds = GameSoundEffects.instance;
  final _haptics = GameHaptics.instance;
  bool _saved = false;
  bool _failureResultAssetsPrecached = false;

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
      final success = controller.status == GameStatus.success;
      await Future.wait([
        success ? _sounds.playSuccess() : _sounds.playFailure(),
        success ? _haptics.playSuccess() : _haptics.playFailure(),
      ]);
      await repository.saveRecord(controller.buildRecord());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_failureResultAssetsPrecached) {
      return;
    }
    _failureResultAssetsPrecached = true;
    for (final assetPath in const [
      GameAssetPaths.failureSceneBg,
      GameAssetPaths.failureResultPanel,
      GameAssetPaths.resultFailureTitleEn,
      GameAssetPaths.resultFailureTitleKo,
      GameAssetPaths.resultButtonPrimary,
      GameAssetPaths.resultButtonSecondary,
      GameAssetPaths.resultKeyIcon,
    ]) {
      precacheImage(AssetImage(assetPath), context);
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
        final finished =
            status == GameStatus.success || status == GameStatus.failed;
        final failed = status == GameStatus.failed;

        return Scaffold(
          backgroundColor: Colors.black,
          body: AppBackground(
            dim: true,
            lightText: true,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (failed)
                        const SizedBox.expand()
                      else
                        _GameplayView(controller: controller),
                      if (finished)
                        failed
                            ? _FailureResultOverlay(
                                controller: controller,
                                onRestart: () {
                                  _saved = false;
                                  controller.restartSameConfig();
                                },
                              )
                            : _ResultOverlay(
                                controller: controller,
                                onRestart: () {
                                  _saved = false;
                                  controller.restartSameConfig();
                                },
                              ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GameplayView extends StatefulWidget {
  final GameController controller;

  const _GameplayView({required this.controller});

  @override
  State<_GameplayView> createState() => _GameplayViewState();
}

class _GameplayViewState extends State<_GameplayView> {
  int? _selectedCodeIndex;
  List<int?>? _slotDigitsOverride;

  GameController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final compact = height < 760;
        final short = height < 680;
        final padding = (width * 0.03).clamp(8.0, 14.0).toDouble();
        final topPadding = (height * 0.006).clamp(2.0, 4.0).toDouble();
        final bottomPadding = (height * 0.012).clamp(6.0, padding).toDouble();
        final gap = (height * 0.006).clamp(3.0, compact ? 4.0 : 5.0).toDouble();
        final contentWidth = width - padding * 2;
        final minHeroHeight = short ? 132.0 : 168.0;
        final preferredHeroHeight = (contentWidth * 405 / 720)
            .clamp(minHeroHeight, compact ? 190.0 : 202.0)
            .toDouble();
        final codeHeight = (contentWidth * 180 / 680)
            .clamp(short ? 44.0 : 48.0, compact ? 52.0 : 56.0)
            .toDouble();
        final keypadHeight = short ? 198.0 : (compact ? 200.0 : 204.0);
        final preferredHistoryMinHeight = (height * 0.16)
            .clamp(short ? 92.0 : 108.0, compact ? 112.0 : 124.0)
            .toDouble();
        final availableHistoryHeight =
            height -
            topPadding -
            bottomPadding -
            codeHeight -
            keypadHeight -
            minHeroHeight -
            gap * 3;
        final historyMinHeight = math
            .min(
              preferredHistoryMinHeight,
              math.max(short ? 72.0 : 108.0, availableHistoryHeight),
            )
            .toDouble();
        final reservedHeight =
            topPadding +
            bottomPadding +
            codeHeight +
            keypadHeight +
            historyMinHeight +
            gap * 3;
        final heroHeight = math
            .min(
              preferredHeroHeight,
              math.max(minHeroHeight, height - reservedHeight),
            )
            .toDouble();

        return Padding(
          padding: EdgeInsets.fromLTRB(
            padding,
            topPadding,
            padding,
            bottomPadding,
          ),
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
                  slotDigits: _visibleSlotDigits(),
                  selectedIndex: _effectiveSelectedIndex(),
                  onSlotTap: _selectCodeSlot,
                ),
              ),
              SizedBox(height: gap),
              SizedBox(
                height: keypadHeight,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.74,
                    child: NumberKeypad(
                      usedDigits: _usedDigitsForKeypad(),
                      onDigit: _inputDigit,
                      onDelete: _deleteDigit,
                      onSubmit: controller.canSubmit ? _submitGuess : null,
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

  int? _effectiveSelectedIndex() {
    final selected = _selectedCodeIndex;
    final cfg = controller.config;
    if (selected == null || cfg == null) {
      return null;
    }
    if (selected < 0 || selected >= cfg.codeLength) {
      return null;
    }
    if (selected > controller.currentGuess.length) {
      return null;
    }
    return selected;
  }

  Set<int> _usedDigitsForKeypad() {
    final selected = _effectiveSelectedIndex();
    final slots = _visibleSlotDigits();
    final usedDigits = slots.whereType<int>().toSet();
    if (selected != null) {
      final selectedDigit = slots[selected];
      if (selectedDigit != null) {
        usedDigits.remove(selectedDigit);
      }
    }
    return usedDigits;
  }

  void _selectCodeSlot(int index) {
    final cfg = controller.config;
    if (cfg == null || index < 0 || index >= cfg.codeLength) {
      return;
    }
    final slots = _visibleSlotDigits();
    if (slots[index] == null && index != _firstEmptySlotIndex(slots)) {
      return;
    }
    setState(() => _selectedCodeIndex = index);
  }

  void _inputDigit(int digit) {
    final selected = _effectiveSelectedIndex();
    final before = List<int>.of(controller.currentGuess);
    if (selected != null) {
      final slots = _visibleSlotDigits();
      final duplicateIndex = slots.indexOf(digit);
      if (duplicateIndex != -1 && duplicateIndex != selected) {
        return;
      }
      slots[selected] = digit;
      _applySlotDigits(slots);
    } else {
      controller.inputDigit(digit);
    }
    if (!_sameDigits(before, controller.currentGuess)) {
      unawaited(GameSoundEffects.instance.playKeypad());
      unawaited(GameHaptics.instance.playKeypad());
    }
  }

  void _deleteDigit() {
    final selected = _effectiveSelectedIndex();
    if (selected != null) {
      final slots = _visibleSlotDigits();
      if (slots[selected] == null) {
        return;
      }
      final before = List<int>.of(controller.currentGuess);
      slots[selected] = null;
      _applySlotDigits(slots, keepInteriorGaps: true);
      if (!_sameDigits(before, controller.currentGuess)) {
        unawaited(GameSoundEffects.instance.playDelete());
        unawaited(GameHaptics.instance.playDelete());
      }
      return;
    }

    final before = controller.currentGuess.length;
    controller.deleteDigit();
    if (controller.currentGuess.length < before) {
      _slotDigitsOverride = null;
      unawaited(GameSoundEffects.instance.playDelete());
      unawaited(GameHaptics.instance.playDelete());
    }
  }

  void _submitGuess() {
    if (!controller.canSubmit) {
      return;
    }
    unawaited(GameSoundEffects.instance.playSubmit());
    unawaited(GameHaptics.instance.playSubmit());
    _selectedCodeIndex = null;
    _slotDigitsOverride = null;
    controller.submitGuess();
  }

  List<int?> _visibleSlotDigits() {
    final cfg = controller.config;
    final length = cfg?.codeLength ?? controller.currentGuess.length;
    final override = _slotDigitsOverride;
    if (override != null &&
        override.length == length &&
        _sameDigits(_filledDigits(override), controller.currentGuess)) {
      return List<int?>.of(override);
    }

    return [
      for (var index = 0; index < length; index++)
        index < controller.currentGuess.length
            ? controller.currentGuess[index]
            : null,
    ];
  }

  void _applySlotDigits(List<int?> slots, {bool keepInteriorGaps = false}) {
    final nextGuess = _filledDigits(slots);
    controller.setCurrentGuess(nextGuess);
    setState(() {
      _slotDigitsOverride = keepInteriorGaps || _hasInteriorGap(slots)
          ? List<int?>.of(slots)
          : null;
    });
  }

  List<int> _filledDigits(List<int?> slots) {
    return [for (final digit in slots) ?digit];
  }

  int? _firstEmptySlotIndex(List<int?> slots) {
    for (var index = 0; index < slots.length; index++) {
      if (slots[index] == null) {
        return index;
      }
    }
    return null;
  }

  bool _hasInteriorGap(List<int?> slots) {
    var sawEmpty = false;
    for (final digit in slots) {
      if (digit == null) {
        sawEmpty = true;
      } else if (sawEmpty) {
        return true;
      }
    }
    return false;
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
}

class _BombHeroView extends StatefulWidget {
  final GameController controller;

  const _BombHeroView({required this.controller});

  @override
  State<_BombHeroView> createState() => _BombHeroViewState();
}

class _BombHeroViewState extends State<_BombHeroView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late _BombHeroStage _stage;
  bool _heroAssetsPrecached = false;

  @override
  void initState() {
    super.initState();
    _stage = _resolveStage();
    _pulseController = AnimationController(
      vsync: this,
      duration: _stage.animationDuration,
    )..repeat(reverse: true);
    if (_stage == _BombHeroStage.critical) {
      unawaited(GameHaptics.instance.playCritical());
    }
  }

  @override
  void didUpdateWidget(covariant _BombHeroView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextStage = _resolveStage();
    if (nextStage == _stage) {
      return;
    }
    _stage = nextStage;
    _pulseController.duration = _stage.animationDuration;
    _pulseController.repeat(reverse: true);
    if (_stage == _BombHeroStage.critical) {
      unawaited(GameHaptics.instance.playCritical());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_heroAssetsPrecached) {
      return;
    }
    _heroAssetsPrecached = true;
    for (final stage in _BombHeroStage.values) {
      precacheImage(AssetImage(stage.assetPath), context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageColor = _stage.color;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(68, 62, 68, 44),
          child: Row(
            children: [
              Expanded(
                child: _BombHudPanel(
                  label: 'LEFT',
                  color: stageColor,
                  child: _AttemptsLed(
                    remaining: widget.controller.remainingAttempts,
                    total: widget.controller.config!.maxAttempts,
                    enabled: widget.controller.usesAttempts,
                    color: stageColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BombHudPanel(
                  label: 'TIME',
                  color: stageColor,
                  child: _LedText(
                    widget.controller.usesTime
                        ? _formatHudSeconds(widget.controller.remainingSeconds)
                        : '--:--',
                    color: stageColor,
                    fontSize: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        builder: (context, hud) {
          final effect = _stage.effectAt(_pulseController.value);
          return Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                left: -18,
                top: -10,
                right: -18,
                bottom: -10,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BombHeroOuterGlowPainter(
                      stage: _stage,
                      color: stageColor,
                      opacity: effect.outerGlowOpacity,
                    ),
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.92,
                    colors: [
                      Color(0x4D000000),
                      Color(0x24000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: effect.glowOpacity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.76,
                      colors: [
                        stageColor.withValues(alpha: 0.30),
                        stageColor.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                reverseDuration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [...previousChildren, ?currentChild],
                  );
                },
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Image.asset(
                  _stage.assetPath,
                  key: ValueKey<String>(_stage.assetPath),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BombHeroLightOverlayPainter(
                      stage: _stage,
                      color: stageColor,
                      glowOpacity: effect.glowOpacity,
                      warningOpacity: effect.warningGlowOpacity,
                    ),
                  ),
                ),
              ),
              ?hud,
            ],
          );
        },
      ),
    );
  }

  _BombHeroStage _resolveStage() {
    final cfg = widget.controller.config!;
    final risks = <double>[];

    if (widget.controller.usesAttempts) {
      final total = cfg.maxAttempts;
      if (total != null && total > 0) {
        final remaining = widget.controller.remainingAttempts ?? total;
        risks.add(1 - (remaining / total).clamp(0.0, 1.0));
      }
    }

    if (widget.controller.usesTime) {
      final total = cfg.timeLimit?.inSeconds;
      if (total != null && total > 0) {
        final remaining = widget.controller.remainingSeconds ?? total;
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

extension _BombHeroStageVisuals on _BombHeroStage {
  String get assetPath {
    return switch (this) {
      _BombHeroStage.stable => GameAssetPaths.bombHeroStable,
      _BombHeroStage.caution => GameAssetPaths.bombHeroCaution,
      _BombHeroStage.danger => GameAssetPaths.bombHeroDanger,
      _BombHeroStage.critical => GameAssetPaths.bombHeroCritical,
    };
  }

  Color get color {
    return switch (this) {
      _BombHeroStage.stable => const Color(0xFF33D17A),
      _BombHeroStage.caution => const Color(0xFFFFD54A),
      _BombHeroStage.danger => const Color(0xFFFF8A3D),
      _BombHeroStage.critical => const Color(0xFFFF3B30),
    };
  }

  Duration get animationDuration {
    return switch (this) {
      _BombHeroStage.stable => const Duration(milliseconds: 2200),
      _BombHeroStage.caution => const Duration(milliseconds: 1200),
      _BombHeroStage.danger => const Duration(milliseconds: 760),
      _BombHeroStage.critical => const Duration(milliseconds: 360),
    };
  }

  _BombHeroEffect effectAt(double value) {
    final breath = Curves.easeInOut.transform(value);
    final warningWave = (math.sin(value * math.pi * 7) + 1) / 2;
    final warningSpike = (math.sin(value * math.pi * 17) + 1) / 2;
    final flicker = Curves.easeOut.transform(
      (breath * 0.50 + warningWave * 0.32 + warningSpike * 0.18)
          .clamp(0.0, 1.0)
          .toDouble(),
    );
    return switch (this) {
      _BombHeroStage.stable => _BombHeroEffect(
        outerGlowOpacity: 0.014 + breath * 0.026,
        glowOpacity: 0.026 + breath * 0.030,
        warningGlowOpacity: 0.014 + breath * 0.026,
      ),
      _BombHeroStage.caution => _BombHeroEffect(
        outerGlowOpacity: 0.044 + breath * 0.090,
        glowOpacity: 0.068 + breath * 0.105,
        warningGlowOpacity: 0.052 + breath * 0.112,
      ),
      _BombHeroStage.danger => _BombHeroEffect(
        outerGlowOpacity: 0.066 + breath * 0.135,
        glowOpacity: 0.090 + breath * 0.145,
        warningGlowOpacity: 0.075 + breath * 0.165,
      ),
      _BombHeroStage.critical => _BombHeroEffect(
        outerGlowOpacity: 0.074 + flicker * 0.195,
        glowOpacity: 0.090 + flicker * 0.188,
        warningGlowOpacity: 0.082 + flicker * 0.225,
      ),
    };
  }
}

class _BombHeroEffect {
  final double outerGlowOpacity;
  final double glowOpacity;
  final double warningGlowOpacity;

  const _BombHeroEffect({
    required this.outerGlowOpacity,
    required this.glowOpacity,
    required this.warningGlowOpacity,
  });
}

class _BombHeroOuterGlowPainter extends CustomPainter {
  final _BombHeroStage stage;
  final Color color;
  final double opacity;

  const _BombHeroOuterGlowPainter({
    required this.stage,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final haloPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.52),
        width: w * 0.96,
        height: h * 0.72,
      ),
      haloPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.18, h * 0.54),
        width: w * 0.36,
        height: h * 0.46,
      ),
      haloPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.82, h * 0.54),
        width: w * 0.36,
        height: h * 0.46,
      ),
      haloPaint,
    );

    if (stage == _BombHeroStage.critical) {
      final edgePaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.72)
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.52),
            width: w * 0.92,
            height: h * 0.62,
          ),
          const Radius.circular(34),
        ),
        edgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BombHeroOuterGlowPainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity;
  }
}

class _BombHeroLightOverlayPainter extends CustomPainter {
  final _BombHeroStage stage;
  final Color color;
  final double glowOpacity;
  final double warningOpacity;

  const _BombHeroLightOverlayPainter({
    required this.stage,
    required this.color,
    required this.glowOpacity,
    required this.warningOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowOpacity)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final hotPaint = Paint()
      ..color = color.withValues(alpha: warningOpacity)
      ..blendMode = BlendMode.plus;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.50),
        width: w * 0.68,
        height: h * 0.54,
      ),
      glowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.31, h * 0.52),
        width: w * 0.30,
        height: h * 0.30,
      ),
      glowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.69, h * 0.52),
        width: w * 0.30,
        height: h * 0.30,
      ),
      glowPaint,
    );

    final stripHeight = stage == _BombHeroStage.stable ? 2.0 : 3.0;
    final topStrip = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.20),
        width: w * 0.46,
        height: stripHeight,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(topStrip, glowPaint);
    canvas.drawRRect(topStrip, hotPaint);

    final lampRadius = stage == _BombHeroStage.stable ? 2.2 : 3.0;
    for (final center in [
      Offset(w * 0.24, h * 0.23),
      Offset(w * 0.76, h * 0.23),
      Offset(w * 0.18, h * 0.60),
      Offset(w * 0.82, h * 0.60),
    ]) {
      canvas.drawCircle(center, lampRadius + 8, glowPaint);
      canvas.drawCircle(center, lampRadius, hotPaint);
    }

    if (stage == _BombHeroStage.critical) {
      final warningBand = Paint()
        ..color = color.withValues(alpha: warningOpacity * 0.42)
        ..blendMode = BlendMode.plus
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.51),
            width: w * 0.78,
            height: h * 0.52,
          ),
          const Radius.circular(18),
        ),
        warningBand,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BombHeroLightOverlayPainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.color != color ||
        oldDelegate.glowOpacity != glowOpacity ||
        oldDelegate.warningOpacity != warningOpacity;
  }
}

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
      return _LedText('OFF', color: color, fontSize: 27);
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

class _ResultOverlay extends StatelessWidget {
  final GameController controller;
  final VoidCallback onRestart;

  const _ResultOverlay({required this.controller, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    final success = controller.status == GameStatus.success;
    final visuals = _ResultVisuals.forState(
      success: success,
      korean: AppText.isKo,
    );
    final strings = _ResultStrings.current;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final compact = screenHeight < 760;
        final short = screenHeight < 680;
        final tight = screenHeight < 620;
        final layoutScale = math
            .min(screenWidth / 360.0, screenHeight / 800.0)
            .clamp(0.76, 1.0)
            .toDouble();
        final horizontalInset = (screenWidth * 0.055)
            .clamp(12.0, 22.0)
            .toDouble();
        final verticalInset = (screenHeight * 0.014)
            .clamp(6.0, compact ? 10.0 : 14.0)
            .toDouble();
        final compositionWidth = (screenWidth * 0.90)
            .clamp(292.0, 354.0)
            .toDouble();
        final maxCompositionHeight = math.max(
          0.0,
          screenHeight - verticalInset * 2,
        );
        final compositionFactor = tight
            ? 0.70
            : (short ? 0.68 : (compact ? 0.64 : 0.60));
        final preferredCompositionHeight =
            (compositionWidth * (success ? 1.18 : 1.24))
                .clamp(360.0, success ? 420.0 : 440.0)
                .toDouble();
        final compositionHeight = math
            .min(
              preferredCompositionHeight,
              math.min(maxCompositionHeight, screenHeight * compositionFactor),
            )
            .toDouble();
        final compositionAlignment = Alignment(
          0,
          success
              ? (tight ? 0.38 : (short ? 0.52 : 0.74))
              : (tight ? 0.34 : (short ? 0.48 : 0.70)),
        );

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final compositionScale = 0.97 + value * 0.03;
            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.black),
                _ResultBackgroundLayer(visuals: visuals, opacity: value),
                ModalBarrier(
                  color: Colors.black.withValues(
                    alpha: visuals.barrierOpacity * value,
                  ),
                  dismissible: false,
                ),
                _ResultAtmosphereLayer(visuals: visuals, opacity: value),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalInset,
                    vertical: verticalInset,
                  ),
                  child: Align(
                    alignment: compositionAlignment,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: visuals.panelShadowOpacity * value,
                            ),
                            blurRadius: success ? 38 : 46,
                            spreadRadius: success ? 6 : 3,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: compositionWidth,
                        height: compositionHeight,
                        child: Transform.scale(
                          scale: compositionScale,
                          child: Opacity(
                            opacity: value,
                            child: _ResultComposition(
                              visuals: visuals,
                              strings: strings,
                              answer: controller.answer.join(),
                              attempts: '${controller.history.length}',
                              time: formatSeconds(controller.elapsedSeconds),
                              layoutScale: layoutScale,
                              tight: tight,
                              onRestart: onRestart,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _FailureResultOverlay extends StatefulWidget {
  final GameController controller;
  final VoidCallback onRestart;

  const _FailureResultOverlay({
    required this.controller,
    required this.onRestart,
  });

  @override
  State<_FailureResultOverlay> createState() => _FailureResultOverlayState();
}

class _FailureResultOverlayState extends State<_FailureResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2050),
    )..forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _skipReveal() {
    if (!_revealController.isCompleted) {
      _revealController.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visuals = _ResultVisuals.forState(
      success: false,
      korean: AppText.isKo,
    );
    final strings = _ResultStrings.current;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final compact = screenHeight < 760;
        final short = screenHeight < 680;
        final tight = screenHeight < 620;
        final layoutScale = math
            .min(screenWidth / 360.0, screenHeight / 800.0)
            .clamp(0.74, 1.0)
            .toDouble();
        final horizontalInset = (screenWidth * 0.052)
            .clamp(10.0, 20.0)
            .toDouble();
        final verticalInset = (screenHeight * 0.012)
            .clamp(5.0, compact ? 9.0 : 12.0)
            .toDouble();
        final compositionWidth = (screenWidth * 0.90)
            .clamp(292.0, 350.0)
            .toDouble();
        final maxCompositionHeight = math.max(
          0.0,
          screenHeight - verticalInset * 2,
        );
        final compositionFactor = tight
            ? 0.78
            : (short ? 0.76 : (compact ? 0.73 : 0.68));
        final preferredCompositionHeight = (compositionWidth * 1.46)
            .clamp(398.0, 492.0)
            .toDouble();
        final compositionHeight = math
            .min(
              preferredCompositionHeight,
              math.min(maxCompositionHeight, screenHeight * compositionFactor),
            )
            .toDouble();
        final compositionAlignment = Alignment(
          0,
          tight ? 0.38 : (short ? 0.54 : 0.72),
        );

        return AnimatedBuilder(
          animation: _revealController,
          builder: (context, child) {
            final value = _revealController.value;
            final shakeValue = _timelineValue(
              value,
              0.0,
              0.14,
              Curves.easeOutCubic,
            );
            final shakeStrength = (1 - shakeValue) * 5.5 * layoutScale;
            final shakeOffset = Offset(
              math.sin(value * math.pi * 34) * shakeStrength,
              math.cos(value * math.pi * 27) * shakeStrength * 0.42,
            );
            const backgroundValue = 1.0;
            final flickerIn = _timelineValue(
              value,
              0.0,
              0.04,
              Curves.easeOutCubic,
            );
            final flickerOut =
                1 - _timelineValue(value, 0.64, 0.68, Curves.easeOutCubic);
            final flicker = math.pow(
              math.max(0.0, math.sin(value * math.pi * 18)),
              1.7,
            );
            final backgroundPulse = (flickerIn * flickerOut * flicker)
                .clamp(0.0, 1.0)
                .toDouble();
            final panelValue = _timelineValue(
              value,
              0.0,
              0.18,
              Curves.easeOutCubic,
            );
            final titleValue = _timelineValue(
              value,
              0.0,
              0.18,
              Curves.easeOutBack,
            );
            final statsValue = _timelineValue(
              value,
              0.0,
              0.18,
              Curves.easeOutCubic,
            );
            final buttonsValue = _timelineValue(
              value,
              0.0,
              0.18,
              Curves.easeOutCubic,
            );
            final backgroundLift = Offset(0, -screenHeight * 0.092);
            final revealing = !_revealController.isCompleted;

            return Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Colors.black),
                Transform.translate(
                  offset: shakeOffset + backgroundLift,
                  child: Transform.scale(
                    scale: 1.08,
                    alignment: Alignment.topCenter,
                    child: ColorFiltered(
                      colorFilter: _impactColorFilter(backgroundPulse),
                      child: _ResultBackgroundLayer(
                        visuals: visuals,
                        opacity: backgroundValue,
                      ),
                    ),
                  ),
                ),
                _ExplosionFlickerOverlay(opacity: backgroundPulse),
                ModalBarrier(
                  color: Colors.black.withValues(
                    alpha: visuals.barrierOpacity * backgroundValue,
                  ),
                  dismissible: false,
                ),
                Transform.translate(
                  offset: shakeOffset,
                  child: _ResultAtmosphereLayer(
                    visuals: visuals,
                    opacity: backgroundValue,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalInset,
                    vertical: verticalInset,
                  ),
                  child: Align(
                    alignment: compositionAlignment,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: visuals.panelShadowOpacity * panelValue,
                            ),
                            blurRadius: 42,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: compositionWidth,
                        height: compositionHeight,
                        child: _FailureResultComposition(
                          visuals: visuals,
                          strings: strings,
                          answer: widget.controller.answer.join(),
                          layoutScale: layoutScale,
                          tight: tight,
                          panelOpacity: panelValue,
                          panelSlide: (1 - panelValue) * 18.0 * layoutScale,
                          revealShadeOpacity: (1 - panelValue) * 0.42,
                          titleOpacity: titleValue.clamp(0.0, 1.0).toDouble(),
                          titleScale: (0.89 + titleValue * 0.07)
                              .clamp(0.89, 0.96)
                              .toDouble(),
                          statsOpacity: statsValue,
                          buttonsOpacity: buttonsValue,
                          actionsEnabled: !revealing,
                          onRestart: widget.onRestart,
                        ),
                      ),
                    ),
                  ),
                ),
                if (revealing)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _skipReveal,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

double _timelineValue(double value, double begin, double end, Curve curve) {
  final normalized = ((value - begin) / (end - begin))
      .clamp(0.0, 1.0)
      .toDouble();
  return curve.transform(normalized);
}

ColorFilter _impactColorFilter(double pulse) {
  final contrast = 1.0 + pulse * 0.42;
  final brightness = pulse * 58.0;
  final intercept = 128.0 * (1.0 - contrast) + brightness;

  return ColorFilter.matrix([
    contrast,
    0,
    0,
    0,
    intercept,
    0,
    contrast,
    0,
    0,
    intercept,
    0,
    0,
    contrast,
    0,
    intercept,
    0,
    0,
    0,
    1,
    0,
  ]);
}

class _ExplosionFlickerOverlay extends StatelessWidget {
  final double opacity;

  const _ExplosionFlickerOverlay({required this.opacity});

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.28),
                  radius: 0.78,
                  colors: [
                    const Color(0xFFFFF0B8).withValues(alpha: 0.34),
                    const Color(0xFFFF6A20).withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.34, 1.0],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    const Color(0xFFFF3B18).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultVisuals {
  final bool success;
  final String backgroundAsset;
  final String panelAsset;
  final String titleAsset;
  final String fallbackTitle;
  final String fallbackSubtitle;
  final Color accent;
  final Color softAccent;
  final double backgroundOpacity;
  final double barrierOpacity;
  final double panelShadowOpacity;

  const _ResultVisuals({
    required this.success,
    required this.backgroundAsset,
    required this.panelAsset,
    required this.titleAsset,
    required this.fallbackTitle,
    required this.fallbackSubtitle,
    required this.accent,
    required this.softAccent,
    required this.backgroundOpacity,
    required this.barrierOpacity,
    required this.panelShadowOpacity,
  });

  static _ResultVisuals forState({
    required bool success,
    required bool korean,
  }) {
    return _ResultVisuals(
      success: success,
      backgroundAsset: GameAssetPaths.resultBackground(success: success),
      panelAsset: GameAssetPaths.resultPanel(success: success),
      titleAsset: GameAssetPaths.resultTitle(success: success, korean: korean),
      fallbackTitle: success
          ? (korean ? '\uBBF8\uC158 \uC131\uACF5' : 'MISSION COMPLETE')
          : (korean ? '\uBBF8\uC158 \uC2E4\uD328' : 'MISSION FAILED'),
      fallbackSubtitle: success
          ? (korean
                ? '\uC7A5\uCE58 \uD574\uC81C \uC131\uACF5'
                : 'DEVICE DEFUSED')
          : (korean
                ? '\uC7A5\uCE58\uAC00 \uD3ED\uBC1C\uD588\uC2B5\uB2C8\uB2E4'
                : 'DEVICE DETONATED'),
      accent: success ? const Color(0xFF38F7D2) : const Color(0xFFFF493D),
      softAccent: success ? const Color(0xFFE5FCFF) : const Color(0xFFFFC6AE),
      backgroundOpacity: success ? 0.94 : 1.0,
      barrierOpacity: success ? 0.14 : 0.10,
      panelShadowOpacity: success ? 0.64 : 0.78,
    );
  }
}

class _ResultStrings {
  final String answer;
  final String attempts;
  final String time;
  final String tryAgain;
  final String home;

  const _ResultStrings({
    required this.answer,
    required this.attempts,
    required this.time,
    required this.tryAgain,
    required this.home,
  });

  static _ResultStrings get current => AppText.isKo ? ko : en;

  static const en = _ResultStrings(
    answer: 'Answer',
    attempts: 'Attempts',
    time: 'Time',
    tryAgain: 'Try Again',
    home: 'Home',
  );

  static const ko = _ResultStrings(
    answer: '\uC815\uB2F5',
    attempts: '\uC2DC\uB3C4 \uD69F\uC218',
    time: '\uC2DC\uAC04',
    tryAgain: '\uB2E4\uC2DC \uC2DC\uB3C4',
    home: '\uD648\uC73C\uB85C',
  );
}

class _ResultBackgroundLayer extends StatelessWidget {
  final _ResultVisuals visuals;
  final double opacity;

  const _ResultBackgroundLayer({required this.visuals, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: visuals.backgroundOpacity * opacity,
          child: Image.asset(
            visuals.backgroundAsset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.35),
                    radius: 1.0,
                    colors: [
                      visuals.accent.withValues(alpha: 0.18),
                      const Color(0xFF151515),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.48, 1.0],
                  ),
                ),
              );
            },
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.08 * opacity),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.52 * opacity),
              ],
              stops: const [0.0, 0.44, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultAtmosphereLayer extends StatelessWidget {
  final _ResultVisuals visuals;
  final double opacity;

  const _ResultAtmosphereLayer({required this.visuals, required this.opacity});

  @override
  Widget build(BuildContext context) {
    final accent = visuals.accent;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.20),
                radius: 0.94,
                colors: [
                  accent.withValues(
                    alpha: (visuals.success ? 0.18 : 0.13) * opacity,
                  ),
                  Colors.transparent,
                  Colors.black.withValues(
                    alpha: (visuals.success ? 0.25 : 0.16) * opacity,
                  ),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.72),
            child: FractionallySizedBox(
              widthFactor: 0.98,
              heightFactor: 0.36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.70 * opacity),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FailureResultComposition extends StatelessWidget {
  final _ResultVisuals visuals;
  final _ResultStrings strings;
  final String answer;
  final double layoutScale;
  final bool tight;
  final double panelOpacity;
  final double panelSlide;
  final double revealShadeOpacity;
  final double titleOpacity;
  final double titleScale;
  final double statsOpacity;
  final double buttonsOpacity;
  final bool actionsEnabled;
  final VoidCallback onRestart;

  const _FailureResultComposition({
    required this.visuals,
    required this.strings,
    required this.answer,
    required this.layoutScale,
    required this.tight,
    required this.panelOpacity,
    required this.panelSlide,
    required this.revealShadeOpacity,
    required this.titleOpacity,
    required this.titleScale,
    required this.statsOpacity,
    required this.buttonsOpacity,
    required this.actionsEnabled,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final titleTop = height * (tight ? 0.122 : 0.148);
        final titleHeight = height * (tight ? 0.328 : 0.354);
        final titleInset = (width * 0.025).clamp(8.0, 14.0).toDouble();
        final contentTop = height * (tight ? 0.466 : 0.500);
        final contentBottom = height * (tight ? 0.045 : 0.055);
        final contentInset = (width * 0.145).clamp(36.0, 50.0).toDouble();

        return Transform.translate(
          offset: Offset(0, panelSlide),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: panelOpacity,
                child: Image.asset(
                  visuals.panelAsset,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return CustomPaint(
                      painter: _ResultPanelFallbackPainter(visuals: visuals),
                    );
                  },
                ),
              ),
              Positioned(
                top: titleTop,
                left: titleInset,
                right: titleInset,
                height: titleHeight,
                child: Opacity(
                  opacity: titleOpacity,
                  child: Transform.scale(
                    scale: titleScale,
                    child: _ResultTitleImage(visuals: visuals),
                  ),
                ),
              ),
              Positioned(
                top: contentTop,
                left: contentInset,
                right: contentInset,
                bottom: contentBottom,
                child: _FailureResultDynamicLayer(
                  visuals: visuals,
                  strings: strings,
                  answer: answer,
                  layoutScale: layoutScale,
                  statsOpacity: statsOpacity,
                  buttonsOpacity: buttonsOpacity,
                  actionsEnabled: actionsEnabled,
                  onRestart: onRestart,
                ),
              ),
              if (revealShadeOpacity > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(
                              alpha: revealShadeOpacity * 0.78,
                            ),
                            Colors.black.withValues(alpha: revealShadeOpacity),
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

class _ResultComposition extends StatelessWidget {
  final _ResultVisuals visuals;
  final _ResultStrings strings;
  final String answer;
  final String attempts;
  final String time;
  final double layoutScale;
  final bool tight;
  final VoidCallback onRestart;

  const _ResultComposition({
    required this.visuals,
    required this.strings,
    required this.answer,
    required this.attempts,
    required this.time,
    required this.layoutScale,
    required this.tight,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final titleTop = height * (tight ? 0.034 : 0.040);
        final titleHeight = height * (tight ? 0.318 : 0.340);
        final titleInset = (width * 0.030).clamp(8.0, 16.0).toDouble();
        final contentTop =
            titleTop + titleHeight + height * (tight ? 0.000 : 0.008);
        final contentBottom = height * (tight ? 0.040 : 0.050);
        final contentInset = (width * 0.125).clamp(34.0, 46.0).toDouble();

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              visuals.panelAsset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return CustomPaint(
                  painter: _ResultPanelFallbackPainter(visuals: visuals),
                );
              },
            ),
            Positioned(
              top: titleTop,
              left: titleInset,
              right: titleInset,
              height: titleHeight,
              child: _ResultTitleImage(visuals: visuals),
            ),
            Positioned(
              top: contentTop,
              left: contentInset,
              right: contentInset,
              bottom: contentBottom,
              child: _ResultDynamicLayer(
                visuals: visuals,
                strings: strings,
                answer: answer,
                attempts: attempts,
                time: time,
                layoutScale: layoutScale,
                onRestart: onRestart,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultTitleImage extends StatelessWidget {
  final _ResultVisuals visuals;

  const _ResultTitleImage({required this.visuals});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      visuals.titleAsset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return _ResultTitleFallback(visuals: visuals);
      },
    );
  }
}

class _ResultTitleFallback extends StatelessWidget {
  final _ResultVisuals visuals;

  const _ResultTitleFallback({required this.visuals});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            visuals.fallbackTitle,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: visuals.accent,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              shadows: [
                Shadow(
                  color: visuals.accent.withValues(alpha: 0.65),
                  blurRadius: 12,
                ),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            visuals.fallbackSubtitle,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: visuals.softAccent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FailureResultDynamicLayer extends StatelessWidget {
  final _ResultVisuals visuals;
  final _ResultStrings strings;
  final String answer;
  final double layoutScale;
  final double statsOpacity;
  final double buttonsOpacity;
  final bool actionsEnabled;
  final VoidCallback onRestart;

  const _FailureResultDynamicLayer({
    required this.visuals,
    required this.strings,
    required this.answer,
    required this.layoutScale,
    required this.statsOpacity,
    required this.buttonsOpacity,
    required this.actionsEnabled,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final scale = math
            .min(layoutScale, math.min(width / 245.0, height / 250.0))
            .clamp(0.72, 1.0)
            .toDouble();
        final availableHeight = height;
        final primaryButtonHeight = (availableHeight * 0.188)
            .clamp(40.0, 48.0)
            .toDouble();
        final secondaryButtonHeight = (availableHeight * 0.174)
            .clamp(37.0, 44.0)
            .toDouble();
        final buttonGap = (availableHeight * 0.055).clamp(9.0, 12.0).toDouble();
        final statsGap = (availableHeight * 0.105).clamp(16.0, 28.0).toDouble();
        final statsHeight = math
            .min(availableHeight * 0.290, 76.0)
            .clamp(58.0, 76.0)
            .toDouble();
        final topPad = math
            .max(
              0.0,
              (availableHeight -
                      statsHeight -
                      statsGap -
                      primaryButtonHeight -
                      secondaryButtonHeight -
                      buttonGap) *
                  0.22,
            )
            .toDouble();
        final primaryButtonPadding = EdgeInsets.symmetric(
          horizontal: (primaryButtonHeight * 0.72).clamp(26.0, 36.0).toDouble(),
          vertical: (primaryButtonHeight * 0.19).clamp(7.0, 12.0).toDouble(),
        );
        final secondaryButtonPadding = EdgeInsets.symmetric(
          horizontal: (secondaryButtonHeight * 0.72)
              .clamp(24.0, 34.0)
              .toDouble(),
          vertical: (secondaryButtonHeight * 0.20).clamp(6.0, 11.0).toDouble(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topPad),
            Opacity(
              opacity: statsOpacity,
              child: SizedBox(
                height: statsHeight,
                child: _FailureCodePanel(
                  visuals: visuals,
                  code: answer,
                  scale: scale,
                ),
              ),
            ),
            SizedBox(height: statsGap),
            IgnorePointer(
              ignoring: !actionsEnabled,
              child: Opacity(
                opacity: buttonsOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ModalActionButton(
                      assetPath: GameAssetPaths.resultButtonPrimary,
                      label: strings.tryAgain,
                      height: primaryButtonHeight,
                      padding: primaryButtonPadding,
                      onTap: onRestart,
                    ),
                    SizedBox(height: buttonGap),
                    _ModalActionButton(
                      assetPath: GameAssetPaths.resultButtonSecondary,
                      label: strings.home,
                      height: secondaryButtonHeight,
                      padding: secondaryButtonPadding,
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FailureCodePanel extends StatelessWidget {
  final _ResultVisuals visuals;
  final String code;
  final double scale;

  const _FailureCodePanel({
    required this.visuals,
    required this.code,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        border: Border.all(
          color: visuals.accent.withValues(alpha: 0.44),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: visuals.accent.withValues(alpha: 0.12),
            blurRadius: 12 * scale,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 5 * scale,
        ),
        child: Center(
          child: Transform.translate(
            offset: Offset(-4.0 * scale, 0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(-3.5 * scale, -0.5 * scale),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: visuals.accent.withValues(alpha: 0.20),
                            blurRadius: 10 * scale,
                            spreadRadius: -2 * scale,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.08),
                            blurRadius: 6 * scale,
                            spreadRadius: -3 * scale,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 63 * scale,
                        height: 63 * scale,
                        child: Image.asset(
                          GameAssetPaths.resultKeyIcon,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 7 * scale),
                  Transform.translate(
                    offset: Offset(-4.0 * scale, 0),
                    child: Text(
                      code,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 51 * scale,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0 * scale,
                        shadows: [
                          Shadow(
                            color: visuals.accent.withValues(alpha: 0.42),
                            blurRadius: 12,
                          ),
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
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
}

class _ResultDynamicLayer extends StatelessWidget {
  final _ResultVisuals visuals;
  final _ResultStrings strings;
  final String answer;
  final String attempts;
  final String time;
  final double layoutScale;
  final VoidCallback onRestart;

  const _ResultDynamicLayer({
    required this.visuals,
    required this.strings,
    required this.answer,
    required this.attempts,
    required this.time,
    required this.layoutScale,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layerScale = math
            .min(constraints.maxWidth / 260.0, constraints.maxHeight / 235.0)
            .clamp(0.76, 1.0)
            .toDouble();
        final scale = math
            .min(layoutScale, layerScale)
            .clamp(0.76, 1.0)
            .toDouble();
        final gap = (constraints.maxHeight * 0.024).clamp(5.0, 8.0).toDouble();
        final topGap = (constraints.maxHeight * 0.012)
            .clamp(0.0, 5.0)
            .toDouble();
        final buttonHeight = (44.0 * scale).clamp(38.0, 44.0).toDouble();

        return Column(
          children: [
            SizedBox(height: topGap),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: constraints.maxWidth,
                child: _ResultStatsGrid(
                  visuals: visuals,
                  scale: scale,
                  rows: [
                    _ResultStatData(label: strings.answer, value: answer),
                    _ResultStatData(label: strings.attempts, value: attempts),
                    _ResultStatData(label: strings.time, value: time),
                  ],
                ),
              ),
            ),
            SizedBox(height: gap * 1.4),
            Column(
              children: [
                _ModalActionButton(
                  assetPath: GameAssetPaths.modalPrimaryButton,
                  label: strings.tryAgain,
                  height: buttonHeight,
                  onTap: onRestart,
                ),
                SizedBox(height: gap),
                _ModalActionButton(
                  assetPath: GameAssetPaths.modalSecondaryButton,
                  label: strings.home,
                  height: buttonHeight,
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
}

class _ResultStatData {
  final String label;
  final String value;

  const _ResultStatData({required this.label, required this.value});
}

class _ResultStatsGrid extends StatelessWidget {
  final _ResultVisuals visuals;
  final double scale;
  final List<_ResultStatData> rows;

  const _ResultStatsGrid({
    required this.visuals,
    required this.scale,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: visuals.success ? 0.38 : 0.46),
        border: Border.all(
          color: visuals.accent.withValues(
            alpha: visuals.success ? 0.25 : 0.34,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: visuals.accent.withValues(
              alpha: visuals.success ? 0.07 : 0.10,
            ),
            blurRadius: 10 * scale,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10 * scale,
          vertical: 5 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              _ResultStatRow(
                data: rows[index],
                scale: scale,
                accent: visuals.accent,
              ),
              if (index != rows.length - 1)
                _ResultStatDivider(accent: visuals.accent),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultStatDivider extends StatelessWidget {
  final Color accent;

  const _ResultStatDivider({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(color: accent.withValues(alpha: 0.18)),
      ),
    );
  }
}

class _ResultStatRow extends StatelessWidget {
  final _ResultStatData data;
  final double scale;
  final Color accent;

  const _ResultStatRow({
    required this.data,
    required this.scale,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (31 * scale).clamp(24.0, 31.0).toDouble(),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                data.label.toUpperCase(),
                maxLines: 1,
                style: TextStyle(
                  color: const Color(0xD8FFFFFF),
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                data.value,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  shadows: [
                    Shadow(
                      color: accent.withValues(alpha: 0.34),
                      blurRadius: 8,
                    ),
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanelFallbackPainter extends CustomPainter {
  final _ResultVisuals visuals;

  const _ResultPanelFallbackPainter({required this.visuals});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width * 0.92, 0)
      ..lineTo(size.width, size.height * 0.08)
      ..lineTo(size.width, size.height * 0.92)
      ..lineTo(size.width * 0.92, size.height)
      ..lineTo(size.width * 0.08, size.height)
      ..lineTo(0, size.height * 0.92)
      ..lineTo(0, size.height * 0.08)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xF2242529), Color(0xF508090B)],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = visuals.accent.withValues(alpha: 0.62),
    );
    final inner = rect.deflate(11);
    canvas.drawRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.14),
    );
  }

  @override
  bool shouldRepaint(covariant _ResultPanelFallbackPainter oldDelegate) {
    return oldDelegate.visuals != visuals;
  }
}

class _ModalActionButton extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;
  final double height;
  final EdgeInsetsGeometry? padding;

  const _ModalActionButton({
    required this.assetPath,
    required this.label,
    required this.onTap,
    this.height = 52,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 34, vertical: 12);
    final labelWidget = _ModalButtonLabel(label);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: AssetFrame(
          assetPath: assetPath,
          padding: resolvedPadding,
          child: labelWidget,
        ),
      ),
    );
  }
}

class _ModalButtonLabel extends StatelessWidget {
  final String label;

  const _ModalButtonLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          shadows: [
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
