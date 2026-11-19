import 'package:flutter/material.dart';

/// رسام تذكرة الكرت المصغرة (Voucher Ticket Visual)
class ProcurementVoucherTicketPainter extends CustomPainter {
  const ProcurementVoucherTicketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ticketRect = Rect.fromLTWH(
      size.width * .06,
      size.height * .035,
      size.width * .88,
      size.height * .93,
    );
    final ticket = Path()
      ..addRRect(
        RRect.fromRectAndRadius(ticketRect, Radius.circular(size.width * .10)),
      );
    final perforationX = size.width * .72;
    final cutouts = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(ticketRect.left, size.height * .53),
          radius: size.width * .075,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(ticketRect.right, size.height * .53),
          radius: size.width * .075,
        ),
      );
    final ticketPath = Path.combine(PathOperation.difference, ticket, cutouts);

    canvas.drawShadow(
      ticketPath,
      const Color(0xFF001F18).withValues(alpha: .30),
      5,
      true,
    );
    canvas.drawPath(
      ticketPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFE7F8F1), Color(0xFFB9E6D7)],
        ).createShader(ticketRect),
    );
    canvas.drawPath(
      ticketPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF087B61).withValues(alpha: .48),
    );

    final perforation = Paint()
      ..color = const Color(0xFF087B61).withValues(alpha: .58)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (
      var y = size.height * .18;
      y < size.height * .84;
      y += size.height * .09
    ) {
      canvas.drawLine(
        Offset(perforationX, y),
        Offset(perforationX, y + size.height * .035),
        perforation,
      );
    }

    final sealCenter = Offset(size.width * .37, size.height * .30);
    canvas.drawCircle(
      sealCenter,
      size.width * .115,
      Paint()..color = const Color(0xFFD8AA45),
    );
    canvas.drawCircle(
      sealCenter,
      size.width * .082,
      Paint()..color = const Color(0xFFFFF3C8),
    );
    final seal = Path()
      ..moveTo(sealCenter.dx, sealCenter.dy - size.width * .045)
      ..lineTo(
        sealCenter.dx + size.width * .012,
        sealCenter.dy - size.width * .012,
      )
      ..lineTo(sealCenter.dx + size.width * .047, sealCenter.dy)
      ..lineTo(
        sealCenter.dx + size.width * .012,
        sealCenter.dy + size.width * .012,
      )
      ..lineTo(sealCenter.dx, sealCenter.dy + size.width * .047)
      ..lineTo(
        sealCenter.dx - size.width * .012,
        sealCenter.dy + size.width * .012,
      )
      ..lineTo(sealCenter.dx - size.width * .047, sealCenter.dy)
      ..lineTo(
        sealCenter.dx - size.width * .012,
        sealCenter.dy - size.width * .012,
      )
      ..close();
    canvas.drawPath(seal, Paint()..color = const Color(0xFF98702B));

    final barcode = Paint()
      ..color = const Color(0xFF075C49)
      ..strokeCap = StrokeCap.square;
    final bars = <double>[.18, .22, .27, .31, .37, .41, .47, .53, .58, .63];
    for (var i = 0; i < bars.length; i++) {
      barcode.strokeWidth = i.isEven ? 1.8 : 1;
      final x = size.width * bars[i];
      canvas.drawLine(
        Offset(x, size.height * .62),
        Offset(x, size.height * (i % 3 == 0 ? .82 : .77)),
        barcode,
      );
    }

    final captionPaint = Paint()
      ..color = const Color(0xFF087B61).withValues(alpha: .65)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .19, size.height * .48),
      Offset(size.width * .55, size.height * .48),
      captionPaint,
    );
    canvas.drawLine(
      Offset(size.width * .24, size.height * .54),
      Offset(size.width * .50, size.height * .54),
      captionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
