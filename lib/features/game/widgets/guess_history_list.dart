import 'package:flutter/material.dart';

import '../../../domain/models/guess_record.dart';
import 'asset_frame.dart';
import 'game_asset_paths.dart';

class GuessHistoryList extends StatelessWidget {
  final List<GuessRecord> history;
  final int maxRows;

  const GuessHistoryList({super.key, required this.history, this.maxRows = 3});

  @override
  Widget build(BuildContext context) {
    final visibleHistory = history.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth;
        final panelHeight = constraints.maxHeight;
        final tableInsets = EdgeInsets.fromLTRB(
          (panelWidth * 0.062).clamp(14.0, 26.0).toDouble(),
          (panelHeight * 0.165).clamp(18.0, 32.0).toDouble(),
          (panelWidth * 0.062).clamp(14.0, 26.0).toDouble(),
          (panelHeight * 0.145).clamp(14.0, 28.0).toDouble(),
        );

        return AssetFrame(
          assetPath: GameAssetPaths.historyPanel,
          padding: tableInsets,
          child: _HistorySurface(
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(height: 18, child: _HistoryHeader()),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: _HistorySeparator(),
                    ),
                    Expanded(
                      child: visibleHistory.isEmpty
                          ? const _HistoryEmptyState()
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: visibleHistory.length,
                              separatorBuilder: (context, index) =>
                                  const _HistorySeparator(),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  height: 30,
                                  child: _HistoryRow(
                                    record: visibleHistory[index],
                                    index: index,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistorySurface extends StatelessWidget {
  final Widget child;

  const _HistorySurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _HistorySurfacePainter(), child: child);
  }
}

class _HistorySurfacePainter extends CustomPainter {
  const _HistorySurfacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, Paint()..color = const Color(0xE6030406));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0AFFFFFF), Color(0x00000000), Color(0x10000000)],
          stops: [0.0, 0.46, 1.0],
        ).createShader(rect),
    );

    final linePaint = Paint()
      ..strokeWidth = 0.55
      ..color = Colors.white.withValues(alpha: 0.018);
    for (var i = 0; i < 22; i += 1) {
      final y = ((i * 11 + 7) % 97) / 97 * size.height;
      final start = ((i * 19) % 31).toDouble();
      final endInset = ((i * 13) % 37).toDouble();
      canvas.drawLine(
        Offset(start, y),
        Offset(size.width - endInset, y),
        linePaint,
      );
    }

    final speckPaint = Paint();
    for (var i = 0; i < 72; i += 1) {
      final x = ((i * 47 + 17) % 997) / 997 * size.width;
      final y = ((i * 71 + 29) % 991) / 991 * size.height;
      final alpha = i.isEven ? 0.020 : 0.012;
      speckPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawRect(Rect.fromLTWH(x, y, 0.65, 0.65), speckPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return const _HistoryColumns(
      index: _HistoryLabel('#'),
      code: _HistoryLabel('CODE'),
      result: _HistoryLabel('RESULT'),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 4),
        child: _HistoryLabel('STANDBY'),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final GuessRecord record;
  final int index;

  const _HistoryRow({required this.record, required this.index});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: index.isEven ? 0.024 : 0.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: _HistoryColumns(
          index: _HistoryText(
            '${record.attemptNumber}',
            color: const Color(0xFF8A8F98),
            fontSize: 15,
          ),
          code: _HistoryText(
            record.guess.join(),
            color: const Color(0xFFF2F2F2),
            fontSize: 24,
          ),
          result: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: _HistoryText(
                  'A${record.result.access}',
                  color: const Color(0xFF33D17A),
                  fontSize: 21,
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: _HistoryText(
                  'T${record.result.trace}',
                  color: const Color(0xFF4DA3FF),
                  fontSize: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistorySeparator extends StatelessWidget {
  const _HistorySeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.038),
          ),
        ),
      ),
    );
  }
}

class _HistoryColumns extends StatelessWidget {
  final Widget index;
  final Widget code;
  final Widget result;

  const _HistoryColumns({
    required this.index,
    required this.code,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40, child: index),
        Expanded(child: code),
        SizedBox(width: 112, child: result),
      ],
    );
  }
}

class _HistoryLabel extends StatelessWidget {
  final String text;

  const _HistoryLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFC5CBD4),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}

class _HistoryText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const _HistoryText(
    this.text, {
    this.color = Colors.white,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}
