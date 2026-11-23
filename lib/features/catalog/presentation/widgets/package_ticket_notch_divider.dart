import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// خط التخريم الفاصل لبطاقة الباقة (Ticket Notch Perforation Divider)
///
/// يحاكي التخريم الفيزيائي لقسائم الشحن والتذاكر الرقمية ليفصل هوية الباقة عن العرض التجاري
class PackageTicketNotchDivider extends StatelessWidget {
  const PackageTicketNotchDivider({
    super.key,
    this.punchRadius = 5.0,
    this.dashWidth = 4.0,
    this.dashSpace = 3.5,
  });

  final double punchRadius;
  final double dashWidth;
  final double dashSpace;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dividerColor = colors.outlineVariant.withValues(alpha: 0.4);

    return SizedBox(
      height: (punchRadius * 2 + 4).h,
      child: Row(
        children: [
          // ثقب التخريم الأيمن (Punch Dot)
          Container(
            width: (punchRadius * 2).r,
            height: (punchRadius * 2).r,
            decoration: BoxDecoration(
              color: dividerColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          // خط التخريم المنقط الممتد
          Expanded(
            child: CustomPaint(
              size: Size(double.infinity, 1.h),
              painter: _TicketDashedLinePainter(
                color: dividerColor,
                dashWidth: dashWidth.w,
                dashSpace: dashSpace.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // ثقب التخريم الأيسر (Punch Dot)
          Container(
            width: (punchRadius * 2).r,
            height: (punchRadius * 2).r,
            decoration: BoxDecoration(
              color: dividerColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketDashedLinePainter extends CustomPainter {
  const _TicketDashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(math.min(startX + dashWidth, size.width), y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _TicketDashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
