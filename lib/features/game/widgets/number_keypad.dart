import 'package:flutter/material.dart';

import '../../../core/constants/app_text.dart';
import 'asset_frame.dart';
import 'game_asset_paths.dart';

class NumberKeypad extends StatelessWidget {
  final Set<int> usedDigits;
  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onSubmit;

  const NumberKeypad({
    super.key,
    required this.usedDigits,
    required this.onDigit,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 26,
      fontWeight: FontWeight.w900,
      height: 1,
      shadows: [
        Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
      ],
    );

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 2.0;
            final buttonWidth = (constraints.maxWidth - gap * 2) / 3;
            final buttonHeight = (buttonWidth / (144 / 112))
                .clamp(48.0, 48.0)
                .toDouble();
            const rows = [
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
            ];

            return Column(
              children: [
                for (final row in rows) ...[
                  Row(
                    children: [
                      for (var i = 0; i < row.length; i++) ...[
                        Expanded(
                          child: SizedBox(
                            height: buttonHeight,
                            child: _DigitButton(
                              digit: row[i],
                              disabled: usedDigits.contains(row[i]),
                              onTap: () => onDigit(row[i]),
                              textStyle: textStyle,
                            ),
                          ),
                        ),
                        if (i != row.length - 1) const SizedBox(width: gap),
                      ],
                    ],
                  ),
                  const SizedBox(height: gap),
                ],
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: buttonHeight,
                        child: _ActionButton(
                          assetPath: GameAssetPaths.keypadDeleteButton,
                          onTap: onDelete,
                          label: AppText.delete,
                        ),
                      ),
                    ),
                    const SizedBox(width: gap),
                    Expanded(
                      child: SizedBox(
                        height: buttonHeight,
                        child: _DigitButton(
                          digit: 0,
                          disabled: usedDigits.contains(0),
                          onTap: () => onDigit(0),
                          textStyle: textStyle,
                        ),
                      ),
                    ),
                    const SizedBox(width: gap),
                    Expanded(
                      child: SizedBox(
                        height: buttonHeight,
                        child: _ActionButton(
                          assetPath: onSubmit == null
                              ? GameAssetPaths.keypadSubmitDisabled
                              : GameAssetPaths.keypadSubmitButton,
                          onTap: onSubmit,
                          label: AppText.submit,
                          pressedScale: 0.91,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final int digit;
  final bool disabled;
  final VoidCallback onTap;
  final TextStyle textStyle;

  const _DigitButton({
    required this.digit,
    required this.disabled,
    required this.onTap,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableAssetButton(
      idleAsset: disabled
          ? GameAssetPaths.keypadButtonDisabled
          : GameAssetPaths.keypadButtonIdle,
      pressedAsset: disabled
          ? GameAssetPaths.keypadButtonDisabled
          : GameAssetPaths.keypadButtonPressed,
      onTap: disabled ? null : onTap,
      child: Text(
        '$digit',
        style: textStyle.copyWith(color: disabled ? Colors.white54 : null),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onTap;
  final String label;
  final double pressedScale;

  const _ActionButton({
    required this.assetPath,
    required this.onTap,
    required this.label,
    this.pressedScale = 0.96,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableAssetButton(
      idleAsset: assetPath,
      pressedAsset: assetPath,
      onTap: onTap,
      pressedScale: pressedScale,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: onTap == null ? Colors.white54 : const Color(0xFFF6FCFF),
            fontSize: 15,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressableAssetButton extends StatefulWidget {
  final String idleAsset;
  final String pressedAsset;
  final VoidCallback? onTap;
  final Widget child;
  final double pressedScale;

  const _PressableAssetButton({
    required this.idleAsset,
    required this.pressedAsset,
    required this.onTap,
    required this.child,
    this.pressedScale = 0.96,
  });

  @override
  State<_PressableAssetButton> createState() => _PressableAssetButtonState();
}

class _PressableAssetButtonState extends State<_PressableAssetButton> {
  bool _pressed = false;
  int _pressSerial = 0;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTapUp: enabled
            ? (_) {
                widget.onTap?.call();
                _releasePressed();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AssetFrame(
            assetPath: _pressed ? widget.pressedAsset : widget.idleAsset,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool pressed) {
    _pressSerial += 1;
    setState(() => _pressed = pressed);
  }

  Future<void> _releasePressed() async {
    final serial = _pressSerial;
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted || serial != _pressSerial) {
      return;
    }
    setState(() => _pressed = false);
  }
}
