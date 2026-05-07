import 'package:flutter/material.dart';

import '../../../core/constants/app_text.dart';
import '../../../core/utils/timer_formatter.dart';
import '../game_controller.dart';
import 'asset_frame.dart';
import 'game_asset_paths.dart';

class LimitStatusBar extends StatelessWidget {
  final GameController controller;

  const LimitStatusBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cfg = controller.config!;
    final items = <Widget>[];
    if (controller.usesAttempts) {
      items.add(
        _StatusItem(
          label: AppText.left,
          value: '${controller.remainingAttempts}',
        ),
      );
    }
    if (controller.usesTime) {
      items.add(
        _StatusItem(
          label: AppText.time,
          value: formatSeconds(controller.remainingSeconds ?? 0),
        ),
      );
    }
    items.add(
      _StatusItem(label: AppText.tried, value: '${controller.history.length}'),
    );

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: AssetFrame(
            assetPath: GameAssetPaths.gameHeaderPanel,
            padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${AppText.difficultyLabel(cfg.difficulty.name).toUpperCase()}   '
                '${AppText.limitModeLabel(cfg.limitMode.name).toUpperCase()}',
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
        const SizedBox(height: 6),
        Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(child: items[index]),
              if (index != items.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatusItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: AssetFrame(
        assetPath: GameAssetPaths.statusPanelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1,
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
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
