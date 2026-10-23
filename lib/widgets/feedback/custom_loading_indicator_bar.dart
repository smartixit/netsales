import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';

class CustomLoadingIndicatorBar extends StatelessWidget {
  const CustomLoadingIndicatorBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 180.w,
      height: 4.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: LinearProgressIndicator(
          backgroundColor: colors.surface.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(colors.surface),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms);
  }
}
