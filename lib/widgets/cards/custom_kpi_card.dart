import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

// ─────────────────────────────────────────────────────────────────────────────
// أنماط KPI المدعومة (KpiCardVariant)
// ─────────────────────────────────────────────────────────────────────────────
/// يحدد الشكل البصري لبطاقة المؤشر.
///
/// - [compact]   : بطاقة صغيرة للشرائط الأفقية (مثل OperationsKpiStrip).
///                 أيقونة + عنوان صغير + قيمة + وحدة — بدون badge.
/// - [standard]  : بطاقة متوسطة لشبكات Bento وصفحات التحليل.
///                 أيقونة محاطة بخلفية لونية + عنوان + قيمة + وحدة + badge اختياري.
/// - [highlighted]: بطاقة standard مع إطار warning عند الحاجة للفت الانتباه.
enum KpiCardVariant { compact, standard, highlighted }

// ─────────────────────────────────────────────────────────────────────────────
// الودجت الرئيسي (CustomKpiCard)
// ─────────────────────────────────────────────────────────────────────────────
/// بطاقة مؤشر أداء رئيسي (KPI) قابلة لإعادة الاستخدام الكامل في أي ميزة.
///
/// ## المبدأ المعماري:
/// يعتمد نفس نمط [CustomButton] و [CustomDialog]:
/// - كلاس [StatelessWidget] أصيل يمكن استخدامه مباشرة في الشجرة.
/// - factories محددة الأغراض توفر واجهة API موحدة وواضحة.
/// - صفر أرقام سحرية — كل الأبعاد من [AppSpacing] و [AppRadius] و screenutil.
///
/// ## Factories المتاحة:
/// ```dart
/// // 1. للشرائط الأفقية المضغوطة (OperationsKpiStrip, الشرائط الصغيرة)
/// CustomKpiCard.compact(
///   title: 'إجمالي المبيعات',
///   value: '12,500',
///   unit: 'ر.ي',
///   icon: Icons.payments_outlined,
///   iconColor: colors.primary,
/// )
///
/// // 2. لشبكات Bento وصفحات التحليل
/// CustomKpiCard.standard(
///   title: 'إجمالي المبيعات',
///   value: '12,500',
///   unit: 'ر.ي',
///   icon: Icons.trending_up_rounded,
///   iconColor: colors.primary,
///   badgeText: '+12.5%',       // اختياري
///   isPositiveBadge: true,     // اختياري
/// )
///
/// // 3. بطاقة standard مع إطار تحذيري (طلبات معلقة، تحذيرات)
/// CustomKpiCard.highlighted(
///   title: 'الطلبات المعلقة',
///   value: '5',
///   unit: 'طلب',
///   icon: Icons.inventory_2_outlined,
///   iconColor: colors.warning,
/// )
/// ```
class CustomKpiCard extends StatelessWidget {
  // ── الخصائص المشتركة ──────────────────────────────────────────────────────
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color? iconColor;
  final KpiCardVariant variant;

  // ── خاصة بـ standard / highlighted ────────────────────────────────────────
  final String? badgeText;
  final bool isPositiveBadge;

  // ── تفاعل اختياري ─────────────────────────────────────────────────────────
  final VoidCallback? onTap;

  const CustomKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor,
    this.variant = KpiCardVariant.standard,
    this.badgeText,
    this.isPositiveBadge = true,
    this.onTap,
  });

  // ── 1. Factory: Compact ───────────────────────────────────────────────────
  /// بطاقة مضغوطة مناسبة للشرائط الأفقية.
  factory CustomKpiCard.compact({
    Key? key,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) =>
      CustomKpiCard(
        key: key,
        title: title,
        value: value,
        unit: unit,
        icon: icon,
        iconColor: iconColor,
        variant: KpiCardVariant.compact,
        onTap: onTap,
      );

  // ── 2. Factory: Standard ──────────────────────────────────────────────────
  /// بطاقة متوسطة لشبكات Bento، تدعم badge النمو اختيارياً.
  factory CustomKpiCard.standard({
    Key? key,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    Color? iconColor,
    String? badgeText,
    bool isPositiveBadge = true,
    VoidCallback? onTap,
  }) =>
      CustomKpiCard(
        key: key,
        title: title,
        value: value,
        unit: unit,
        icon: icon,
        iconColor: iconColor,
        variant: KpiCardVariant.standard,
        badgeText: badgeText,
        isPositiveBadge: isPositiveBadge,
        onTap: onTap,
      );

  // ── 3. Factory: Highlighted ───────────────────────────────────────────────
  /// بطاقة standard مع إطار warning — لفت الانتباه للطلبات المعلقة والتحذيرات.
  factory CustomKpiCard.highlighted({
    Key? key,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    Color? iconColor,
    String? badgeText,
    bool isPositiveBadge = false,
    VoidCallback? onTap,
  }) =>
      CustomKpiCard(
        key: key,
        title: title,
        value: value,
        unit: unit,
        icon: icon,
        iconColor: iconColor,
        variant: KpiCardVariant.highlighted,
        badgeText: badgeText,
        isPositiveBadge: isPositiveBadge,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    final child = switch (variant) {
      KpiCardVariant.compact => _CompactLayout(card: this),
      KpiCardVariant.standard => _StandardLayout(card: this),
      KpiCardVariant.highlighted => _StandardLayout(card: this, isHighlighted: true),
    };

    if (onTap != null) {
      return CustomInteractiveBounce(onTap: onTap!, child: child);
    }
    return child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// تخطيط Compact الداخلي
// ─────────────────────────────────────────────────────────────────────────────
class _CompactLayout extends StatelessWidget {
  final CustomKpiCard card;

  const _CompactLayout({required this.card});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = card.iconColor ?? colors.primary;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة + عنوان في صف واحد
          Row(
            children: [
              Icon(card.icon, color: iconColor, size: 16.r),
              AppSpacing.hXxs,
              Expanded(
                child: Text(
                  card.title,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vXs,
          // القيمة + الوحدة على نفس الخط (FittedBox لمنع الفيض)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  card.value,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.hXxs,
                Text(
                  card.unit,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// تخطيط Standard / Highlighted الداخلي
// ─────────────────────────────────────────────────────────────────────────────
class _StandardLayout extends StatelessWidget {
  final CustomKpiCard card;
  final bool isHighlighted;

  const _StandardLayout({
    required this.card,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = card.iconColor ?? colors.primary;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: isHighlighted
              ? colors.warning.withValues(alpha: 0.50)
              : colors.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف العليا: الأيقونة المحاطة + badge النمو الاختياري
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(card.icon, color: iconColor, size: 18.r),
              ),
              if (card.badgeText != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: card.isPositiveBadge
                        ? colors.success.withValues(alpha: 0.12)
                        : colors.error.withValues(alpha: 0.12),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    card.badgeText!,
                    style: AppTypography.labelSmall.copyWith(
                      color: card.isPositiveBadge ? colors.success : colors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),

          AppSpacing.vSm,

          // العنوان
          Text(
            card.title,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          AppSpacing.vXxs,

          // القيمة + الوحدة (FittedBox لمنع الفيض في الخطوط الكبيرة)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  card.value,
                  style: AppTypography.titleLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.hXs,
                Text(
                  card.unit,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
