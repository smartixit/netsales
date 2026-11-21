import 'package:flutter/material.dart';

/// Foreground satin-like gold ribbon shared by the Network and POS hero banners.
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
