import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One wedge of a [DonutChart], and one row of its legend.
class DonutSlice {
  const DonutSlice({
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
    this.displayValue,
  });

  final String label;

  /// Share of the whole. Any scale — the chart normalises them.
  final double value;
  final Color color;

  /// Colour of the amount in the legend; defaults to [color].
  final Color? valueColor;

  /// Pre-formatted amount, e.g. "₹2500" or "500".
  final String? displayValue;
}

/// Ring chart with a centred total and a percentage bubble on each wedge.
///
/// Painted by hand rather than pulling in a charting package: the design only
/// needs one ring with three or four wedges.
class DonutChart extends StatelessWidget {
  const DonutChart({
    required this.slices,
    required this.centreValue,
    required this.centreLabel,
    this.size = 128,
    this.strokeWidth = 16,
    super.key,
  });

  final List<DonutSlice> slices;

  /// Big number in the hole, e.g. "₹4500".
  final String centreValue;

  /// Caption under it, e.g. "TOTAL".
  final String centreLabel;

  final double size;
  final double strokeWidth;

  double get _total =>
      slices.fold<double>(0, (sum, slice) => sum + slice.value);

  @override
  Widget build(BuildContext context) {
    final total = _total;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              slices: slices,
              total: total,
              strokeWidth: strokeWidth,
            ),
          ),
          // The hole is sized from the ring, so the label always clears it.
          SizedBox(
            width: size - strokeWidth * 2.6,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centreValue,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A1C1E),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    centreLabel.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6F7A74),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (total > 0)
            for (final bubble in _bubbles(total))
              Positioned(
                left: bubble.offset.dx,
                top: bubble.offset.dy,
                child: _PercentBubble(percent: bubble.percent),
              ),
        ],
      ),
    );
  }

  /// Places a percentage bubble at the midpoint of each wedge.
  List<({Offset offset, int percent})> _bubbles(double total) {
    const bubbleSize = 25.0;
    final radius = (size - strokeWidth) / 2;
    final centre = size / 2;

    var startAngle = -math.pi / 2;
    final result = <({Offset offset, int percent})>[];

    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      final mid = startAngle + sweep / 2;
      result.add((
        offset: Offset(
          centre + radius * math.cos(mid) - bubbleSize / 2,
          centre + radius * math.sin(mid) - bubbleSize / 2,
        ),
        percent: ((slice.value / total) * 100).round(),
      ));
      startAngle += sweep;
    }

    return result;
  }
}

class _PercentBubble extends StatelessWidget {
  const _PercentBubble({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$percent%',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.slices,
    required this.total,
    required this.strokeWidth,
  });

  final List<DonutSlice> slices;
  final double total;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Track, so the ring still reads as a ring when there is no data.
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.89
        ..color = const Color(0xFFF3F3F6),
    );

    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = slice.color,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.slices != slices ||
      oldDelegate.total != total ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// The label / amount rows beside the ring.
class DonutLegend extends StatelessWidget {
  const DonutLegend({required this.slices, super.key});

  final List<DonutSlice> slices;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < slices.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          _LegendRow(slice: slices[index]),
        ],
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.slice});

  final DonutSlice slice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: slice.color,
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        const SizedBox(width: 12),
        // The label takes the slack so a long one ellipsises rather than
        // pushing the amount off the edge.
        Expanded(
          child: Text(
            slice.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF3E4944),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          slice.displayValue ?? '${slice.value.round()}',
          style: TextStyle(
            color: slice.valueColor ?? slice.color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
