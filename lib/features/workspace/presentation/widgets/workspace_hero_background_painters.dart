import 'package:flutter/material.dart';

/// Paints the luminous teal atmosphere and connected-node motif used by both
/// workspace welcome banners. All geometry is normalized to the supplied size.
class WorkspaceHeroBackdropPainter extends CustomPainter {
  const WorkspaceHeroBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintGlow(
      canvas,
      Offset(size.width * 0.12, size.height * 0.12),
      size.width * 0.62,
      const Color(0xFF35F0D0),
      0.55,
    );
    _paintGlow(
      canvas,
      Offset(size.width * 0.42, size.height * 0.52),
      size.width * 0.38,
      const Color(0xFF0AAE9D),
      0.17,
    );
    _paintGlow(
      canvas,
      Offset(size.width * 0.88, size.height * 0.15),
      size.width * 0.34,
      const Color(0xFF063F49),
      0.30,
    );

    final points = <Offset>[
      Offset(size.width * 0.075, size.height * 0.12),
      Offset(size.width * 0.245, size.height * 0.06),
      Offset(size.width * 0.425, size.height * 0.14),
      Offset(size.width * 0.625, size.height * 0.06),
      Offset(size.width * 0.835, size.height * 0.16),
      Offset(size.width * 0.965, size.height * 0.43),
      Offset(size.width * 0.08, size.height * 0.48),
      Offset(size.width * 0.285, size.height * 0.58),
      Offset(size.width * 0.505, size.height * 0.46),
      Offset(size.width * 0.72, size.height * 0.61),
      Offset(size.width * 0.91, size.height * 0.76),
      Offset(size.width * 0.43, size.height * 0.84),
    ];

    const edges = <(int, int)>[
      (0, 1),
      (0, 6),
      (1, 2),
      (1, 7),
      (2, 3),
      (2, 8),
      (3, 4),
      (3, 8),
      (4, 5),
      (4, 9),
      (5, 10),
      (6, 7),
      (7, 8),
      (7, 11),
      (8, 9),
      (9, 10),
      (9, 11),
    ];

    final linePaint = Paint()
      ..color = const Color(0xFFB5F7EA).withValues(alpha: 0.13)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    for (final edge in edges) {
      canvas.drawLine(points[edge.$1], points[edge.$2], linePaint);
    }

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final glowPaint = Paint()
        ..color = const Color(0xFF62E8D1).withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(point, index.isEven ? 5.2 : 3.8, glowPaint);
      canvas.drawCircle(
        point,
        index.isEven ? 2.3 : 1.7,
        Paint()..color = const Color(0xFF8DF5E2).withValues(alpha: 0.54),
      );
    }
  }

  void _paintGlow(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.32),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.48, 1],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant WorkspaceHeroBackdropPainter oldDelegate) =>
      false;
}

/// The warm curved ribbon is a foreground layer, not a flat stroke. Its
/// highlight, body and underside create the narrow satin-like gold sweep.
class WorkspaceHeroRibbonPainter extends CustomPainter {
  const WorkspaceHeroRibbonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;

    final ribbon = Path()
      ..moveTo(-w * 0.025, h * 0.675)
      ..cubicTo(
        w * 0.075,
        h * 0.735,
        w * 0.145,
        h * 0.875,
        w * 0.325,
        h * 0.925,
      )
      ..cubicTo(
        w * 0.395,
        h * 0.947,
        w * 0.455,
        h * 0.948,
        w * 0.515,
        h * 0.958,
      )
      ..lineTo(w * 0.515, h * 0.991)
      ..cubicTo(
        w * 0.365,
        h * 0.982,
        w * 0.265,
        h * 0.975,
        w * 0.155,
        h * 0.905,
      )
      ..cubicTo(
        w * 0.075,
        h * 0.852,
        w * 0.02,
        h * 0.798,
        -w * 0.025,
        h * 0.765,
      )
      ..close();

    canvas.drawShadow(ribbon, const Color(0xFF001F25), 5, true);
    canvas.drawPath(
      ribbon,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFE7AD),
            Color(0xFFE7B45D),
            Color(0xFFB97A2B),
          ],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromLTWH(0, h * 0.67, w * 0.54, h * 0.34)),
    );

    final highlight = Path()
      ..moveTo(-w * 0.02, h * 0.688)
      ..cubicTo(
        w * 0.09,
        h * 0.756,
        w * 0.17,
        h * 0.882,
        w * 0.325,
        h * 0.927,
      );
    canvas.drawPath(
      highlight,
      Paint()
        ..color = const Color(0xFFFFF0C8).withValues(alpha: 0.82)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant WorkspaceHeroRibbonPainter oldDelegate) =>
      false;
}
