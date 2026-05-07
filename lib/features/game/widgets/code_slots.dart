import 'package:flutter/material.dart';

import 'asset_frame.dart';
import 'game_asset_paths.dart';

class CodeSlots extends StatelessWidget {
  final int length;
  final List<int> digits;

  const CodeSlots({super.key, required this.length, required this.digits});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: const Color(0xFFEAFBFF),
      fontSize: 40,
      fontWeight: FontWeight.w900,
      height: 1,
      shadows: const [
        Shadow(color: Color(0x997FF4FF), blurRadius: 6),
        Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
      ],
    );

    return FractionallySizedBox(
      widthFactor: 0.74,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slotGap = length >= 4 ? 5.0 : 8.0;
              final maxSlotWidth =
                  (constraints.maxWidth - slotGap * (length - 1)) / length;
              final availableSize = maxSlotWidth < constraints.maxHeight
                  ? maxSlotWidth
                  : constraints.maxHeight;
              final slotSize = availableSize < 44
                  ? availableSize.toDouble()
                  : availableSize.clamp(44.0, 60.0).toDouble();

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < length; index++) ...[
                    SizedBox.square(
                      dimension: slotSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isSelected(index)
                                ? const Color(0xFFFF3B30)
                                : Colors.white.withValues(alpha: 0.12),
                            width: _isSelected(index) ? 1.6 : 0.8,
                          ),
                          boxShadow: _isSelected(index)
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF3B30,
                                    ).withValues(alpha: 0.55),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: AssetFrame(
                            assetPath: _slotAsset(index),
                            padding: EdgeInsets.all(slotSize * 0.13),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                index < digits.length ? '${digits[index]}' : '',
                                style: textStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (index != length - 1) SizedBox(width: slotGap),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isSelected(int index) {
    return index == digits.length && digits.length < length;
  }

  String _slotAsset(int index) {
    if (index == digits.length && digits.length < length) {
      return GameAssetPaths.codeSlotSelected;
    }
    if (index < digits.length) {
      return GameAssetPaths.codeSlotFilled;
    }
    return GameAssetPaths.codeSlotEmpty;
  }
}
