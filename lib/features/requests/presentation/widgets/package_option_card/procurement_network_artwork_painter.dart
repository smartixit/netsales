import 'package:flutter/material.dart';

/// رسام خلفية الشبكة والعقد المتصلة (Network Nodes Background Visual)
class ProcurementNetworkArtworkPainter extends CustomPainter {
  const ProcurementNetworkArtworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(size.width * .10, size.height * .16),
      Offset(size.width * .40, size.height * .11),
      Offset(size.width * .78, size.height * .19),
      Offset(size.width * .19, size.height * .46),
      Offset(size.width * .72, size.height * .52),
      Offset(size.width * .12, size.height * .82),
      Offset(size.width * .86, size.height * .83),
    ];
    final links = Paint()
      ..color = Colors.white.withValues(alpha: .24)
      ..strokeWidth = .8;
    for (var i = 0; i < points.length; i++) {
      for (var j = i + 1; j < points.length; j++) {
        if ((points[i] - points[j]).distance < size.width * .58) {
          canvas.drawLine(points[i], points[j], links);
        }
      }
    }
    final globe = Paint()
      ..color = Colors.white.withValues(alpha: .20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width * .49, size.height * .49);
    canvas.drawCircle(center, size.width * .41, globe);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .30,
        height: size.height * .80,
      ),
      globe,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .76,
        height: size.height * .25,
      ),
      globe,
    );
    final node = Paint()..color = const Color(0xFF8CFFE0);
    for (final point in points) {
      canvas.drawCircle(point, 2, node);
      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = const Color(0xFF8CFFE0).withValues(alpha: .24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
