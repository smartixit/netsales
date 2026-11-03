import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// الشارة الدلالية الموحدة لحالات النظام (Enterprise Semantic Status Badge)
/// تترجم النبرة الدلالية (SemanticTone) إلى مظهر بصري متناغم مع الهوية البصرية والوضع الليلي/النهاري
class CustomStatusBadge extends StatelessWidget {
  /// نص الشارة
  final String label;

  /// النبرة الدلالية البصرية
  final SemanticTone tone;

  /// أيقونة اختيارية مع الشارة
  final IconData? icon;

  /// إظهار نقطة مؤشر دائرية نابضة بالحالة
  final bool showDot;

  /// وضع الكثافة المصغرة (للجداول والبطاقات المضغوطة)
  final bool isCompact;

  const CustomStatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
    this.showDot = false,
    this.isCompact = false,
  });

  /// إنشاء شارة مباشرة من كائن العرض الدلالي (EnumPresentation)
  factory CustomStatusBadge.fromPresentation(
    EnumPresentation presentation, {
    Key? key,
    bool isCompact = false,
    bool showDot = false,
  }) {
    return CustomStatusBadge(
      key: key,
      label: presentation.label,
      tone: presentation.tone,
      icon: presentation.icon,
      showDot: showDot,
      isCompact: isCompact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = _resolvePalette(colors, tone);

    final horizontalPadding = isCompact ? 8.w : 10.w;
    final verticalPadding = isCompact ? 3.h : 4.h;
    final iconSize = isCompact ? 12.r : 14.r;
    final dotSize = isCompact ? 5.r : 6.r;
    final textStyle = isCompact
        ? AppTypography.badgeText.copyWith(
            color: palette.foreground,
            fontWeight: FontWeight.w700,
          )
        : AppTypography.labelSmall.copyWith(
            color: palette.foreground,
            fontWeight: FontWeight.bold,
          );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: palette.foreground,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.w),
          ] else if (icon != null) ...[
            Icon(icon, size: iconSize, color: palette.foreground),
            SizedBox(width: 4.w),
          ],
          Flexible(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgePalette _resolvePalette(AppColors colors, SemanticTone tone) {
    switch (tone) {
      case SemanticTone.success:
        return _BadgePalette(
          background: colors.success.withValues(alpha: 0.12),
          foreground: colors.success,
          border: colors.success.withValues(alpha: 0.28),
        );
      case SemanticTone.warning:
        return _BadgePalette(
          background: colors.warning.withValues(alpha: 0.12),
          foreground: colors.warning,
          border: colors.warning.withValues(alpha: 0.28),
        );
      case SemanticTone.danger:
        return _BadgePalette(
          background: colors.error.withValues(alpha: 0.12),
          foreground: colors.error,
          border: colors.error.withValues(alpha: 0.28),
        );
      case SemanticTone.info:
        return _BadgePalette(
          background: colors.primary.withValues(alpha: 0.10),
          foreground: colors.primary,
          border: colors.primary.withValues(alpha: 0.24),
        );
      case SemanticTone.primary:
        return _BadgePalette(
          background: colors.primary.withValues(alpha: 0.14),
          foreground: colors.primary,
          border: colors.primary.withValues(alpha: 0.32),
        );
      case SemanticTone.neutral:
        return _BadgePalette(
          background: colors.surfaceContainerHighest.withValues(alpha: 0.45),
          foreground: colors.onSurfaceVariant,
          border: colors.outlineVariant.withValues(alpha: 0.30),
        );
    }
  }
}

class _BadgePalette {
  final Color background;
  final Color foreground;
  final Color border;

  const _BadgePalette({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
