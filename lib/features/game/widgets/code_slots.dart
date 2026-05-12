import 'package:flutter/material.dart';

import 'asset_frame.dart';
import 'game_asset_paths.dart';

class CodeSlots extends StatelessWidget {
  final int length;
  final List<int> digits;
  final List<int?>? slotDigits;
  final int? selectedIndex;
  final ValueChanged<int>? onSlotTap;

  const CodeSlots({
    super.key,
    required this.length,
    required this.digits,
    this.slotDigits,
    this.selectedIndex,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.74,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF182026).withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF9FB6C1).withValues(alpha: 0.28),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF28343C).withValues(alpha: 0.58),
              const Color(0xFF11171C).withValues(alpha: 0.88),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB8CCD4).withValues(alpha: 0.08),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.48),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = (constraints.maxWidth * 0.035)
                .clamp(10.0, 13.0)
                .toDouble();
            final verticalPadding = (constraints.maxHeight * 0.07)
                .clamp(3.0, 5.0)
                .toDouble();
            final usableWidth = constraints.maxWidth - horizontalPadding * 2;
            final usableHeight = constraints.maxHeight - verticalPadding * 2;
            final slotGap = length >= 4
                ? (constraints.maxWidth * 0.018).clamp(5.0, 7.0).toDouble()
                : (constraints.maxWidth * 0.025).clamp(7.0, 9.0).toDouble();
            final maxSlotWidth =
                (usableWidth - slotGap * (length - 1)) / length;
            final availableSize = maxSlotWidth < usableHeight
                ? maxSlotWidth
                : usableHeight;
            final slotSize = availableSize < 44
                ? availableSize.toDouble()
                : availableSize.clamp(44.0, 66.0).toDouble();
            final digitStyle = Theme.of(context).textTheme.displaySmall
                ?.copyWith(
                  color: const Color(0xFFF2FDFF),
                  fontSize: (slotSize * 0.76).clamp(41.0, 45.0).toDouble(),
                  fontWeight: FontWeight.w900,
                  height: 1,
                  shadows: const [
                    Shadow(color: Color(0x809EC7D2), blurRadius: 5),
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                );

            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding * 0.55,
                      vertical: verticalPadding * 0.65,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: const Color(0xFF0B1115).withValues(alpha: 0.42),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < length; index++) ...[
                        Semantics(
                          button: true,
                          selected: _isSelected(index),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onSlotTap == null || !_isTappable(index)
                                ? null
                                : () => onSlotTap!(index),
                            child: SizedBox.square(
                              dimension: slotSize,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _slotFillColor(index),
                                  border: Border.all(
                                    color: _slotBorderColor(index),
                                    width: _slotBorderWidth(index),
                                  ),
                                  boxShadow: _slotShadows(index, slotSize),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: AssetFrame(
                                    assetPath: _slotAsset(index),
                                    padding: EdgeInsets.all(slotSize * 0.10),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _digitAt(index)?.toString() ?? '',
                                        style: digitStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (index != length - 1) SizedBox(width: slotGap),
                      ],
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

  bool _isSelected(int index) {
    final selected = selectedIndex;
    if (selected != null) {
      return selected == index;
    }
    return index == _firstEmptyIndex();
  }

  bool _isFilled(int index) {
    return _digitAt(index) != null;
  }

  Color _slotFillColor(int index) {
    if (_isSelected(index)) {
      return const Color(0xFF36434A).withValues(alpha: 0.54);
    }
    if (_isFilled(index)) {
      return const Color(0xFF303D44).withValues(alpha: 0.46);
    }
    return const Color(0xFF1D272D).withValues(alpha: 0.42);
  }

  Color _slotBorderColor(int index) {
    if (_isSelected(index)) {
      return const Color(0xFFFF6B5F).withValues(alpha: 0.86);
    }
    if (_isFilled(index)) {
      return const Color(0xFFB7CDD6).withValues(alpha: 0.42);
    }
    return const Color(0xFF8EA2AA).withValues(alpha: 0.24);
  }

  double _slotBorderWidth(int index) {
    if (_isSelected(index)) {
      return 1.8;
    }
    if (_isFilled(index)) {
      return 1.1;
    }
    return 0.8;
  }

  List<BoxShadow> _slotShadows(int index, double slotSize) {
    if (_isSelected(index)) {
      return [
        BoxShadow(
          color: const Color(0xFFFF5A50).withValues(alpha: 0.36),
          blurRadius: slotSize * 0.16,
          spreadRadius: 0.2,
        ),
        BoxShadow(
          color: const Color(0xFFFFE1DC).withValues(alpha: 0.12),
          blurRadius: slotSize * 0.08,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.52),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    if (_isFilled(index)) {
      return [
        BoxShadow(
          color: const Color(0xFFB6CCD4).withValues(alpha: 0.13),
          blurRadius: slotSize * 0.10,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.42),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.38),
        blurRadius: 5,
        offset: const Offset(0, 1),
      ),
    ];
  }

  String _slotAsset(int index) {
    if (_isSelected(index)) {
      return GameAssetPaths.codeSlotSelected;
    }
    if (_isFilled(index)) {
      return GameAssetPaths.codeSlotFilled;
    }
    return GameAssetPaths.codeSlotEmpty;
  }

  int? _digitAt(int index) {
    final slots = slotDigits;
    if (slots != null) {
      return index < slots.length ? slots[index] : null;
    }
    return index < digits.length ? digits[index] : null;
  }

  int? _firstEmptyIndex() {
    for (var index = 0; index < length; index++) {
      if (_digitAt(index) == null) {
        return index;
      }
    }
    return null;
  }

  bool _isTappable(int index) {
    if (index < 0 || index >= length) {
      return false;
    }
    if (_digitAt(index) != null) {
      return true;
    }
    return index == _firstEmptyIndex();
  }
}
