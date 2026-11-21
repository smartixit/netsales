import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_hero_canvas.dart';

/// Vector scene painter for the WorkspaceNetworkIllustrationPainter workspace welcome illustration.
class WorkspaceNetworkIllustrationPainter extends CustomPainter {
  const WorkspaceNetworkIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    final scale = math.min(size.width / 1000, size.height / 700);
    final horizontalOffset = (size.width - 1000 * scale) / 2;
    final verticalOffset = size.height - 700 * scale;
    canvas.translate(horizontalOffset, verticalOffset);
    canvas.scale(scale);
    final artwork = WorkspaceHeroCanvas(canvas);
    _paintNetwork(canvas, artwork);
    canvas.restore();
  }

  void _paintNetwork(Canvas canvas, WorkspaceHeroCanvas artwork) {
    artwork.paintGround();

    // Distant low-rise blocks give the skyline depth behind the towers.
    final lowRise = artwork.polygon(const [
      Offset(28, 395),
      Offset(116, 354),
      Offset(205, 392),
      Offset(205, 580),
      Offset(28, 596),
    ]);
    canvas.drawPath(
      lowRise,
      artwork.linear(const Rect.fromLTWH(28, 354, 177, 242), const [
        Color(0xFF0B8490),
        Color(0xFF064E5E),
      ]),
    );
    final lowRiseRoof = artwork.polygon(const [
      Offset(28, 395),
      Offset(116, 354),
      Offset(205, 392),
      Offset(120, 437),
    ]);
    canvas.drawPath(lowRiseRoof, artwork.solid(const Color(0xFF43B9B6)));
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 2; col++) {
        final x = 56 + col * 62.0;
        final y = 458 + row * 54.0;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 37, 33),
            const Radius.circular(4),
          ),
          artwork.linear(Rect.fromLTWH(x, y, 37, 33), const [
            Color(0xFF0A5267),
            Color(0xFF28B9C4),
          ]),
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
    final mainSide = artwork.polygon(const [
      Offset(498, 70),
      Offset(632, 139),
      Offset(632, 564),
      Offset(498, 623),
    ]);
    canvas.drawShadow(mainSide, const Color(0xFF001B2C), 24, true);
    canvas.drawPath(
      mainSide,
      artwork.linear(const Rect.fromLTWH(498, 70, 134, 553), const [
        Color(0xFF168D9C),
        Color(0xFF06445D),
      ]),
    );
    final mainFront = artwork.polygon(const [
      Offset(278, 191),
      Offset(498, 70),
      Offset(498, 623),
      Offset(278, 657),
    ]);
    canvas.drawShadow(mainFront, const Color(0xFF001D27), 20, true);
    canvas.drawPath(
      mainFront,
      artwork.linear(const Rect.fromLTWH(278, 70, 220, 587), const [
        Color(0xFFF0FFFF),
        Color(0xFF77DCE6),
        Color(0xFF2E9EAE),
      ]),
    );
    canvas.drawPath(
      artwork.polygon(const [
        Offset(264, 190),
        Offset(498, 54),
        Offset(646, 132),
        Offset(632, 151),
        Offset(498, 91),
        Offset(282, 214),
      ]),
      artwork.solid(const Color(0xFFB9F8F3)),
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
        final window = artwork.polygon([
          Offset(x, y + 19),
          Offset(x + 67, y - 17),
          Offset(x + 67, y + 43),
          Offset(x, y + 79),
        ]);
        canvas.drawPath(window, artwork.solid(const Color(0xFF083E58)));
        final inner = artwork.polygon([
          Offset(x + 5, y + 23),
          Offset(x + 62, y - 8),
          Offset(x + 62, y + 38),
          Offset(x + 5, y + 70),
        ]);
        canvas.drawPath(
          inner,
          artwork.linear(Rect.fromLTWH(x, y - 17, 67, 96), const [
            Color(0xFF1FC0D2),
            Color(0xFF0C789A),
            Color(0xFF07506F),
          ]),
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
        final pane = artwork.polygon([
          Offset(x, y),
          Offset(x + 37, y + 19),
          Offset(x + 37, y + 73),
          Offset(x, y + 56),
        ]);
        canvas.drawPath(pane, artwork.solid(const Color(0xFF052F4B)));
        canvas.drawPath(
          artwork.polygon([
            Offset(x + 4, y + 5),
            Offset(x + 32, y + 20),
            Offset(x + 32, y + 65),
            Offset(x + 4, y + 52),
          ]),
          artwork.linear(Rect.fromLTWH(x, y, 37, 73), const [
            Color(0xFF1BAEC5),
            Color(0xFF07516D),
          ]),
        );
      }
    }

    // A second, shorter block sits to the right of the main tower.
    final secondSide = artwork.polygon(const [
      Offset(735, 255),
      Offset(852, 310),
      Offset(852, 559),
      Offset(735, 595),
    ]);
    canvas.drawPath(
      secondSide,
      artwork.linear(const Rect.fromLTWH(735, 255, 117, 340), const [
        Color(0xFF126F83),
        Color(0xFF064353),
      ]),
    );
    final secondFront = artwork.polygon(const [
      Offset(620, 300),
      Offset(735, 255),
      Offset(735, 595),
      Offset(620, 625),
    ]);
    canvas.drawPath(
      secondFront,
      artwork.linear(const Rect.fromLTWH(620, 255, 115, 370), const [
        Color(0xFF9DEAF0),
        Color(0xFF167E91),
      ]),
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
          artwork.solid(const Color(0xFF07516C)),
        );
        canvas.drawRect(
          Rect.fromLTWH(x + 4, y + 4, 22, 34),
          artwork.linear(Rect.fromLTWH(x + 4, y + 4, 22, 34), const [
            Color(0xFF21C0CC),
            Color(0xFF0B607A),
          ]),
        );
      }
    }

    // Distant tree silhouettes and layered foreground planting.
    artwork.drawTree(const Offset(105, 435), 0.72, const Color(0xFF087A6B));
    artwork.drawTree(const Offset(840, 426), 0.84, const Color(0xFF075D59));
    artwork.drawBush(const Offset(148, 590), 260, 125);
    artwork.drawBush(const Offset(365, 627), 270, 118);
    artwork.drawBush(const Offset(760, 606), 260, 132);
    artwork.drawBush(const Offset(955, 620), 180, 105);

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

  @override
  bool shouldRepaint(
    covariant WorkspaceNetworkIllustrationPainter oldDelegate,
  ) => false;
}
