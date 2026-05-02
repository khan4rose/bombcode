import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';
import '../mode_select/mode_select_screen.dart';
import '../records/records_screen.dart';
import '../settings/settings_screen.dart';
import '../tutorial/tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final strings = _HomeStrings.current;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 720;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: r.c(440)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.c(22),
                      vertical: r.c(isCompact ? 14 : 24),
                    ),
                    child: Column(
                      children: [
                        const Spacer(),
                        _TitleBlock(strings: strings),
                        SizedBox(height: r.c(isCompact ? 22 : 34)),
                        _MainMenuButton(
                          label: strings.startGame,
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => _openModeSelect(context),
                        ),
                        SizedBox(height: r.c(12)),
                        _MainMenuButton(
                          label: strings.selectDifficulty,
                          icon: Icons.tune_rounded,
                          onPressed: () => _openModeSelect(context),
                        ),
                        SizedBox(height: r.c(12)),
                        _MainMenuButton(
                          label: strings.records,
                          icon: Icons.military_tech_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RecordsScreen(),
                            ),
                          ),
                        ),
                        SizedBox(height: r.c(12)),
                        _MainMenuButton(
                          label: strings.settings,
                          icon: Icons.settings_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                        SizedBox(height: r.c(isCompact ? 16 : 24)),
                        Row(
                          children: [
                            Expanded(
                              child: _UtilityButton(
                                label: strings.shop,
                                icon: Icons.storefront_rounded,
                                onPressed: () => _showComingSoon(context),
                              ),
                            ),
                            SizedBox(width: r.c(10)),
                            Expanded(
                              child: _UtilityButton(
                                label: strings.removeAds,
                                icon: Icons.block_rounded,
                                onPressed: () => _showComingSoon(context),
                              ),
                            ),
                            SizedBox(width: r.c(10)),
                            Expanded(
                              child: _UtilityButton(
                                label: strings.help,
                                icon: Icons.help_outline_rounded,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TutorialScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openModeSelect(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ModeSelectScreen()));
  }

  void _showComingSoon(BuildContext context) {
    final strings = _HomeStrings.current;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.comingSoon)),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final _HomeStrings strings;

  const _TitleBlock({required this.strings});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock_open_rounded,
          color: const Color(0xFFFF394D),
          size: r.c(58),
        ),
        SizedBox(height: r.c(12)),
        Text(
          'BOMBCODE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: r.font(42),
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
            shadows: const [
              Shadow(
                color: Color(0xFFFF263D),
                blurRadius: 22,
              ),
            ],
          ),
        ),
        SizedBox(height: r.c(6)),
        Text(
          strings.subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF9FE8FF),
            fontSize: r.font(13),
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MainMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _MainMenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return SizedBox(
      width: double.infinity,
      height: r.c(58),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: r.c(24)),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6F1018),
          foregroundColor: Colors.white,
          shadowColor: const Color(0xFFFF263D),
          elevation: 8,
          textStyle: TextStyle(
            fontSize: r.font(18),
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Color(0xFFFF5366),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _UtilityButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return SizedBox(
      height: r.c(74),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE9F8FF),
          side: const BorderSide(color: Color(0xFF6AD7FF), width: 1.2),
          backgroundColor: const Color(0xAA101820),
          padding: EdgeInsets.symmetric(horizontal: r.c(6), vertical: r.c(8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: r.c(22)),
            SizedBox(height: r.c(5)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.font(12),
                    fontWeight: FontWeight.w800,
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

class _HomeStrings {
  final String subtitle;
  final String startGame;
  final String selectDifficulty;
  final String records;
  final String settings;
  final String shop;
  final String removeAds;
  final String help;
  final String comingSoon;

  const _HomeStrings({
    required this.subtitle,
    required this.startGame,
    required this.selectDifficulty,
    required this.records,
    required this.settings,
    required this.shop,
    required this.removeAds,
    required this.help,
    required this.comingSoon,
  });

  static _HomeStrings get current {
    final isKo = PlatformDispatcher.instance.locale.languageCode == 'ko';
    return isKo ? ko : en;
  }

  static const en = _HomeStrings(
    subtitle: 'Offline Code Defusal',
    startGame: 'Start Game',
    selectDifficulty: 'Select Difficulty',
    records: 'Records',
    settings: 'Settings',
    shop: 'Shop',
    removeAds: 'Remove Ads',
    help: 'Help',
    comingSoon: 'Coming soon.',
  );

  static const ko = _HomeStrings(
    subtitle: '오프라인 코드 해체',
    startGame: '게임 시작',
    selectDifficulty: '난이도 선택',
    records: '기록',
    settings: '설정',
    shop: '상점',
    removeAds: '광고 제거',
    help: '도움말',
    comingSoon: '출시 준비 중입니다.',
  );
}
