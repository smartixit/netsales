import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// طبقة تأطير وتعتيم نافذة مسح الرمز (Enterprise Custom QR Scanner Overlay)
///
/// ويدجت مستقلة تماماً ومبنية كـ StatelessWidget مدمجة بالكامل مع التصميم
/// ترسم قناعاً شبه شفاف يحيط بنافذة المسح، مع زوايا تأطير منحنية فخمة.
class CustomQrScannerOverlay extends StatelessWidget {
  /// أبعاد نافذة المسح المربعة
  final double scanBoxSize;

  /// نصف قطر استدارة زوايا نافذة المسح
  final double borderRadius;

  /// لون أقواس وزوايا المسح
  final Color cornerColor;

  /// طول ضلع زوايا المسح
  final double cornerLength;

  /// سُمك خطوط زوايا المسح
  final double cornerStrokeWidth;

  /// لون القناع الخلفي المحيط بنافذة المسح
  final Color backdropColor;

  /// إزاحة النافذة عمودياً عن المركز
  final double verticalOffset;

  const CustomQrScannerOverlay({
    super.key,
    this.scanBoxSize = 260.0,
    this.borderRadius = 20.0,
    this.cornerColor = Colors.white,
    this.cornerLength = 36.0,
    this.cornerStrokeWidth = 4.0,
    this.backdropColor = const Color(0x99000000),
    this.verticalOffset = -40.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = scanBoxSize.r.clamp(160.0, constraints.maxWidth - 40.w);

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ScannerOverlayPainter(
            scanBoxSize: boxSize,
            borderRadius: borderRadius.r,
            cornerColor: cornerColor,
            cornerLength: cornerLength.r,
            cornerStrokeWidth: cornerStrokeWidth.r,
            backdropColor: backdropColor,
            verticalOffset: verticalOffset.h,
          ),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanBoxSize;
  final double borderRadius;
  final Color cornerColor;
  final double cornerLength;
  final double cornerStrokeWidth;
  final Color backdropColor;
  final double verticalOffset;

  _ScannerOverlayPainter({
    required this.scanBoxSize,
    required this.borderRadius,
    required this.cornerColor,
    required this.cornerLength,
    required this.cornerStrokeWidth,
    required this.backdropColor,
    required this.verticalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, (size.height / 2) + verticalOffset);

    final scanRect = Rect.fromCenter(
      center: center,
      width: scanBoxSize,
      height: scanBoxSize,
    );

    // 1. رسم القناع شبه الشفاف مع تفريغ نافذة المسح
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius)),
      );

    final maskPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final maskPaint = Paint()
      ..color = backdropColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, maskPaint);

    // 2. رسم زوايا التأطير المتقنة (Corner Brackets)
    final cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = scanRect.left;
    final top = scanRect.top;
    final right = scanRect.right;
    final bottom = scanRect.bottom;
    final radius = borderRadius;
    final length = cornerLength;

    // الزاوية العلوية اليسرى
    final topLeft = Path()
      ..moveTo(left, top + length)
      ..lineTo(left, top + radius)
      ..arcToPoint(Offset(left + radius, top), radius: Radius.circular(radius))
      ..lineTo(left + length, top);
    canvas.drawPath(topLeft, cornerPaint);

    // الزاوية العلوية اليمنى
    final topRight = Path()
      ..moveTo(right - length, top)
      ..lineTo(right - radius, top)
      ..arcToPoint(Offset(right, top + radius), radius: Radius.circular(radius))
      ..lineTo(right, top + length);
    canvas.drawPath(topRight, cornerPaint);

    // الزاوية السفلية اليسرى
    final bottomLeft = Path()
      ..moveTo(left, bottom - length)
      ..lineTo(left, bottom - radius)
      ..arcToPoint(
        Offset(left + radius, bottom),
        radius: Radius.circular(radius),
      )
      ..lineTo(left + length, bottom);
    canvas.drawPath(bottomLeft, cornerPaint);

    // الزاوية السفلية اليمنى
    final bottomRight = Path()
      ..moveTo(right - length, bottom)
      ..lineTo(right - radius, bottom)
      ..arcToPoint(
        Offset(right, bottom - radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(right, bottom - length);
    canvas.drawPath(bottomRight, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanBoxSize != scanBoxSize ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.cornerColor != cornerColor ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.cornerStrokeWidth != cornerStrokeWidth ||
        oldDelegate.backdropColor != backdropColor ||
        oldDelegate.verticalOffset != verticalOffset;
  }
}
