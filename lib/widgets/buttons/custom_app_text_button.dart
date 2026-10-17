import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';

class CustomAppTextButton extends StatelessWidget {
  const CustomAppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.padding,
  });

  final String text;

  final TextStyle? style;

  final VoidCallback onPressed;

  final IconData? icon;

  final bool loading;

  final bool enabled;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: enabled && !loading ? onPressed : null,

      style: TextButton.styleFrom(
        foregroundColor: colors.primary,

        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),

      child: loading
          ? SizedBox(
              width: 18.w,

              height: 18.h,

              child: CircularProgressIndicator(
                strokeWidth: 2,

                color: colors.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                if (icon != null) ...[Icon(icon, size: 18.sp), AppSpacing.hXs],

                Text(
                  text,
                  style:
                      style ??
                      Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: colors.primary),
                ),
              ],
            ),
    );
  }
}
