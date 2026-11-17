import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';
import 'package:netsales/core/services/url_launcher_service.dart';

/// الحالات الموحدة المعتمدة لكل واجهات NetSales.
enum CustomStateKind {
  loading,
  empty,
  error,
  offline,
  pricingExpired,
}

/// طرق تقديم الحالة دون تغيير هويتها البصرية.
enum CustomStatePresentation {
  fullscreen,
  boxed,
  compact,
  banner,
}

/// مكوّن مركزي موحّد لحالات التحميل والفراغ والأخطاء والاتصال وانتهاء التعرفة.
///
/// تعتمد جميع الشاشات على هذا المكوّن، بينما تبقى مكونات Skeleton المتخصصة
/// متاحة للتحميل التدريجي داخل القوائم والجداول دون استبدال المحتوى المحمّل.
class CustomStateView extends StatelessWidget {
  const CustomStateView({
    super.key,
    required this.kind,
    required this.title,
    this.subtitle,
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel,
    this.icon,
    this.accentColor,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.technicalDetails,
    this.graphicSize,
    this.padding,
    this.showLoadingSkeleton = true,
  });

  const CustomStateView.loading({
    super.key,
    this.title = 'جارٍ تحميل البيانات',
    this.subtitle = 'نجهّز المحتوى المطلوب، يرجى الانتظار.',
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'جارٍ التحميل',
    this.icon = Icons.hourglass_top_rounded,
    this.accentColor,
    this.graphicSize,
    this.padding,
    this.showLoadingSkeleton = true,
  }) : kind = CustomStateKind.loading,
       actionLabel = null,
       actionIcon = null,
       onAction = null,
       secondaryActionLabel = null,
       secondaryActionIcon = null,
       onSecondaryAction = null,
       customAction = null,
       technicalDetails = null;

