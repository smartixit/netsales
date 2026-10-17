import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';

class CustomAppOutlineButton extends StatelessWidget {
  const CustomAppOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.width,
    this.height,
  });

  final String text;

  final VoidCallback onPressed;

  final IconData? icon;

  final bool loading;

  final bool enabled;

  final double? width;

  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final disabled = !enabled || loading;
    final effectiveHeight = height ?? 60.h;

    final button = OutlinedButton(
      onPressed: disabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      child: loading
          ? SizedBox(
              width: 22.w,
              height: 22.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: colors.primary, size: 20),
                  AppSpacing.hSm,
                ],
                Text(text, style: AppTypography.buttonText),
              ],
            ),
    );

    if (width != null) {
      return SizedBox(
        height: effectiveHeight,
        width: width,
        child: button,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: effectiveHeight,
          width: constraints.hasBoundedWidth ? double.infinity : null,
          child: button,
        );
      },
    );
  }
}
