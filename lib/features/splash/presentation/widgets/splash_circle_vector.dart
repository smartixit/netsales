import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// الرسوميات الخلفية الدائرية المتراكبة لشاشة الإقلاع
class SplashCircleVector extends StatelessWidget {
  const SplashCircleVector({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Positioned(
          top: -80.h,
          left: -60.w,
          child: Container(
            width: 260.r,
            height: 260.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: -30.h,
          left: -20.w,
          child: Container(
            width: 180.r,
            height: 180.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.04),
            ),
          ),
        ),
        Positioned(
          bottom: -100.h,
          right: -60.w,
          child: Container(
            width: 300.r,
            height: 300.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -40.h,
          right: 20.w,
          child: Container(
            width: 160.r,
            height: 160.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }
}

