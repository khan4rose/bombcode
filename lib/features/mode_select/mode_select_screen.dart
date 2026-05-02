import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/widgets/app_background.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/limit_mode.dart';
import '../../domain/models/game_config.dart';
import '../game/game_screen.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  Difficulty _difficulty = Difficulty.beginner;
  int _attempts = 20;
  int _timeIndex = 0;
  double _sound = 0.7;
  double _music = 0.5;
  bool _vibration = true;
  bool _autoCheckTable = true;

  static const _timeValues = [0, 5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    _applyDifficultyDefaults(_difficulty);
  }

  void _applyDifficultyDefaults(Difficulty difficulty) {
    final defaults = GameConfig.defaults(difficulty);
    _difficulty = difficulty;
    _attempts = defaults.maxAttempts ?? 20;
    _timeIndex = 0;
    _autoCheckTable = defaults.autoCheckTable;
  }

  GameConfig get _config {
    final defaults = GameConfig.defaults(_difficulty);
    final timeMinutes = _timeValues[_timeIndex];
    return GameConfig(
      difficulty: _difficulty,
      codeLength: defaults.codeLength,
      maxAttempts: _attempts,
      timeLimit: timeMinutes == 0 ? null : Duration(minutes: timeMinutes),
      limitMode: timeMinutes == 0
          ? LimitMode.attemptsOnly
          : LimitMode.attemptsAndTime,
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
            return Stack(
              fit: StackFit.expand,
              children: [
                const AppBackground(dim: true, child: SizedBox.expand()),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.055,
                    vertical: height * 0.01,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.115,
                        child: _TopBar(
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.105,
                        child: _DifficultySelector(
                          selected: _difficulty,
                          onChanged: (difficulty) => setState(
                            () => _applyDifficultyDefaults(difficulty),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.13,
                        child: _DifficultySummary(config: config),
                      ),
                      SizedBox(
                        height: height * 0.27,
                        child: _LimitModePanel(
                          attempts: _attempts,
                          timeIndex: _timeIndex,
                          onAttemptsChanged: (value) =>
                              setState(() => _attempts = value),
                          onTimeChanged: (value) =>
                              setState(() => _timeIndex = value),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.245,
                        child: _OptionsPanel(
                          sound: _sound,
                          music: _music,
                          vibration: _vibration,
                          autoCheckTable: _autoCheckTable,
                          onSoundChanged: (value) =>
                              setState(() => _sound = value),
                          onMusicChanged: (value) =>
                              setState(() => _music = value),
                          onVibrationChanged: (value) =>
                              setState(() => _vibration = value),
                          onAutoCheckChanged: (value) =>
                              setState(() => _autoCheckTable = value),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: _StartMissionButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GameScreen(config: config),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
          alignment: Alignment.centerLeft,
          child: _ImageButton(
            assetName: 'back_button.png',
            onTap: onBack,
            icon: Icons.chevron_left_rounded,
            size: 52,
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
                  fontSize: 31,
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
                  fontSize: 14,
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
        const SizedBox(height: 6),
        Expanded(
          child: Row(
            children: [
              for (final difficulty in Difficulty.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _difficultyIcon(difficulty),
                  color: selected ? Colors.white : Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppText.difficultyLabel(difficulty.name).toUpperCase(),
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
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

    return _Panel(
      child: Row(
        children: [
          Expanded(
            child: _SummaryColumn(
              assetName: 'digits_icon.png',
              fallbackIcon: Icons.layers_rounded,
              color: Colors.lightGreenAccent,
              line1: '${config.codeLength} ${AppText.digits}'.toUpperCase(),
              line2: '${config.maxAttempts} ${AppText.tries}'.toUpperCase(),
            ),
          ),
          const _ThinDivider(),
          Expanded(
            child: _SummaryColumn(
              assetName: 'timer_icon.png',
              fallbackIcon: Icons.timer_rounded,
              color: Colors.lightBlueAccent,
              line1: AppText.noTimer.toUpperCase(),
              line2: AppText.limitModeLabel(
                config.limitMode.name,
              ).toUpperCase(),
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
            width: 34,
            height: 34,
            child: _MissionAsset(
              name: assetName,
              fallback: Icon(fallbackIcon, color: color, size: 32),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            line1,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            line2,
            style: TextStyle(
              color: color,
              fontSize: 14,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(AppText.limitMode),
        const SizedBox(height: 5),
        Expanded(
          child: _Panel(
            child: Column(
              children: [
                Expanded(
                  child: _CompactSliderRow(
                    fallbackIcon: Icons.shield_outlined,
                    title: AppText.attemptsLimit,
                    valueText: '$attempts ${AppText.tries}'.toUpperCase(),
                    min: 7,
                    max: 20,
                    value: attempts.toDouble(),
                    ticks: const ['7', '10', '15', '20'],
                    onMinus: () =>
                        onAttemptsChanged((attempts - 1).clamp(7, 20).toInt()),
                    onPlus: () =>
                        onAttemptsChanged((attempts + 1).clamp(7, 20).toInt()),
                    onChanged: (value) =>
                        onAttemptsChanged(value.round().clamp(7, 20).toInt()),
                  ),
                ),
                Expanded(
                  child: _CompactSliderRow(
                    fallbackIcon: Icons.timer_outlined,
                    title: AppText.timeLimit,
                    valueText: _timeText,
                    min: 0,
                    max: 4,
                    value: timeIndex.toDouble(),
                    ticks: [
                      AppText.off.toUpperCase(),
                      '05:00',
                      '10:00',
                      '20:00',
                    ],
                    onMinus: () =>
                        onTimeChanged((timeIndex - 1).clamp(0, 4).toInt()),
                    onPlus: () =>
                        onTimeChanged((timeIndex + 1).clamp(0, 4).toInt()),
                    onChanged: (value) =>
                        onTimeChanged(value.round().clamp(0, 4).toInt()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String get _timeText {
    final label = switch (timeIndex) {
      0 => '00:00 ${AppText.off}',
      1 => '05:00',
      2 => '10:00',
      3 => '15:00',
      _ => '20:00',
    };
    return label.toUpperCase();
  }
}

class _OptionsPanel extends StatelessWidget {
  final double sound;
  final double music;
  final bool vibration;
  final bool autoCheckTable;
  final ValueChanged<double> onSoundChanged;
  final ValueChanged<double> onMusicChanged;
  final ValueChanged<bool> onVibrationChanged;
  final ValueChanged<bool> onAutoCheckChanged;

  const _OptionsPanel({
    required this.sound,
    required this.music,
    required this.vibration,
    required this.autoCheckTable,
    required this.onSoundChanged,
    required this.onMusicChanged,
    required this.onVibrationChanged,
    required this.onAutoCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(AppText.options),
        const SizedBox(height: 5),
        Expanded(
          child: _Panel(
            child: Column(
              children: [
                Expanded(
                  child: _VolumeRow(
                    assetName: 'sound_icon.png',
                    fallbackIcon: Icons.volume_up_rounded,
                    label: AppText.sound,
                    value: sound,
                    onChanged: onSoundChanged,
                  ),
                ),
                Expanded(
                  child: _VolumeRow(
                    assetName: 'music_icon.png',
                    fallbackIcon: Icons.music_note_rounded,
                    label: AppText.music,
                    value: music,
                    onChanged: onMusicChanged,
                  ),
                ),
                Expanded(
                  child: _ToggleRow(
                    assetName: 'vibration_icon.png',
                    fallbackIcon: Icons.vibration_rounded,
                    label: AppText.vibration,
                    value: vibration,
                    onChanged: onVibrationChanged,
                  ),
                ),
                Expanded(
                  child: _ToggleRow(
                    assetName: 'check_table_icon.png',
                    fallbackIcon: Icons.fact_check_rounded,
                    label: AppText.checkTable,
                    value: autoCheckTable,
                    onChanged: onAutoCheckChanged,
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
  final double min;
  final double max;
  final double value;
  final List<String> ticks;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<double> onChanged;

  const _CompactSliderRow({
    required this.fallbackIcon,
    required this.title,
    required this.valueText,
    required this.min,
    required this.max,
    required this.value,
    required this.ticks,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(fallbackIcon, color: Colors.white70, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              valueText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _ImageButton(
              assetName: 'minus_button.png',
              onTap: onMinus,
              icon: Icons.remove_rounded,
              size: 34,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _AssetSlider(
                min: min,
                max: max,
                value: value,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 6),
            _ImageButton(
              assetName: 'plus_button.png',
              onTap: onPlus,
              icon: Icons.add_rounded,
              size: 34,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final tick in ticks)
                Text(
                  tick,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
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

class _VolumeRow extends StatelessWidget {
  final String assetName;
  final IconData fallbackIcon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeRow({
    required this.assetName,
    required this.fallbackIcon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: _MissionAsset(
            name: assetName,
            fallback: Icon(fallbackIcon, color: Colors.redAccent, size: 26),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 82,
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: _AssetSlider(
            min: 0,
            max: 1,
            value: value,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 42,
          child: Text(
            '${(value * 100).round()}%',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String assetName;
  final IconData fallbackIcon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.assetName,
    required this.fallbackIcon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: _MissionAsset(
            name: assetName,
            fallback: Icon(fallbackIcon, color: Colors.redAccent, size: 26),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 74,
            height: 30,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF9A1515) : Colors.black87,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white30),
            ),
            child: Container(
              width: 36,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF24282B),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                value ? AppText.on.toUpperCase() : AppText.off.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StartMissionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartMissionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: 72,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _MissionAsset(
              name: 'start_mission_button.png',
              fit: BoxFit.fill,
              fallback: const _MetalFrame(active: true, red: true),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.key_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppText.startMission.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  const _AssetSlider({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final percent = ((value - min) / (max - min)).clamp(0.0, 1.0);
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
                        BoxShadow(color: Colors.redAccent, blurRadius: 8),
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
    onChanged(min + (max - min) * percent);
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 5, height: 20, color: Colors.redAccent),
        const SizedBox(width: 7),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: Colors.white24, height: 1)),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
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
