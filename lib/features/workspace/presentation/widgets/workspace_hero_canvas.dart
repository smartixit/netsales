import 'package:flutter/material.dart';

/// Shared low-level drawing primitives for the feature's vector scenes.
class WorkspaceHeroCanvas {
  WorkspaceHeroCanvas(this.canvas);

  final Canvas canvas;

  Paint solid(Color color) => Paint()..color = color;

  Paint linear(
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

  Path polygon(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  void drawTree(Offset center, double scale, Color color) {
    final trunk = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 74 * scale),
      width: 17 * scale,
      height: 98 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(trunk, Radius.circular(6 * scale)),
      solid(const Color(0xFF063F43)),
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
        ).createShader(Rect.fromCircle(center: center, radius: 125 * scale)),
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

  void drawBush(Offset center, double width, double height) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
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

  void paintGround() {
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
      linear(const Rect.fromLTWH(0, 430, 1000, 270), const [
        Color(0xFF075D58),
        Color(0xFF03454A),
      ]),
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
      linear(const Rect.fromLTWH(0, 540, 1000, 160), const [
        Color(0xFF0A7165),
        Color(0xFF03444A),
      ]),
    );
  }
}
