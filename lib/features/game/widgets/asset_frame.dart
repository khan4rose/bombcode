import 'package:flutter/material.dart';

class AssetFrame extends StatelessWidget {
  final String assetPath;
  final Widget? child;
  final Widget? backing;
  final EdgeInsetsGeometry padding;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;

  const AssetFrame({
    super.key,
    required this.assetPath,
    this.child,
    this.backing,
    this.padding = EdgeInsets.zero,
    this.fit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.high,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ?backing,
        Image.asset(
          assetPath,
          fit: fit,
          filterQuality: filterQuality,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
            );
          },
        ),
        if (child != null)
          Padding(
            padding: padding,
            child: Align(alignment: alignment, child: child),
          ),
      ],
    );
  }
}
