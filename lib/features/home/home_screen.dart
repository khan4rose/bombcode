import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/local_game_config_repository.dart';
import '../../core/widgets/app_background.dart';
import '../game/game_screen.dart';
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
              if (width <= 0 || height <= 0) {
                return const SizedBox.shrink();
              }
              final scaleW = width / 360.0;
              final scaleH = height / 800.0;
              final scale = math.min(scaleW, scaleH);
              final s = scale.clamp(0.78, 1.16).toDouble();
              final mainButtonWidth = math.min(width * 0.86, 360.0 * s);
              final primaryButtonHeight = 76.0 * s;
              final secondaryButtonHeight = 65.0 * s;
              final mainButtonLeft = (width - mainButtonWidth) / 2;
              final buttonGap = 5.0 * s;
              final buttonTop = height * 0.436;
              final utilityAlignInset = mainButtonWidth * 0.025;
              final utilitySpan = mainButtonWidth - utilityAlignInset * 2;
              final bottomIconSize = (width * 0.17).clamp(62.0, 76.0);
              final utilityGap = (width * 0.055).clamp(18.0, 24.0);
              final availableUtilityWidth = math.max(
                48.0,
                (utilitySpan - utilityGap * 2) / 3,
              );
              final utilityWidth = math.min(
                math.max(48.0, bottomIconSize + 12.0 * s),
                availableUtilityWidth,
              );
              final utilityHeight = utilityWidth;
              final bottomIconVisualSize = math.min(
                bottomIconSize,
                utilityWidth,
              );
              final utilityTop = math.min(
                height * 0.825,
                height - utilityHeight - 28.0 * s,
              );
              final utilityLeft =
                  mainButtonLeft +
                  utilityAlignInset +
                  (utilitySpan - utilityWidth * 3 - utilityGap * 2) / 2;
              final currencyWidth = math.min(width * 0.38, 152.0 * s);
              final currencyHeight = currencyWidth / 2.62;
              final logoWidth = math.min(width * 0.91, 360.0 * s);
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
                        PrimaryMenuButton(
                          text: strings.startGame,
                          scale: s,
                          height: primaryButtonHeight,
                          onPressed: () => _startGame(context),
                        ),
                        const SizedBox.shrink(),
                        SecondaryMenuButton(
                          text: strings.selectDifficulty,
                          scale: s,
                          height: secondaryButtonHeight,
                          onPressed: () => _openModeSelect(context),
                        ),
                        SizedBox(height: buttonGap),
                        SecondaryMenuButton(
                          text: strings.records,
                          scale: s,
                          height: secondaryButtonHeight,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RecordsScreen(),
                            ),
                          ),
                        ),
                        SizedBox(height: buttonGap),
                        SecondaryMenuButton(
                          text: strings.settings,
                          scale: s,
                          height: secondaryButtonHeight,
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
                        BottomMenuButton(
                          text: strings.shop,
                          assetPath: assets.shopIcon,
                          width: utilityWidth,
                          height: utilityHeight,
                          iconSize: bottomIconVisualSize,
                          onPressed: () => _showComingSoon(context),
                        ),
                        SizedBox(width: utilityGap),
                        BottomMenuButton(
                          text: strings.removeAds,
                          assetPath: assets.noAdsIcon,
                          width: utilityWidth,
                          height: utilityHeight,
                          iconSize: bottomIconVisualSize,
                          onPressed: () => _showComingSoon(context),
                        ),
                        SizedBox(width: utilityGap),
                        BottomMenuButton(
                          text: strings.help,
                          assetPath: assets.helpIcon,
                          width: utilityWidth,
                          height: utilityHeight,
                          iconSize: bottomIconVisualSize,
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

  Future<void> _startGame(BuildContext context) async {
    final config = await LocalGameConfigRepository().loadLastConfig();
    if (!context.mounted) {
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => GameScreen(config: config)));
  }

  void _showComingSoon(BuildContext context) {
    final strings = _HomeStrings.current;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.comingSoon)));
  }
}

class _MenuSizes {
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

class PrimaryMenuButton extends StatelessWidget {
  final String text;
  final double scale;
  final double? width;
  final double height;
  final VoidCallback onPressed;

  const PrimaryMenuButton({
    super.key,
    required this.text,
    required this.scale,
    this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _MenuTextButton(
      text: text,
      assetPath: _MenuFrameAssets.primary,
      scale: scale,
      width: width,
      height: height,
      textStyle: _MenuTextStyles.primary(scale),
      baselineDy: _MenuTextStyles.baselineDy(scale),
      splashColor: Colors.redAccent.withValues(alpha: 0.16),
      onPressed: onPressed,
    );
  }
}

class SecondaryMenuButton extends StatelessWidget {
  final String text;
  final double scale;
  final double? width;
  final double height;
  final VoidCallback onPressed;

