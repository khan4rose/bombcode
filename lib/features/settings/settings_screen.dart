import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/feedback/game_haptics.dart';
import '../../core/utils/game_sound_effects.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _sound = 0.7;
  double _music = 0.5;
  bool _vibration = true;
  bool _checkTable = true;

  @override
  void initState() {
    super.initState();
    _loadSoundSetting();
    _loadVibrationSetting();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppText.settings),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        dim: true,
        lightText: true,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(r.c(18)),
            children: [
              Text(
                AppText.options.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: r.c(8)),
              _VolumeSettingTile(
                icon: Icons.volume_up_rounded,
                title: AppText.sound,
                value: _sound,
                onChanged: _setSound,
              ),
              _VolumeSettingTile(
                icon: Icons.music_note_rounded,
                title: AppText.music,
                value: _music,
                onChanged: (value) => setState(() => _music = value),
              ),
              _SwitchSettingTile(
                icon: Icons.vibration_rounded,
                title: AppText.vibration,
                value: _vibration,
                onChanged: _setVibration,
              ),
              _SwitchSettingTile(
                icon: Icons.fact_check_rounded,
                title: AppText.checkTable,
                value: _checkTable,
                onChanged: (value) => setState(() => _checkTable = value),
              ),
              SizedBox(height: r.c(14)),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(AppText.isKo ? '언어' : 'Language'),
                subtitle: Text(
                  AppText.isKo
                      ? '휴대폰 언어에 따라 한글/영문 화면이 자동 선택됩니다.'
                      : 'Device language chooses Korean or English screens.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.storage_rounded),
                title: Text(AppText.isKo ? '저장소' : 'Storage'),
                subtitle: Text(
                  AppText.isKo
                      ? '기록은 이 기기에만 저장됩니다.'
                      : 'Records are saved on this device.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(AppText.isKo ? '버전' : 'Version'),
                subtitle: const Text('BoomCode MVP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSoundSetting() async {
    final sound = await GameSoundEffects.instance.loadSoundVolume();
    if (!mounted) {
      return;
    }
    setState(() => _sound = sound);
  }

  void _setSound(double value) {
    setState(() => _sound = value);
    unawaited(GameSoundEffects.instance.saveSoundVolume(value));
  }

  Future<void> _loadVibrationSetting() async {
    final enabled = await GameHaptics.instance.loadEnabled();
    if (!mounted) {
      return;
    }
    setState(() => _vibration = enabled);
  }

  void _setVibration(bool enabled) {
    setState(() => _vibration = enabled);
    unawaited(GameHaptics.instance.saveEnabled(enabled));
  }
}

class _VolumeSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeSettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(title),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.redAccent,
        inactiveColor: Colors.white24,
      ),
      trailing: SizedBox(
        width: 44,
        child: Text(
          '${(value * 100).round()}%',
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SwitchSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.redAccent),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.redAccent,
      activeTrackColor: Colors.redAccent.withValues(alpha: 0.35),
    );
  }
}
