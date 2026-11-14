import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ودجت زر الإجراء المركزي العائم المستقلة (FloatingCenterActionButton - Executive VIP Squircle)
class FloatingCenterActionButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onTap;

  const FloatingCenterActionButton({
    super.key,
    required this.icon,
    this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? 'إجراء سريع',
        child: Container(
          transform: Matrix4.translationValues(0, -6.h, 0),
          width: 46.r,
          height: 46.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            boxShadow: AppElevation.glow(
              context,
              colors.primary,
              alpha: 0.45,
              blur: 16.r,
            ),
          ),
          child: Center(
            child: Icon(icon, color: colors.onPrimary, size: 24.r),
          ),
        ),
      ),
    );
  }
}