  const SecondaryMenuButton({
    super.key,
    required this.text,
    required this.scale,
    this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _MenuTextButton(
      text: text,
      assetPath: _MenuFrameAssets.secondary,
      scale: scale,
      width: width,
      height: height,
      textStyle: _MenuTextStyles.secondary(scale),
      baselineDy: _MenuTextStyles.baselineDy(scale),
      splashColor: Colors.cyanAccent.withValues(alpha: 0.12),
      onPressed: onPressed,
    );
  }
}

class BottomMenuButton extends StatelessWidget {
  final String text;
  final String assetPath;
  final double width;
  final double height;
  final double iconSize;
  final VoidCallback onPressed;

  const BottomMenuButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Semantics(
        button: true,
        label: text,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.cyanAccent.withValues(alpha: 0.10),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Center(
              child: SizedBox.square(
                dimension: iconSize,
                child: Image.asset(
                  assetPath,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTextButton extends StatelessWidget {
  final String text;
  final String assetPath;
  final double scale;
  final double? width;
  final double height;
  final TextStyle textStyle;
  final double baselineDy;
  final Color splashColor;
  final VoidCallback onPressed;

  const _MenuTextButton({
    required this.text,
    required this.assetPath,
    required this.scale,
    required this.width,
    required this.height,
    required this.textStyle,
    required this.baselineDy,
    required this.splashColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Semantics(
        button: true,
        label: text,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            splashColor: splashColor,
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  assetPath,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
                Center(
                  child: Transform.translate(
                    offset: Offset(0, baselineDy),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0 * scale),
                      child: Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle,
                        strutStyle: StrutStyle(
                          fontSize: textStyle.fontSize,
                          height: 1.0,
                          forceStrutHeight: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuFrameAssets {
  static const primary = 'assets/menu/menu_button_primary_frame.png';
  static const secondary = 'assets/menu/menu_button_secondary_frame.png';
}

class _MenuTextStyles {
  static bool get _isKo =>
      PlatformDispatcher.instance.locale.languageCode == 'ko';

  static TextStyle primary(double scale) {
    final isKo = _isKo;
    return _base(
      fontSize: (isKo ? 30.2 : 30.0) * scale,
      fontWeight: isKo ? FontWeight.w900 : FontWeight.w800,
      shadowBlur: isKo ? 2.5 : 3.5,
    );
  }

  static TextStyle secondary(double scale) {
    final isKo = _isKo;
    return _base(
      fontSize: (isKo ? 25.5 : 25.0) * scale,
      fontWeight: isKo ? FontWeight.w900 : FontWeight.w800,
      shadowBlur: isKo ? 2.0 : 3.0,
    );
  }

  static double baselineDy(double scale) => _isKo ? -1.0 * scale : 0.0;

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required double shadowBlur,
  }) {
    return TextStyle(
      color: const Color(0xFFF1F1EC),
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.0,
      letterSpacing: 0,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.95),
          offset: const Offset(2, 2),
          blurRadius: shadowBlur,
        ),
        Shadow(
          color: Colors.redAccent.withValues(alpha: 0.45),
          offset: const Offset(0, 0),
          blurRadius: shadowBlur + 1.5,
        ),
      ],
    );
  }
}

class _HomeMenuAssets {
  final String logo;
  final String shopIcon;
  final String noAdsIcon;
  final String helpIcon;

  const _HomeMenuAssets({
    required this.logo,
    required this.shopIcon,
    required this.noAdsIcon,
    required this.helpIcon,
  });

  static _HomeMenuAssets get current {
    final isKo = PlatformDispatcher.instance.locale.languageCode == 'ko';
    return isKo ? ko : en;
  }

  static const en = _HomeMenuAssets(
    logo: 'assets/menu/menu_logo_eng.png',
    shopIcon: 'assets/menu/menu_shop_icon.png',
    noAdsIcon: 'assets/menu/menu_no_ads_icon.png',
    helpIcon: 'assets/menu/menu_help_icon.png',
  );

  static const ko = _HomeMenuAssets(
    logo: 'assets/menu/menu_logo_kor.png',
    shopIcon: 'assets/menu/menu_shop_icon.png',
    noAdsIcon: 'assets/menu/menu_no_ads_icon.png',
    helpIcon: 'assets/menu/menu_help_icon.png',
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
    startGame: 'START GAME',
    selectDifficulty: 'DIFFICULTY',
    records: 'RECORDS',
    settings: 'SETTINGS',
    shop: 'Shop',
    removeAds: 'Remove Ads',
    help: 'Help',
    comingSoon: 'Coming soon.',
  );

  static const ko = _HomeStrings(
    startGame: '\uAC8C\uC784 \uC2DC\uC791',
    selectDifficulty: '\uB09C\uC774\uB3C4',
    records: '\uAE30\uB85D',
    settings: '\uC124\uC815',
    shop: '\uC0C1\uC810',
    removeAds: '\uAD11\uACE0 \uC81C\uAC70',
    help: '\uB3C4\uC6C0\uB9D0',
    comingSoon: '\uCD9C\uC2DC \uC900\uBE44 \uC911\uC785\uB2C8\uB2E4.',
  );
}
