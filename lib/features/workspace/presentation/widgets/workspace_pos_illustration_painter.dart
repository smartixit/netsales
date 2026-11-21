import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_hero_canvas.dart';

/// Vector scene painter for the WorkspacePosIllustrationPainter workspace welcome illustration.
class WorkspacePosIllustrationPainter extends CustomPainter {
  const WorkspacePosIllustrationPainter();

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
    _paintStore(canvas, artwork);
    canvas.restore();
  }

  void _paintStore(Canvas canvas, WorkspaceHeroCanvas artwork) {
    artwork.paintGround();

    // Low warehouse volume behind the shop.
    final annex = artwork.polygon(const [
      Offset(54, 391),
      Offset(166, 347),
      Offset(244, 379),
      Offset(244, 536),
      Offset(54, 559),
    ]);
    canvas.drawPath(
      annex,
      artwork.linear(const Rect.fromLTWH(54, 347, 190, 212), const [
        Color(0xFF58B9BC),
        Color(0xFF0A5964),
      ]),
    );
    canvas.drawPath(
      artwork.polygon(const [
        Offset(54, 391),
        Offset(166, 347),
        Offset(244, 379),
        Offset(132, 425),
      ]),
      artwork.solid(const Color(0xFF9CE8D9)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(91, 437, 47, 75),
        const Radius.circular(3),
      ),
      artwork.solid(const Color(0xFF084C5A)),
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
      artwork.linear(const Rect.fromLTWH(0, 360, 1000, 200), const [
        Color(0xFF0A6C61),
        Color(0xFF03444A),
      ]),
    );

    // Main shop body, beveled right side and ground plinth.
    final side = artwork.polygon(const [
      Offset(665, 313),
      Offset(765, 352),
      Offset(765, 610),
      Offset(665, 628),
    ]);
    canvas.drawShadow(side, const Color(0xFF001F27), 20, true);
    canvas.drawPath(
      side,
      artwork.linear(const Rect.fromLTWH(665, 313, 100, 315), const [
        Color(0xFF8CCFC0),
        Color(0xFF367D79),
      ]),
    );
    final body = artwork.polygon(const [
      Offset(195, 315),
      Offset(665, 315),
      Offset(665, 628),
      Offset(195, 604),
    ]);
    canvas.drawShadow(body, const Color(0xFF001D28), 24, true);
    canvas.drawPath(
      body,
      artwork.linear(const Rect.fromLTWH(195, 315, 470, 313), const [
        Color(0xFFE7FFF6),
        Color(0xFFB7E9D9),
        Color(0xFF6EB8AC),
      ]),
    );
    canvas.drawPath(
      Path()
        ..moveTo(195, 315)
        ..lineTo(665, 315)
        ..lineTo(665, 340)
        ..lineTo(195, 340)
        ..close(),
      artwork.solid(const Color(0xFFF5FFF9)),
    );

    // Left display window with thick teal frame and reflective glass.
    final displayFrame = RRect.fromRectAndRadius(
      const Rect.fromLTWH(255, 405, 245, 177),
      const Radius.circular(9),
    );
    canvas.drawRRect(displayFrame, artwork.solid(const Color(0xFF0A4C5A)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(267, 417, 221, 153),
        const Radius.circular(5),
      ),
      artwork.linear(const Rect.fromLTWH(267, 417, 221, 153), const [
        Color(0xFF167F89),
        Color(0xFF084F61),
      ]),
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
      artwork.solid(const Color(0xFFB8F8EB).withValues(alpha: 0.24)),
    );

    // Narrow entrance door and its inset glass panel.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(540, 384, 104, 235),
        const Radius.circular(5),
      ),
      artwork.solid(const Color(0xFF174F58)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(551, 397, 82, 204),
        const Radius.circular(3),
      ),
      artwork.linear(const Rect.fromLTWH(551, 397, 82, 204), const [
        Color(0xFF2B9091),
        Color(0xFF0A5864),
      ]),
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
      artwork.solid(const Color(0xFFE7D6A6)),
    );

    // Canopy roof: dimensional top, alternating fabric panels and scallops.
    final canopyTop = artwork.polygon(const [
      Offset(130, 300),
      Offset(238, 178),
      Offset(700, 178),
      Offset(812, 300),
    ]);
    canvas.drawShadow(canopyTop, const Color(0xFF001B25), 18, true);
    canvas.drawPath(
      canopyTop,
      artwork.linear(const Rect.fromLTWH(130, 178, 682, 122), const [
        Color(0xFFEFFFF8),
        Color(0xFF8BCFC0),
        Color(0xFF3A9A8B),
      ]),
    );
    canvas.drawPath(
      artwork.polygon(const [
        Offset(228, 190),
        Offset(700, 190),
        Offset(783, 291),
        Offset(148, 291),
      ]),
      artwork.solid(const Color(0xFFEEFFF8)),
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
        ..cubicTo(right + 8, 323, right - 6, 338, (left + right) / 2, 340)
        ..cubicTo(left + 6, 338, left - 7, 323, left, 291)
        ..close();
      canvas.drawPath(
        stripe,
        artwork.linear(
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
    artwork.drawBush(const Offset(122, 600), 275, 122);
    artwork.drawBush(const Offset(355, 639), 285, 112);
    artwork.drawBush(const Offset(690, 622), 270, 125);
    artwork.drawBush(const Offset(950, 642), 190, 105);

    canvas.drawOval(
      const Rect.fromLTWH(140, 640, 680, 24),
      Paint()
        ..color = const Color(0xFF001F26).withValues(alpha: 0.33)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
    );
  }

  @override
  bool shouldRepaint(covariant WorkspacePosIllustrationPainter oldDelegate) =>
      false;
}
