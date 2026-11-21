import 'dart:math' as math;

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

/// Vector artwork for the Network and POS welcome banners.
/// It intentionally contains no raster assets and scales to any banner size.
class WorkspaceHeroIllustrationPainter extends CustomPainter {
  const WorkspaceHeroIllustrationPainter({required this.isNetwork});

  final bool isNetwork;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    // Preserve the illustration's original 10:7 proportions. Independent
    // x/y scaling visibly flattens the buildings on narrow mobile layouts.
    final scale = math.min(size.width / 1000, size.height / 700);
    final horizontalOffset = (size.width - 1000 * scale) / 2;
    final verticalOffset = size.height - 700 * scale;
    canvas.translate(horizontalOffset, verticalOffset);
    canvas.scale(scale);
    if (isNetwork) {
      _paintNetwork(canvas);
    } else {
      _paintStore(canvas);
    }
    canvas.restore();
  }

  Paint _solid(Color color) => Paint()..color = color;

  Paint _linear(
    Rect rect,
    List<Color> colors, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return Paint()
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      ).createShader(rect);
  }

  Path _polygon(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  void _drawTree(Canvas canvas, Offset center, double scale, Color color) {
    final trunk = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 74 * scale),
      width: 17 * scale,
      height: 98 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(trunk, Radius.circular(6 * scale)),
      _solid(const Color(0xFF063F43)),
    );

    final foliage = Path()
      ..moveTo(center.dx, center.dy - 110 * scale)
      ..cubicTo(
        center.dx - 78 * scale,
        center.dy - 44 * scale,
        center.dx - 86 * scale,
        center.dy + 22 * scale,
        center.dx - 45 * scale,
        center.dy + 43 * scale,
      )
      ..cubicTo(
        center.dx - 94 * scale,
        center.dy + 72 * scale,
        center.dx - 52 * scale,
        center.dy + 111 * scale,
        center.dx,
        center.dy + 95 * scale,
      )
      ..cubicTo(
        center.dx + 58 * scale,
        center.dy + 115 * scale,
        center.dx + 91 * scale,
        center.dy + 59 * scale,
        center.dx + 48 * scale,
        center.dy + 38 * scale,
      )
      ..cubicTo(
        center.dx + 91 * scale,
        center.dy - 14 * scale,
        center.dx + 55 * scale,
        center.dy - 78 * scale,
        center.dx,
        center.dy - 110 * scale,
      )
      ..close();
    canvas.drawShadow(foliage, const Color(0xFF001F25), 12 * scale, true);
    canvas.drawPath(
      foliage,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.88),
            color,
            const Color(0xFF064B4C),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: 125 * scale),
        ),
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - 17 * scale, center.dy - 71 * scale)
        ..cubicTo(
          center.dx - 52 * scale,
          center.dy - 27 * scale,
          center.dx - 43 * scale,
          center.dy + 10 * scale,
          center.dx - 10 * scale,
          center.dy + 34 * scale,
        ),
      Paint()
        ..color = const Color(0xFF8BE5CB).withValues(alpha: 0.12)
        ..strokeWidth = 9 * scale
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawBush(Canvas canvas, Offset center, double width, double height) {
    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    final shape = Path()
      ..moveTo(rect.left, rect.bottom)
      ..cubicTo(
        rect.left - width * 0.03,
        rect.center.dy,
        rect.left + width * 0.11,
        rect.top + height * 0.12,
        rect.left + width * 0.29,
        rect.top + height * 0.29,
      )
      ..cubicTo(
        rect.left + width * 0.40,
        rect.top - height * 0.08,
        rect.center.dx - width * 0.06,
        rect.top + height * 0.02,
        rect.center.dx,
        rect.top + height * 0.20,
      )
      ..cubicTo(
        rect.center.dx + width * 0.14,
        rect.top - height * 0.07,
        rect.right - width * 0.18,
        rect.top + height * 0.15,
        rect.right - width * 0.25,
        rect.top + height * 0.42,
      )
      ..cubicTo(
        rect.right + width * 0.04,
        rect.center.dy,
        rect.right,
        rect.bottom - height * 0.08,
        rect.right,
        rect.bottom,
      )
      ..close();
    canvas.drawShadow(shape, const Color(0xFF001F24), 10, true);
    canvas.drawPath(
      shape,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF178B78),
            Color(0xFF087064),
            Color(0xFF03494B),
          ],
        ).createShader(rect),
    );
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + width * 0.28, rect.center.dy)
        ..quadraticBezierTo(
          rect.center.dx,
          rect.top + height * 0.28,
          rect.right - width * 0.20,
          rect.center.dy + height * 0.10,
        ),
      Paint()
        ..color = const Color(0xFF68D8B9).withValues(alpha: 0.17)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintGround(Canvas canvas) {
    final distantHill = Path()
      ..moveTo(0, 496)
      ..cubicTo(115, 430, 165, 480, 260, 462)
      ..cubicTo(365, 440, 410, 482, 515, 464)
      ..cubicTo(660, 437, 725, 483, 835, 455)
      ..cubicTo(920, 437, 956, 465, 1000, 456)
      ..lineTo(1000, 700)
      ..lineTo(0, 700)
      ..close();
    canvas.drawPath(
      distantHill,
      _linear(
        const Rect.fromLTWH(0, 430, 1000, 270),
        const [Color(0xFF075D58), Color(0xFF03454A)],
      ),
    );

    final foreground = Path()
      ..moveTo(0, 588)
      ..cubicTo(115, 535, 190, 580, 290, 564)
      ..cubicTo(410, 536, 468, 596, 588, 567)
      ..cubicTo(715, 536, 826, 598, 1000, 555)
      ..lineTo(1000, 700)
      ..lineTo(0, 700)
      ..close();
    canvas.drawPath(
      foreground,
      _linear(
        const Rect.fromLTWH(0, 540, 1000, 160),
        const [Color(0xFF0A7165), Color(0xFF03444A)],
      ),
    );
  }

  void _paintNetwork(Canvas canvas) {
    _paintGround(canvas);

    // Distant low-rise blocks give the skyline depth behind the towers.
    final lowRise = _polygon(const [
      Offset(28, 395),
      Offset(116, 354),
      Offset(205, 392),
      Offset(205, 580),
      Offset(28, 596),
    ]);
    canvas.drawPath(
      lowRise,
      _linear(
        const Rect.fromLTWH(28, 354, 177, 242),
        const [Color(0xFF0B8490), Color(0xFF064E5E)],
      ),
    );
    final lowRiseRoof = _polygon(const [
      Offset(28, 395),
      Offset(116, 354),
      Offset(205, 392),
      Offset(120, 437),
    ]);
    canvas.drawPath(lowRiseRoof, _solid(const Color(0xFF43B9B6)));
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 2; col++) {
        final x = 56 + col * 62.0;
        final y = 458 + row * 54.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 37, 33),
            const Radius.circular(4),
          ),
          _linear(
            Rect.fromLTWH(x, y, 37, 33),
            const [Color(0xFF0A5267), Color(0xFF28B9C4)],
          ),
        );
        canvas.drawLine(
          Offset(x + 5, y + 4),
          Offset(x + 27, y + 4),
          Paint()
            ..color = const Color(0xFFB6F5EC).withValues(alpha: 0.60)
            ..strokeWidth = 2,
        );
      }
    }

    // Main tower: bright glazed front plane and a deep, shaded side plane.
    final mainSide = _polygon(const [
      Offset(498, 70),
      Offset(632, 139),
      Offset(632, 564),
      Offset(498, 623),
    ]);
    canvas.drawShadow(mainSide, const Color(0xFF001B2C), 24, true);
    canvas.drawPath(
      mainSide,
      _linear(
        const Rect.fromLTWH(498, 70, 134, 553),
        const [Color(0xFF168D9C), Color(0xFF06445D)],
      ),
    );
    final mainFront = _polygon(const [
      Offset(278, 191),
      Offset(498, 70),
      Offset(498, 623),
      Offset(278, 657),
    ]);
    canvas.drawShadow(mainFront, const Color(0xFF001D27), 20, true);
    canvas.drawPath(
      mainFront,
      _linear(
        const Rect.fromLTWH(278, 70, 220, 587),
        const [Color(0xFFF0FFFF), Color(0xFF77DCE6), Color(0xFF2E9EAE)],
      ),
    );
    canvas.drawPath(
      _polygon(const [
        Offset(264, 190),
        Offset(498, 54),
        Offset(646, 132),
        Offset(632, 151),
        Offset(498, 91),
        Offset(282, 214),
      ]),
      _solid(const Color(0xFFB9F8F3)),
    );
    canvas.drawLine(
      const Offset(498, 74),
      const Offset(498, 621),
      Paint()
        ..color = const Color(0xFF053D55)
        ..strokeWidth = 8,
    );

    // Front curtain wall: eight cyan-lit glass panels with dark mullions.
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 2; col++) {
        final x = 300 + col * 86.0;
        final y = 244 + row * 91.0;
        final window = _polygon([
          Offset(x, y + 19),
          Offset(x + 67, y - 17),
          Offset(x + 67, y + 43),
          Offset(x, y + 79),
        ]);
        canvas.drawPath(
          window,
          _solid(const Color(0xFF083E58)),
        );
        final inner = _polygon([
          Offset(x + 5, y + 23),
          Offset(x + 62, y - 8),
          Offset(x + 62, y + 38),
          Offset(x + 5, y + 70),
        ]);
        canvas.drawPath(
          inner,
          _linear(
            Rect.fromLTWH(x, y - 17, 67, 96),
            const [
              Color(0xFF1FC0D2),
              Color(0xFF0C789A),
              Color(0xFF07506F),
            ],
          ),
        );
        canvas.drawPath(
          Path()
            ..moveTo(x + 11, y + 22)
            ..lineTo(x + 11, y + 66),
          Paint()
            ..color = const Color(0xFFB9F8F2).withValues(alpha: 0.68)
            ..strokeWidth = 3,
        );
        canvas.drawPath(
          Path()
            ..moveTo(x + 14, y + 18)
            ..lineTo(x + 52, y - 2),
          Paint()
            ..color = const Color(0xFFE3FFFF).withValues(alpha: 0.62)
            ..strokeWidth = 3,
        );
      }
    }

    // Side-plane windows follow the tower's receding perspective.
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 2; col++) {
        final x = 525 + col * 51.0;
        final y = 177 + row * 92.0;
        final pane = _polygon([
          Offset(x, y),
          Offset(x + 37, y + 19),
          Offset(x + 37, y + 73),
          Offset(x, y + 56),
        ]);
        canvas.drawPath(pane, _solid(const Color(0xFF052F4B)));
        canvas.drawPath(
          _polygon([
            Offset(x + 4, y + 5),
            Offset(x + 32, y + 20),
            Offset(x + 32, y + 65),
            Offset(x + 4, y + 52),
          ]),
          _linear(
            Rect.fromLTWH(x, y, 37, 73),
            const [Color(0xFF1BAEC5), Color(0xFF07516D)],
          ),
        );
      }
    }

    // A second, shorter block sits to the right of the main tower.
    final secondSide = _polygon(const [
      Offset(735, 255),
      Offset(852, 310),
      Offset(852, 559),
      Offset(735, 595),
    ]);
    canvas.drawPath(
      secondSide,
      _linear(
        const Rect.fromLTWH(735, 255, 117, 340),
        const [Color(0xFF126F83), Color(0xFF064353)],
      ),
    );
    final secondFront = _polygon(const [
      Offset(620, 300),
      Offset(735, 255),
      Offset(735, 595),
      Offset(620, 625),
    ]);
    canvas.drawPath(
      secondFront,
      _linear(
        const Rect.fromLTWH(620, 255, 115, 370),
        const [Color(0xFF9DEAF0), Color(0xFF167E91)],
      ),
    );
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 2; col++) {
        final x = 642 + col * 45.0;
        final y = 334 + row * 66.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 30, 42),
            const Radius.circular(2),
          ),
          _solid(const Color(0xFF07516C)),
        );
        canvas.drawRect(
          Rect.fromLTWH(x + 4, y + 4, 22, 34),
          _linear(
            Rect.fromLTWH(x + 4, y + 4, 22, 34),
            const [Color(0xFF21C0CC), Color(0xFF0B607A)],
          ),
        );
      }
    }

    // Distant tree silhouettes and layered foreground planting.
    _drawTree(canvas, const Offset(105, 435), 0.72, const Color(0xFF087A6B));
    _drawTree(canvas, const Offset(840, 426), 0.84, const Color(0xFF075D59));
    _drawBush(canvas, const Offset(148, 590), 260, 125);
    _drawBush(canvas, const Offset(365, 627), 270, 118);
    _drawBush(canvas, const Offset(760, 606), 260, 132);
    _drawBush(canvas, const Offset(955, 620), 180, 105);

    // Cool edge lights add the glossy, illustrated finish visible in the art.
    canvas.drawPath(
      Path()
        ..moveTo(278, 192)
        ..lineTo(498, 70)
        ..lineTo(498, 623),
      Paint()
        ..color = const Color(0xFFCCFFFF).withValues(alpha: 0.75)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawOval(
      const Rect.fromLTWH(180, 630, 610, 26),
      Paint()
        ..color = const Color(0xFF001E2C).withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  void _paintStore(Canvas canvas) {
    _paintGround(canvas);

    // Low warehouse volume behind the shop.
    final annex = _polygon(const [
      Offset(54, 391),
      Offset(166, 347),
      Offset(244, 379),
      Offset(244, 536),
      Offset(54, 559),
    ]);
    canvas.drawPath(
      annex,
      _linear(
        const Rect.fromLTWH(54, 347, 190, 212),
        const [Color(0xFF58B9BC), Color(0xFF0A5964)],
      ),
    );
    canvas.drawPath(
      _polygon(const [
        Offset(54, 391),
        Offset(166, 347),
        Offset(244, 379),
        Offset(132, 425),
      ]),
      _solid(const Color(0xFF9CE8D9)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(91, 437, 47, 75),
        const Radius.circular(3),
      ),
      _solid(const Color(0xFF084C5A)),
    );

    // Dark hills and stylized trees behind the storefront.
    final rearFoliage = Path()
      ..moveTo(0, 463)
      ..cubicTo(55, 389, 104, 400, 150, 464)
      ..cubicTo(205, 364, 270, 395, 305, 468)
      ..cubicTo(364, 378, 424, 393, 470, 472)
      ..cubicTo(550, 376, 650, 402, 688, 475)
      ..cubicTo(760, 393, 830, 409, 900, 482)
      ..lineTo(1000, 540)
      ..lineTo(0, 560)
      ..close();
    canvas.drawPath(
      rearFoliage,
      _linear(
        const Rect.fromLTWH(0, 360, 1000, 200),
        const [Color(0xFF0A6C61), Color(0xFF03444A)],
      ),
    );

    // Main shop body, beveled right side and ground plinth.
    final side = _polygon(const [
      Offset(665, 313),
      Offset(765, 352),
      Offset(765, 610),
      Offset(665, 628),
    ]);
    canvas.drawShadow(side, const Color(0xFF001F27), 20, true);
    canvas.drawPath(
      side,
      _linear(
        const Rect.fromLTWH(665, 313, 100, 315),
        const [Color(0xFF8CCFC0), Color(0xFF367D79)],
      ),
    );
    final body = _polygon(const [
      Offset(195, 315),
      Offset(665, 315),
      Offset(665, 628),
      Offset(195, 604),
    ]);
    canvas.drawShadow(body, const Color(0xFF001D28), 24, true);
    canvas.drawPath(
      body,
      _linear(
        const Rect.fromLTWH(195, 315, 470, 313),
        const [Color(0xFFE7FFF6), Color(0xFFB7E9D9), Color(0xFF6EB8AC)],
      ),
    );
    canvas.drawPath(
      Path()
        ..moveTo(195, 315)
        ..lineTo(665, 315)
        ..lineTo(665, 340)
        ..lineTo(195, 340)
        ..close(),
      _solid(const Color(0xFFF5FFF9)),
    );

    // Left display window with thick teal frame and reflective glass.
    final displayFrame = RRect.fromRectAndRadius(
      const Rect.fromLTWH(255, 405, 245, 177),
      const Radius.circular(9),
    );
    canvas.drawRRect(displayFrame, _solid(const Color(0xFF0A4C5A)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(267, 417, 221, 153),
        const Radius.circular(5),
      ),
      _linear(
        const Rect.fromLTWH(267, 417, 221, 153),
        const [Color(0xFF167F89), Color(0xFF084F61)],
      ),
    );
    canvas.drawLine(
      const Offset(377, 419),
      const Offset(377, 569),
      Paint()
        ..color = const Color(0xFFB4F5E9).withValues(alpha: 0.80)
        ..strokeWidth = 5,
    );
    canvas.drawPath(
      Path()
        ..moveTo(284, 548)
        ..lineTo(362, 429)
        ..lineTo(362, 450)
        ..lineTo(298, 557),
      _solid(const Color(0xFFB8F8EB).withValues(alpha: 0.24)),
    );

    // Narrow entrance door and its inset glass panel.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(540, 384, 104, 235),
        const Radius.circular(5),
      ),
      _solid(const Color(0xFF174F58)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(551, 397, 82, 204),
        const Radius.circular(3),
      ),
      _linear(
        const Rect.fromLTWH(551, 397, 82, 204),
        const [Color(0xFF2B9091), Color(0xFF0A5864)],
      ),
    );
    canvas.drawLine(
      const Offset(563, 407),
      const Offset(620, 466),
      Paint()
        ..color = const Color(0xFFC4FFF0).withValues(alpha: 0.42)
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      const Offset(618, 510),
      5,
      _solid(const Color(0xFFE7D6A6)),
    );

    // Canopy roof: dimensional top, alternating fabric panels and scallops.
    final canopyTop = _polygon(const [
      Offset(130, 300),
      Offset(238, 178),
      Offset(700, 178),
      Offset(812, 300),
    ]);
    canvas.drawShadow(canopyTop, const Color(0xFF001B25), 18, true);
    canvas.drawPath(
      canopyTop,
      _linear(
        const Rect.fromLTWH(130, 178, 682, 122),
        const [Color(0xFFEFFFF8), Color(0xFF8BCFC0), Color(0xFF3A9A8B)],
      ),
    );
    canvas.drawPath(
      _polygon(const [
        Offset(228, 190),
        Offset(700, 190),
        Offset(783, 291),
        Offset(148, 291),
      ]),
      _solid(const Color(0xFFEEFFF8)),
    );

    const stripeColors = <Color>[
      Color(0xFF19A995),
      Color(0xFFF1FFF8),
      Color(0xFF1DAD9B),
      Color(0xFFF4FFF9),
      Color(0xFF149C91),
      Color(0xFFF4FFF8),
    ];
    for (var index = 0; index < stripeColors.length; index++) {
      final left = 150 + index * 105.0;
      final right = left + 105;
      final topLeft = 230 + index * 78.0;
      final topRight = topLeft + 78;
      final stripe = Path()
        ..moveTo(topLeft, 190)
        ..lineTo(topRight, 190)
        ..lineTo(right, 291)
        ..cubicTo(
          right + 8,
          323,
          right - 6,
          338,
          (left + right) / 2,
          340,
        )
        ..cubicTo(
          left + 6,
          338,
          left - 7,
          323,
          left,
          291,
        )
        ..close();
      canvas.drawPath(
        stripe,
        _linear(
          Rect.fromLTWH(left, 190, right - left, 150),
          [stripeColors[index], stripeColors[index].withValues(alpha: 0.84)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
      canvas.drawPath(
        Path()
          ..moveTo(left + 7, 202)
          ..lineTo(left + 7, 286),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.23)
          ..strokeWidth = 3,
      );
    }

    // Crisp fascia line and side awning edge finish the illustrated canopy.
    canvas.drawPath(
      Path()
        ..moveTo(143, 293)
        ..quadraticBezierTo(467, 309, 800, 293),
      Paint()
        ..color = const Color(0xFFB5F9E9)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(700, 178)
        ..lineTo(812, 300)
        ..lineTo(804, 335),
      Paint()
        ..color = const Color(0xFF0A6F6D)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke,
    );

    // Foreground shrubs overlap the base of the shop, as in the reference art.
    _drawBush(canvas, const Offset(122, 600), 275, 122);
    _drawBush(canvas, const Offset(355, 639), 285, 112);
    _drawBush(canvas, const Offset(690, 622), 270, 125);
    _drawBush(canvas, const Offset(950, 642), 190, 105);

    canvas.drawOval(
      const Rect.fromLTWH(140, 640, 680, 24),
      Paint()
        ..color = const Color(0xFF001F26).withValues(alpha: 0.33)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
    );
  }

  @override
  bool shouldRepaint(covariant WorkspaceHeroIllustrationPainter oldDelegate) =>
      oldDelegate.isNetwork != isNetwork;
}