  const CustomStateView.empty({
    super.key,
    required this.title,
    this.subtitle,
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'لا توجد بيانات',
    this.icon = Icons.inbox_rounded,
    this.accentColor,
    this.actionLabel,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.empty,
       technicalDetails = null,
       showLoadingSkeleton = false;

  const CustomStateView.error({
    super.key,
    this.title = 'تعذر إكمال العملية',
    this.subtitle,
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'حدث خطأ',
    this.icon = Icons.error_outline_rounded,
    this.accentColor,
    this.actionLabel = 'إعادة المحاولة',
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.technicalDetails,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.error,
       showLoadingSkeleton = false;

  const CustomStateView.offline({
    super.key,
    this.title = 'الاتصال غير متاح',
    this.subtitle = 'تحقق من اتصال الإنترنت ثم أعد المحاولة.',
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'OFFLINE',
    this.icon = Icons.wifi_off_rounded,
    this.accentColor,
    this.actionLabel = 'إعادة فحص الاتصال',
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon = Icons.settings_outlined,
    this.onSecondaryAction,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.offline,
       technicalDetails = null,
       showLoadingSkeleton = false;

  const CustomStateView.pricingExpired({
    super.key,
    this.title = 'انتهت صلاحية التعرفة',
    this.subtitle = 'لم يعد عرض الأسعار الحالي صالحاً. حدّث التعرفة قبل إرسال الطلب.',
    this.presentation = CustomStatePresentation.boxed,
    this.badgeLabel = 'PRICING EXPIRED',
    this.icon = Icons.timer_off_rounded,
    this.accentColor,
    this.actionLabel = 'تحديث التعرفة',
    this.actionIcon = Icons.refresh_rounded,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customAction,
    this.graphicSize,
    this.padding,
  }) : kind = CustomStateKind.pricingExpired,
       technicalDetails = null,
       showLoadingSkeleton = false;

  final CustomStateKind kind;
  final String title;
  final String? subtitle;
  final CustomStatePresentation presentation;
  final String? badgeLabel;
  final IconData? icon;
  final Color? accentColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final Widget? customAction;
  final String? technicalDetails;
  final double? graphicSize;
  final EdgeInsetsGeometry? padding;
  final bool showLoadingSkeleton;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = accentColor ?? _resolveAccent(colors);

    if (presentation == CustomStatePresentation.banner) {
      return _buildBanner(context, accent);
    }

    if (presentation == CustomStatePresentation.compact) {
      return _buildCompact(context, accent);
    }

    final content = _buildContent(context, accent);
    if (presentation == CustomStatePresentation.fullscreen) {
      return Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding ?? EdgeInsets.all(AppSpacing.xl),
          child: content,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: accent.withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }

  Color _resolveAccent(AppColors colors) {
    return switch (kind) {
      CustomStateKind.loading => colors.primary,
      CustomStateKind.empty => colors.secondary,
      CustomStateKind.error => colors.error,
      CustomStateKind.offline => colors.warning,
      CustomStateKind.pricingExpired => colors.tertiary,
    };
  }

  String _defaultBadge() {
    return switch (kind) {
      CustomStateKind.loading => 'جارٍ التحميل',
      CustomStateKind.empty => 'لا توجد بيانات',
      CustomStateKind.error => 'حدث خطأ',
      CustomStateKind.offline => 'OFFLINE',
      CustomStateKind.pricingExpired => 'PRICING EXPIRED',
    };
  }

  IconData _defaultIcon() {
    return switch (kind) {
      CustomStateKind.loading => Icons.hourglass_top_rounded,
      CustomStateKind.empty => Icons.inbox_rounded,
      CustomStateKind.error => Icons.error_outline_rounded,
      CustomStateKind.offline => Icons.wifi_off_rounded,
      CustomStateKind.pricingExpired => Icons.timer_off_rounded,
    };
  }

  Widget _buildContent(BuildContext context, Color accent) {
    final colors = context.colors;
    final size = (graphicSize ?? 104).r;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 480.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeroGraphic(context, accent, size),
          AppSpacing.vMd,
          _buildBadge(context, accent),
          AppSpacing.vSm,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            AppSpacing.vXs,
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.55,
              ),
            ),
          ],
          if (kind == CustomStateKind.loading && showLoadingSkeleton) ...[
            AppSpacing.vMd,
            _LoadingPreview(accent: accent),
          ],
          if (_hasActions) ...[
            AppSpacing.vMd,
            _buildActions(context),
          ],
          if (technicalDetails != null && technicalDetails!.isNotEmpty) ...[
            AppSpacing.vMd,
            _buildTechnicalDetails(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroGraphic(BuildContext context, Color accent, double size) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size + 34.r,
      height: size + 34.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 34.r,
            height: size + 34.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? .20 : .12),
                  accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Container(
            width: size * .88,
            height: size * .88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceContainerLow.withValues(alpha: .9),
              border: Border.all(color: accent.withValues(alpha: .28), width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: .10),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          if (kind == CustomStateKind.loading)
            SizedBox(
              width: size * .62,
              height: size * .62,
              child: CircularProgressIndicator(
                strokeWidth: 3.r,
                color: accent,
                backgroundColor: accent.withValues(alpha: .12),
              ),
            ),
          if (kind != CustomStateKind.loading)
            Container(
              width: size * .58,
              height: size * .58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: .12),
                border: Border.all(color: accent.withValues(alpha: .28)),
              ),
              child: Icon(icon ?? _defaultIcon(), color: accent, size: size * .28),
            ),
          if (kind == CustomStateKind.loading)
            Icon(icon ?? _defaultIcon(), color: accent, size: size * .24),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: accent.withValues(alpha: .24)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon ?? _defaultIcon(), size: 13.r, color: accent),
        AppSpacing.hXxs,
        Text(
          badgeLabel ?? _defaultBadge(),
          style: AppTypography.badgeText.copyWith(color: accent, fontWeight: FontWeight.w800),
        ),
      ]),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (customAction != null) return customAction!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        if (actionLabel != null && onAction != null)
          CustomButton.primary(
            text: actionLabel!,
            icon: actionIcon ?? Icons.refresh_rounded,
            onPressed: onAction!,
            size: AppButtonSize.small,
          ),
        if (secondaryActionLabel != null && onSecondaryAction != null)
          CustomButton.outline(
            text: secondaryActionLabel!,
            icon: secondaryActionIcon,
            onPressed: onSecondaryAction!,
            size: AppButtonSize.small,
          ),
      ],
    );
  }

  Widget _buildTechnicalDetails(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .36)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          title: Text(
            'التفاصيل الفنية والدعم التقني',
            style: AppTypography.labelMedium.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: Icon(Icons.terminal_rounded, color: colors.onSurfaceVariant),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText(
                    technicalDetails!,
                    style: AppTypography.bodySmall.copyWith(color: colors.error, height: 1.4),
                  ),
                  AppSpacing.vSm,
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: CustomButton.text(
                      text: 'نسخ تفاصيل الخطأ',
                      icon: Icons.copy_rounded,
                      size: AppButtonSize.small,
                      onPressed: () async {
                        await UrlLauncherService.copyToClipboard(technicalDetails!);
                        CustomToast.show(message: 'تم نسخ تفاصيل الخطأ للحافظة', icon: Icons.copy_rounded);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, Color accent) {
    final colors = context.colors;
    return Padding(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 42.r,
          height: 42.r,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .10),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: .25)),
          ),
          child: Center(
            child: kind == CustomStateKind.loading
                ? SizedBox.square(dimension: 18.r, child: CircularProgressIndicator(strokeWidth: 2, color: accent))
                : Icon(icon ?? _defaultIcon(), color: accent, size: 20.r),
          ),
        ),
        AppSpacing.vXs,
        Text(title, textAlign: TextAlign.center, style: AppTypography.labelLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          AppSpacing.vXxs,
          Text(subtitle!, textAlign: TextAlign.center, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant, height: 1.4)),
        ],
        if (_hasActions) ...[AppSpacing.vXs, _buildActions(context)],
      ]),
    );
  }

  Widget _buildBanner(BuildContext context, Color accent) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: .20)),
      ),
      child: Row(children: [
        Icon(icon ?? _defaultIcon(), size: 17.r, color: accent),
        AppSpacing.hXs,
        Expanded(
          child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
        ),
        if (onAction != null)
          CustomButton.text(text: actionLabel ?? 'إعادة المحاولة', size: AppButtonSize.small, onPressed: onAction),
      ]),
    );
  }

  bool get _hasActions =>
      customAction != null ||
      (actionLabel != null && onAction != null) ||
      (secondaryActionLabel != null && onSecondaryAction != null);
}

class _LoadingPreview extends StatelessWidget {
  const _LoadingPreview({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300.w),
      child: Column(children: [
        _LoadingLine(widthFactor: 1, accent: accent),
        AppSpacing.vXs,
        _LoadingLine(widthFactor: .78, accent: accent),
        AppSpacing.vXs,
        _LoadingLine(widthFactor: .9, accent: accent),
      ]),
    );
  }
}

class _LoadingLine extends StatelessWidget {
  const _LoadingLine({required this.widthFactor, required this.accent});
  final double widthFactor;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 8.h,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: .75),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}
