import 'package:flutter/material.dart';

/// Small normalized trend line. Input points are ordered chronologically.
class DashboardMetricSparkline extends StatelessWidget {
  const DashboardMetricSparkline({
    required this.points,
    required this.color,
    required this.fillColor,
    super.key,
  });

  final List<double> points;
  final Color color;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        points: points,
        color: color,
        fillColor: fillColor,
        isRtl: Directionality.of(context) == TextDirection.rtl,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.points,
    required this.color,
    required this.fillColor,
    required this.isRtl,
  });

  final List<double> points;
  final Color color;
  final Color fillColor;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.isEmpty) return;
    final path = Path();
    final fill = Path();
    for (var index = 0; index < points.length; index++) {
      final logicalX = size.width * index / (points.length - 1);
      final x = isRtl ? size.width - logicalX : logicalX;
      final y = size.height - (points[index] * (size.height - 4)) - 2;
      if (index == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      if (index == points.length - 1) {
        fill.lineTo(x, y);
        fill.lineTo(x, size.height);
        fill.close();
      }
    }
    canvas.drawPath(fill, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.isRtl != isRtl;
}
