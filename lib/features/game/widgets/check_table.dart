import 'package:flutter/material.dart';

import '../../../core/constants/app_text.dart';
import '../../../domain/enums/digit_mark.dart';
import '../game_controller.dart';
import 'asset_frame.dart';
import 'game_asset_paths.dart';

class CheckTable extends StatelessWidget {
  final GameController controller;

  const CheckTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AssetFrame(
      assetPath: GameAssetPaths.checkTablePanel,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      child: Column(
        children: [
          SizedBox(
            height: 18,
            child: Text(
              AppText.checkTable.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 6,
              childAspectRatio: 120 / 72,
              children: [
                for (var digit = 0; digit <= 9; digit++)
                  _DigitMarker(
                    digit: digit,
                    mark: controller.digitMarks[digit]!,
                    onTap: controller.config?.autoCheckTable == true
                        ? null
                        : () => controller.markDigit(digit),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DigitMarker extends StatelessWidget {
  final int digit;
  final DigitMark mark;
  final VoidCallback? onTap;

  const _DigitMarker({
    required this.digit,
    required this.mark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$digit ${mark.label}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AssetFrame(
          assetPath: _assetFor(mark),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$digit',
                    maxLines: 1,
                    style: TextStyle(
                      color: _textColor(mark),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      shadows: const [
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
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    mark.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: _textColor(mark).withValues(alpha: 0.82),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      shadows: const [
                        Shadow(
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
        ),
      ),
    );
  }

  String _assetFor(DigitMark mark) {
    return switch (mark) {
      DigitMark.unknown => GameAssetPaths.digitMarkerUnknown,
      DigitMark.possible => GameAssetPaths.digitMarkerPossible,
      DigitMark.impossible => GameAssetPaths.digitMarkerImpossible,
      DigitMark.accessCandidate => GameAssetPaths.digitMarkerAccessCandidate,
      DigitMark.traceCandidate => GameAssetPaths.digitMarkerTraceCandidate,
    };
  }

  Color _textColor(DigitMark mark) {
    return switch (mark) {
      DigitMark.unknown => Colors.white70,
      DigitMark.possible => const Color(0xFFE6FBFF),
      DigitMark.impossible => Colors.white54,
      DigitMark.accessCandidate => Colors.white,
      DigitMark.traceCandidate => const Color(0xFFFFE681),
    };
  }
}
