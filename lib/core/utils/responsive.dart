import 'dart:math';

import 'package:flutter/widgets.dart';

class Responsive {
  final Size size;
  final double textScale;

  const Responsive._(this.size, this.textScale);

  factory Responsive.of(BuildContext context) {
    final media = MediaQuery.of(context);
    return Responsive._(media.size, media.textScaler.scale(1));
  }

  double get shortest => min(size.width, size.height);
  double get scale => (shortest / 390).clamp(0.82, 1.22);
  double get compactScale => (shortest / 390).clamp(0.78, 1.08);

  double s(double value) => value * scale;
  double c(double value) => value * compactScale;
  double font(double value) => (value * scale / textScale.clamp(1.0, 1.25))
      .clamp(value * 0.82, value * 1.18);
}
