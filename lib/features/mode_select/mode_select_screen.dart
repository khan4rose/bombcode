import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/widgets/app_background.dart';
import '../../data/local_game_config_repository.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/models/game_config.dart';
import '../game/game_screen.dart';

const _attemptValues = [0, 7, 10, 13, 15, 20];
const _timeValues = [0, 5, 10, 20];

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  final _configRepository = LocalGameConfigRepository();
  Difficulty _difficulty = Difficulty.normal;
  int _attempts = 0;
  int _timeIndex = 0;
  bool _autoCheckTable = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLastConfig());
  }

  void _applyDifficultyDefaults(Difficulty difficulty) {
    final defaults = GameConfig.defaults(difficulty);
    _difficulty = difficulty;
    _attempts = _nearestValue(_attemptValues, defaults.maxAttempts ?? 0);
    _timeIndex = 0;
    _autoCheckTable = defaults.autoCheckTable;
  }

  GameConfig get _config {
    final defaults = GameConfig.defaults(_difficulty);
    final timeMinutes = _timeValues[_timeIndex];
    return GameConfig.fromLimits(
      difficulty: _difficulty,
      codeLength: defaults.codeLength,
      maxAttempts: _attempts == 0 ? null : _attempts,
      timeLimit: timeMinutes == 0 ? null : Duration(minutes: timeMinutes),
      autoCheckTable: _autoCheckTable,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;
            final horizontalPadding = (width * 0.055).clamp(16.0, 24.0);
            final verticalPadding = (height * 0.012).clamp(8.0, 12.0);
            final topToDifficultyGap = (height * 0.022).clamp(13.0, 18.0);
            final sectionGap = (height * 0.03).clamp(18.0, 26.0);
            final limitSectionGap = (sectionGap * 2).clamp(36.0, 52.0);
            final topHeight = (height * 0.12).clamp(78.0, 98.0);
            final difficultyHeight = (height * 0.098).clamp(60.0, 78.0);
            final summaryHeight = (height * 0.148).clamp(90.0, 122.0);
            final limitHeight = (height * 0.335).clamp(220.0, 270.0);
            final startButtonHeight = (height * 0.082).clamp(44.0, 68.0);

            return Stack(
              fit: StackFit.expand,
              children: [
                const AppBackground(dim: true, child: SizedBox.expand()),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: topHeight,
                            child: Center(
                              child: _TopBar(
                                onBack: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                          SizedBox(height: topToDifficultyGap),
                          SizedBox(
                            height: difficultyHeight,
                            child: _DifficultySelector(
                              selected: _difficulty,
                              onChanged: (difficulty) => setState(
                                () => _applyDifficultyDefaults(difficulty),
                              ),
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          SizedBox(
                            height: summaryHeight,
                            child: _DifficultySummary(config: config),
                          ),
                          SizedBox(height: limitSectionGap),
                          SizedBox(
                            height: limitHeight,
                            child: _LimitModePanel(
                              attempts: _attempts,
                              timeIndex: _timeIndex,
                              onAttemptsChanged: (value) =>
                                  setState(() => _attempts = value),
                              onTimeChanged: (value) =>
                                  setState(() => _timeIndex = value),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: const Alignment(0, 0.35),
                              child: _StartMissionButton(
                                height: startButtonHeight,
                                onPressed: () => _startMission(config),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadLastConfig() async {
    final config = await _configRepository.loadLastConfig();
    if (!mounted) {
      return;
    }
    setState(() => _applyConfig(config));
  }

  void _applyConfig(GameConfig config) {
    _difficulty = config.difficulty;
    _attempts = _nearestValue(_attemptValues, config.maxAttempts ?? 0);
    final minutes = config.timeLimit?.inMinutes ?? 0;
    _timeIndex = _indexForValue(_timeValues, minutes);
    _autoCheckTable = config.autoCheckTable;
  }

  Future<void> _startMission(GameConfig config) async {
    await _configRepository.saveLastConfig(config);
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => GameScreen(config: config)));
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: const Alignment(0.96, 0.74),
          child: _ImageButton(
            assetName: 'back_button.png',
            onTap: onBack,
            icon: Icons.chevron_left_rounded,
            size: 38,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppText.missionSetup.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
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
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AppText.setChallenge.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;

  const _DifficultySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(AppText.difficulty),
        const SizedBox(height: 12),
        Expanded(
          child: FractionallySizedBox(
            widthFactor: 0.94,
            child: Row(
              children: [
                for (final difficulty in Difficulty.values)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: _DifficultyButton(
                        difficulty: difficulty,
                        selected: selected == difficulty,
                        onTap: () => onChanged(difficulty),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final Difficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseName = switch (difficulty) {
      Difficulty.beginner => 'difficulty_beginner',
      Difficulty.normal => 'difficulty_normal',
      Difficulty.expert => 'difficulty_expert',
    };

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _MissionAsset(
            name: '${baseName}_${selected ? 'on' : 'off'}.png',
            fit: BoxFit.fill,
            fallback: _MetalFrame(active: selected),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _difficultyIcon(difficulty),
                      color: selected ? Colors.white : Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      AppText.difficultyLabel(difficulty.name).toUpperCase(),
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
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

  IconData _difficultyIcon(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.beginner => Icons.gps_fixed_rounded,
      Difficulty.normal => Icons.adjust_rounded,
      Difficulty.expert => Icons.radar_rounded,
    };
  }
}

class _DifficultySummary extends StatelessWidget {
  final GameConfig config;

  const _DifficultySummary({required this.config});

  @override
  Widget build(BuildContext context) {
    final reward = switch (config.difficulty) {
      Difficulty.beginner => 100,
      Difficulty.normal => 200,
      Difficulty.expert => 300,
    };
    final timeText = config.timeLimit == null
        ? AppText.off.toUpperCase()
        : _formatTimeLimit(config.timeLimit!.inMinutes);
    final attemptsText = config.maxAttempts == null
        ? AppText.off.toUpperCase()
        : '${config.maxAttempts} ${AppText.tries}'.toUpperCase();

    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryColumn(
              assetName: 'digits_icon.png',
              fallbackIcon: Icons.layers_rounded,
              color: Colors.lightGreenAccent,
              line1: '${config.codeLength} ${AppText.digits}'.toUpperCase(),
              line2: attemptsText,
            ),
          ),
          const _ThinDivider(),
          Expanded(
            child: _SummaryColumn(
              assetName: 'timer_icon.png',
              fallbackIcon: Icons.timer_rounded,
              color: Colors.lightBlueAccent,
              line1: AppText.timeLimit.toUpperCase(),
              line2: timeText,
            ),
          ),
          const _ThinDivider(),
          Expanded(
            child: _SummaryColumn(
              assetName: 'reward_icon.png',
              fallbackIcon: Icons.stars_rounded,
              color: Colors.amberAccent,
              line1: AppText.reward.toUpperCase(),
              line2: '$reward',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String assetName;
  final IconData fallbackIcon;
  final Color color;
  final String line1;
  final String line2;

  const _SummaryColumn({
    required this.assetName,
    required this.fallbackIcon,
    required this.color,
    required this.line1,
    required this.line2,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: _MissionAsset(
              name: assetName,
              fallback: Icon(fallbackIcon, color: color, size: 40),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            line1,
            style: TextStyle(
              color: color,
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            line2,
            style: TextStyle(
              color: color,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitModePanel extends StatelessWidget {
  final int attempts;
  final int timeIndex;
  final ValueChanged<int> onAttemptsChanged;
  final ValueChanged<int> onTimeChanged;

  const _LimitModePanel({
    required this.attempts,
    required this.timeIndex,
    required this.onAttemptsChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final attemptIndex = _indexForValue(_attemptValues, attempts);
    final timeIndex = this.timeIndex.clamp(0, _timeValues.length - 1).toInt();
    final attemptTicks = [
      for (final value in _attemptValues) _formatAttemptsLimit(value),
    ];
    final timeTicks = [
      for (final value in _timeValues) _formatTimeLimit(value),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(AppText.limitMode),
        const SizedBox(height: 5),
        Expanded(
          child: _Panel(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 9),
            child: Column(
              children: [
                Expanded(
                  child: _CompactSliderRow(
                    fallbackIcon: Icons.shield_outlined,
                    title: AppText.attemptsLimit,
                    valueText: _formatAttemptsValue(
                      _attemptValues[attemptIndex],
                    ),
                    selectedIndex: attemptIndex,
                    ticks: attemptTicks,
                    onMinus: () => onAttemptsChanged(
                      _attemptValues[(attemptIndex - 1)
                          .clamp(0, _attemptValues.length - 1)
                          .toInt()],
                    ),
                    onPlus: () => onAttemptsChanged(
                      _attemptValues[(attemptIndex + 1)
                          .clamp(0, _attemptValues.length - 1)
                          .toInt()],
                    ),
                    onChanged: (index) =>
                        onAttemptsChanged(_attemptValues[index]),
                  ),
                ),
                const SizedBox(height: 5),
                const Divider(height: 1, color: Colors.white12),
                const SizedBox(height: 5),
                Expanded(
                  child: _CompactSliderRow(
                    fallbackIcon: Icons.timer_outlined,
                    title: AppText.timeLimit,
                    valueText: _formatTimeLimit(_timeValues[timeIndex]),
                    selectedIndex: timeIndex,
                    ticks: timeTicks,
                    onMinus: () => onTimeChanged(
                      (timeIndex - 1).clamp(0, _timeValues.length - 1).toInt(),
                    ),
                    onPlus: () => onTimeChanged(
                      (timeIndex + 1).clamp(0, _timeValues.length - 1).toInt(),
                    ),
                    onChanged: onTimeChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactSliderRow extends StatelessWidget {
  final IconData fallbackIcon;
  final String title;
  final String valueText;
  final int selectedIndex;
  final List<String> ticks;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<int> onChanged;

  const _CompactSliderRow({
    required this.fallbackIcon,
    required this.title,
    required this.valueText,
    required this.selectedIndex,
    required this.ticks,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(fallbackIcon, color: Colors.white70, size: 19),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              constraints: const BoxConstraints(minWidth: 60),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF170607),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.45),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  valueText,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _ImageButton(
              assetName: 'minus_button.png',
              onTap: onMinus,
              icon: Icons.remove_rounded,
              size: 30,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: _AssetSlider(
                itemCount: ticks.length,
                selectedIndex: selectedIndex,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 3),
            _ImageButton(
              assetName: 'plus_button.png',
              onTap: onPlus,
              icon: Icons.add_rounded,
              size: 30,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final tick in ticks)
                Text(
                  tick,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StartMissionButton extends StatelessWidget {
  final double height;
  final VoidCallback onPressed;

  const _StartMissionButton({required this.height, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _MissionAsset(
              name: 'start_mission_button.png',
              fit: BoxFit.fill,
              fallback: const _MetalFrame(active: true, red: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppText.startMission.toUpperCase(),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetSlider extends StatelessWidget {
  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _AssetSlider({
    required this.itemCount,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lastIndex = itemCount - 1;
        final percent = lastIndex <= 0 ? 0.0 : selectedIndex / lastIndex;
        final thumbLeft = (constraints.maxWidth - 20) * percent;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              _update(details.localPosition.dx, constraints.maxWidth),
          onHorizontalDragUpdate: (details) =>
              _update(details.localPosition.dx, constraints.maxWidth),
          child: SizedBox(
            height: 30,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  top: 9,
                  bottom: 9,
                  child: _MissionAsset(
                    name: 'slider_track.png',
                    fit: BoxFit.fill,
                    fallback: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 11,
                  height: 8,
                  width: constraints.maxWidth * percent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Color(0x99FF5252), blurRadius: 5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: thumbLeft,
                  top: 2,
                  width: 20,
                  height: 26,
                  child: _MissionAsset(
                    name: 'slider_thumb.png',
                    fit: BoxFit.fill,
                    fallback: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2E31),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _update(double dx, double width) {
    final percent = (dx / width).clamp(0.0, 1.0);
    onChanged(
      (percent * (itemCount - 1)).round().clamp(0, itemCount - 1).toInt(),
    );
  }
}

class _ImageButton extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;
  final IconData icon;
  final double size;

  const _ImageButton({
    required this.assetName,
    required this.onTap,
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _MissionAsset(
              name: assetName,
              fit: BoxFit.fill,
              fallback: const _MetalFrame(active: false),
            ),
            Icon(icon, color: Colors.redAccent, size: size * 0.58),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  static const _style = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
    height: 1.0,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 5, height: 20, color: Colors.redAccent),
        const SizedBox(width: 7),
        Text(label.toUpperCase(), style: _style),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: Colors.white24, height: 1)),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({required this.child, this.padding = const EdgeInsets.all(9)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: double.infinity, color: Colors.white24);
  }
}

class _MissionAsset extends StatelessWidget {
  final String name;
  final BoxFit fit;
  final Widget fallback;

  const _MissionAsset({
    required this.name,
    required this.fallback,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/mission_setup/$name',
      fit: fit,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

class _MetalFrame extends StatelessWidget {
  final bool active;
  final bool red;

  const _MetalFrame({required this.active, this.red = false});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: red || active
            ? const Color(0xFF861918)
            : const Color(0xFF171A1D),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: active ? Colors.redAccent : Colors.white24,
          width: 1.4,
        ),
        boxShadow: active
            ? const [BoxShadow(color: Colors.redAccent, blurRadius: 10)]
            : null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: red || active
              ? const [Color(0xFFB52722), Color(0xFF5D1110)]
              : const [Color(0xFF2A2E32), Color(0xFF0F1113)],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _MetalFallbackBackground extends StatelessWidget {
  const _MetalFallbackBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF30353A), Color(0xFF121518), Color(0xFF08090B)],
        ),
      ),
      child: CustomPaint(painter: _FramePainter()),
    );
  }
}

int _indexForValue(List<int> values, int value) {
  final exactIndex = values.indexOf(value);
  if (exactIndex != -1) {
    return exactIndex;
  }

  var nearestIndex = 0;
  var nearestDistance = (values.first - value).abs();
  for (var i = 1; i < values.length; i++) {
    final distance = (values[i] - value).abs();
    if (distance < nearestDistance) {
      nearestIndex = i;
      nearestDistance = distance;
    }
  }
  return nearestIndex;
}

int _nearestValue(List<int> values, int value) {
  return values[_indexForValue(values, value)];
}

String _formatTimeLimit(int minutes) {
  if (minutes == 0) {
    return AppText.off.toUpperCase();
  }
  return '${minutes.toString().padLeft(2, '0')}:00';
}

String _formatAttemptsLimit(int attempts) {
  if (attempts == 0) {
    return AppText.off.toUpperCase();
  }
  return attempts.toString();
}

String _formatAttemptsValue(int attempts) {
  if (attempts == 0) {
    return AppText.off.toUpperCase();
  }
  return '$attempts ${AppText.tries}'.toUpperCase();
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white24;
    final redPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.redAccent.withValues(alpha: 0.45);
    final rect = Rect.fromLTWH(14, 14, size.width - 28, size.height - 28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(8), const Radius.circular(14)),
      redPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
