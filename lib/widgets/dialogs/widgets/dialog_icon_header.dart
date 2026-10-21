import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// أنماط الحوارات الموحدة في النظام
enum DialogType {
  success,
  error,
  warning,
  info,
  danger,
  pending,
  confirmation,
  custom,
}

/// ودجت الترويسة والأيقونة لحوارات النظام (DialogIconHeader)
///
/// يدعم أنيميشن Lottie التفاعلي مع تدرج لوني ناعم متكيف مع نوع الحوار
/// وأيقونة طوارئ بديلة في حال تعذر تحميل الأنيميشن.
class DialogIconHeader extends StatelessWidget {
  final DialogType type;
  final Widget? customHeader;
  final String? customAnimationPath;

  const DialogIconHeader({
    super.key,
    required this.type,
    this.customHeader,
    this.customAnimationPath,
  });

  @override
  Widget build(BuildContext context) {
    if (customHeader != null) return customHeader!;

    final colors = context.colors;
    final isDanger = type == DialogType.danger || type == DialogType.error;
    final isPending = type == DialogType.pending;
    final isSuccess = type == DialogType.success;

    final topColor = switch (type) {
      DialogType.danger ||
      DialogType.error =>
        colors.error.withValues(alpha: 0.12),
      DialogType.pending ||
      DialogType.warning =>
        colors.warning.withValues(alpha: 0.12),
      DialogType.success => colors.success.withValues(alpha: 0.12),
      _ => colors.primary.withValues(alpha: 0.12),
    };

    final animationPath = customAnimationPath ?? _getAnimationPath(type);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            topColor,
            colors.surface,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 90.r,
          height: 90.r,
          child: Lottie.asset(
            animationPath,
            repeat: isPending,
            animate: true,
            errorBuilder: (_, __, ___) => _buildFallbackIcon(colors, isDanger, isPending, isSuccess),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(
    AppColors colors,
    bool isDanger,
    bool isPending,
    bool isSuccess,
  ) {
    final iconColor = isDanger
        ? colors.error
        : isPending
            ? colors.warning
            : isSuccess
                ? colors.success
                : colors.primary;

    final iconData = switch (type) {
      DialogType.success => Icons.check_circle_rounded,
      DialogType.error || DialogType.danger => Icons.error_rounded,
      DialogType.warning => Icons.warning_rounded,
      DialogType.pending => Icons.schedule_rounded,
      DialogType.confirmation => Icons.help_outline_rounded,
      _ => Icons.info_rounded,
    };

    return Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 38.r,
      ),
    );
  }

  static String _getAnimationPath(DialogType type) {
    switch (type) {
      case DialogType.success:
        return 'assets/animations/success.json';
      case DialogType.error:
      case DialogType.danger:
        return 'assets/animations/error.json';
      case DialogType.warning:
      case DialogType.confirmation:
        return 'assets/animations/warning.json';
      case DialogType.pending:
      case DialogType.info:
      case DialogType.custom:
        return 'assets/animations/info.json';
    }
  }
}
