import 'package:flutter/material.dart';

/// Design tokens for the hand-painted charts.
abstract final class ChartTheme {
  static const line = Color(0xFF1F7A62);
  static const grid = Color(0xFFEEEDF3);
  static const label = Color(0xFF717786);

  static const caption = TextStyle(
    color: label,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}

/// Revenue trend line with a soft gradient fill underneath.
///
/// Painted by hand rather than pulling in a charting package: the design only
/// needs one series, four gridlines and a highlighted point.
class RevenueChart extends StatelessWidget {
  const RevenueChart({
    required this.values,
    required this.labels,
    this.highlightIndex,
    super.key,
  });

  /// Revenue per bucket, in display order.
  final List<double> values;

  /// X-axis captions; rendered evenly spaced under the plot.
  final List<String> labels;

  /// Bucket to mark with a dot and tooltip.
  final int? highlightIndex;

  /// Most captions the axis shows; a 30-day series keeps every fifth or so.
  static const _maxAxisLabels = 6;

  /// Evenly spaced captions, always including the first and the last.
  List<String> _axisLabels() {
    if (labels.length <= _maxAxisLabels) return labels;
    final last = labels.length - 1;
    return [
      for (var slot = 0; slot < _maxAxisLabels; slot++)
        labels[(slot * last / (_maxAxisLabels - 1)).round()],
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return const SizedBox(
        height: 174,
        child: Center(
          child: Text('Not enough data yet', style: ChartTheme.caption),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 174,
          width: double.infinity,
          child: CustomPaint(
            painter: _RevenueChartPainter(
              values: values,
              highlightIndex: highlightIndex,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final label in _axisLabels())
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Color(0xFF717786),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  _RevenueChartPainter({required this.values, required this.highlightIndex});

  final List<double> values;
  final int? highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEDF3)
      ..strokeWidth = 0.855;

    for (var line = 0; line < 4; line++) {
      final dy = size.height * line / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    // A flat series would divide by zero; give it a nominal band instead.
    final span = (maxValue - minValue).abs() < 0.001 ? 1.0 : maxValue - minValue;

    Offset pointAt(int index) {
      final dx = size.width * index / (values.length - 1);
      // Leave 12% headroom top and bottom so the line never touches the edge.
      final normalised = (values[index] - minValue) / span;
      final dy = size.height * (0.88 - normalised * 0.76);
      return Offset(dx, dy);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var index = 1; index < values.length; index++) {
      final previous = pointAt(index - 1);
      final current = pointAt(index);
      // Horizontal control points give the gentle S-curve in the design.
      final controlX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ChartTheme.line.withValues(alpha: 0.3),
            ChartTheme.line.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = ChartTheme.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.565
        ..strokeCap = StrokeCap.round,
    );

    final highlight = highlightIndex;
    if (highlight != null && highlight >= 0 && highlight < values.length) {
      final point = pointAt(highlight);
      canvas.drawCircle(
        point,
        10,
        Paint()..color = ChartTheme.line.withValues(alpha: 0.1),
      );
      canvas.drawCircle(point, 5, Paint()..color = ChartTheme.line);
    }
  }

  @override
  bool shouldRepaint(_RevenueChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.highlightIndex != highlightIndex;
}
