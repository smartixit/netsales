import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';

/// بطاقة قسم معلومات تفصيلية بأسلوب قيد الموحد (CustomDetailInfoSection) — عرض نقي.
class CustomDetailInfoSection extends StatelessWidget {
  const CustomDetailInfoSection({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    required this.children,
    this.padding,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs + 2.r),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, size: 18.sp, color: colors.primary),
                  ),
                  AppSpacing.hSm,
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          Padding(
            padding: padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// صف معلومة واحدة داخل [CustomDetailInfoSection] — يستقبل [onCopy] من الخارج.
class CustomDetailInfoTile extends StatelessWidget {
  const CustomDetailInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
    this.highlight = false,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final bool highlight;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final effectiveColor =
        valueColor ?? (highlight ? colors.primary : colors.onSurface);

    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: highlight ? colors.primary : colors.onSurfaceVariant,
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: effectiveColor,
                      fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onCopy != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: AppSpacing.sm),
                child: Icon(
                  Icons.copy_rounded,
                  size: 16.sp,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// فاصل موحّد بين صفوف [CustomDetailInfoSection].
class CustomDetailInfoDivider extends StatelessWidget {
  const CustomDetailInfoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Divider(
      height: 1,
      indent: AppSpacing.xl + AppSpacing.xs,
      color: colors.outlineVariant.withValues(alpha: 0.35),
    );
  }
}
