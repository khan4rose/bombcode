import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/widgets/app_background.dart';
import '../mode_select/mode_select_screen.dart';
import '../records/records_screen.dart';
import '../settings/settings_screen.dart';
import '../tutorial/tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = _HomeStrings.current;
    final assets = _HomeMenuAssets.current;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final scaleW = width / 360.0;
              final scaleH = height / 800.0;
              final scale = math.min(scaleW, scaleH);
              final s = scale.clamp(0.78, 1.16).toDouble();
              final mainButtonWidth = math.min(width * 1.02, 418.0 * s);
              final mainButtonHeight =
                  mainButtonWidth / _MenuSizes.mainButtonAspect * 0.82;
              final mainButtonLeft = (width - mainButtonWidth) / 2;
              final buttonGap = 1.0 * s;
              final buttonTop = height * 0.435;
              final utilityAlignInset = mainButtonWidth * 0.025;
              final utilitySpan = mainButtonWidth - utilityAlignInset * 2;
              final utilityWidth = math.min(96.0 * s, utilitySpan * 0.29) * 0.8;
              final utilityHeight =
                  utilityWidth / _MenuSizes.utilityButtonAspect;
              final utilityTop = height * 0.845;
              final utilityGap =
                  math.max(0.0, (utilitySpan - utilityWidth * 3) / 2) * 0.3;
              final utilityLeft =
                  mainButtonLeft +
                  utilityAlignInset +
                  (utilitySpan - utilityWidth * 3 - utilityGap * 2) / 2;
              final currencyWidth = math.min(width * 0.38, 152.0 * s);
              final currencyHeight = currencyWidth / 2.62;
              final logoWidth = math.min(width * 0.94, 384.0 * s);
              final logoHeight = logoWidth / _MenuSizes.logoAspect;

              return Stack(
                children: [
                  Positioned(
                    left: 18.0 * s,
                    top: 9.0 * s,
                    width: currencyWidth,
                    height: currencyHeight,
                    child: const _CurrencyPanel(),
                  ),
                  Positioned(
                    left: (width - logoWidth) / 2,
                    top: height * 0.058,
                    width: logoWidth,
                    height: logoHeight,
                    child: _LogoPlate(assetPath: assets.logo),
                  ),
                  Positioned(
                    left: mainButtonLeft,
                    top: buttonTop,
                    width: mainButtonWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MainMenuButton(
                          label: strings.startGame,
                          assetPath: assets.start,
                          height: mainButtonHeight,
                          onPressed: () => _openModeSelect(context),
                        ),
                        const SizedBox.shrink(),
                        _MainMenuButton(
                          label: strings.selectDifficulty,
                          assetPath: assets.difficulty,
                          height: mainButtonHeight,
                          onPressed: () => _openModeSelect(context),
                        ),
                        SizedBox(height: buttonGap),
                        _MainMenuButton(
                          label: strings.records,
                          assetPath: assets.records,
                          height: mainButtonHeight,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RecordsScreen(),
                            ),
                          ),
                        ),
                        SizedBox(height: buttonGap),
                        _MainMenuButton(
                          label: strings.settings,
                          assetPath: assets.settings,
                          height: mainButtonHeight,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: utilityLeft,
                    top: utilityTop,
                    width: utilityWidth * 3 + utilityGap * 2,
                    height: utilityHeight,
                    child: Row(
                      children: [
                        _UtilityButton(
                          label: strings.shop,
                          assetPath: assets.shop,
                          width: utilityWidth,
                          height: utilityHeight,
                          onPressed: () => _showComingSoon(context),
                        ),
                        SizedBox(width: utilityGap),
                        _UtilityButton(
                          label: strings.removeAds,
                          assetPath: assets.removeAds,
                          width: utilityWidth,
                          height: utilityHeight,
                          onPressed: () => _showComingSoon(context),
                        ),
                        SizedBox(width: utilityGap),
                        _UtilityButton(
                          label: strings.help,
                          assetPath: assets.help,
                          width: utilityWidth,
                          height: utilityHeight,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TutorialScreen(),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.comingSoon)));
  }
}

class _MenuSizes {
  static const mainButtonAspect = 738 / 172;
  static const utilityButtonAspect = 196 / 248;
  static const logoAspect = 760 / 620;
}

class _CurrencyPanel extends StatelessWidget {
  const _CurrencyPanel();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/menu/menu_currency.png',
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );
  }
}

class _LogoPlate extends StatelessWidget {
  final String assetPath;

  const _LogoPlate({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

class _MainMenuButton extends StatelessWidget {
  final String label;
  final String assetPath;
  final double height;
  final VoidCallback onPressed;

  const _MainMenuButton({
    required this.label,
    required this.assetPath,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.redAccent.withValues(alpha: 0.16),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _UtilityButton extends StatelessWidget {
  final String label;
  final String assetPath;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const _UtilityButton({
    required this.label,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.cyanAccent.withValues(alpha: 0.12),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMenuAssets {
  final String logo;
  final String start;
  final String difficulty;
  final String records;
  final String settings;
  final String shop;
  final String removeAds;
  final String help;

  const _HomeMenuAssets({
    required this.logo,
    required this.start,
    required this.difficulty,
    required this.records,
    required this.settings,
    required this.shop,
    required this.removeAds,
    required this.help,
  });

  static _HomeMenuAssets get current {
    final isKo = PlatformDispatcher.instance.locale.languageCode == 'ko';
    return isKo ? ko : en;
  }

  static const en = _HomeMenuAssets(
    logo: 'assets/menu/menu_logo_eng.png',
    start: 'assets/menu/menu_start_eng.png',
    difficulty: 'assets/menu/menu_difficulty_eng.png',
    records: 'assets/menu/menu_records_eng.png',
    settings: 'assets/menu/menu_settings_eng.png',
    shop: 'assets/menu/menu_shop_eng.png',
    removeAds: 'assets/menu/menu_remove_ads_eng.png',
    help: 'assets/menu/menu_help_eng.png',
  );

  static const ko = _HomeMenuAssets(
    logo: 'assets/menu/menu_logo_kor.png',
    start: 'assets/menu/menu_start_kor.png',
    difficulty: 'assets/menu/menu_difficulty_kor.png',
    records: 'assets/menu/menu_records_kor.png',
    settings: 'assets/menu/menu_settings_kor.png',
    shop: 'assets/menu/menu_shop_kor.png',
    removeAds: 'assets/menu/menu_remove_ads_kor.png',
    help: 'assets/menu/menu_help_kor.png',
  );
}

class _HomeStrings {
  final String startGame;
  final String selectDifficulty;
  final String records;
  final String settings;
  final String shop;
  final String removeAds;
  final String help;
  final String comingSoon;

  const _HomeStrings({
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
    startGame: '\uAC8C\uC784 \uC2DC\uC791',
    selectDifficulty: '\uB09C\uC774\uB3C4 \uC120\uD0DD',
    records: '\uAE30\uB85D',
    settings: '\uC124\uC815',
    shop: '\uC0C1\uC810',
    removeAds: '\uAD11\uACE0 \uC81C\uAC70',
    help: '\uB3C4\uC6C0\uB9D0',
    comingSoon: '\uCD9C\uC2DC \uC900\uBE44 \uC911\uC785\uB2C8\uB2E4.',
  );
}
