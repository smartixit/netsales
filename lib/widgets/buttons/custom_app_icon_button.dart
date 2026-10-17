import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';

class CustomAppIconButton extends StatelessWidget {
  const CustomAppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 55,
  });

  final IconData icon;

  final VoidCallback onPressed;

  final String? tooltip;

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip ?? '',

      child: Material(
        color: colors.surfaceContainerHighest,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),

          onTap: onPressed,

          child: SizedBox(
            width: size.w,

            height: size.h,

            child: Icon(icon, color: colors.primary, size: 28.sp),
          ),
        ),
      ),
    );
  }
}
