import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/color_resolver.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';

/// بطاقة باقة كروت الإنترنت — تصميم واجهة العرض المميزة (Showcase Data Plan Card)
///
/// تم بناء التصميم ليعكس هوية الباقات الرقمية الحديثة مع وضوح مالي تام:
/// 1. مساحة علوية هادئة بتدرج لوني خافت مشتق من لون الباقة مع هالة بصرية ناعمة.
/// 2. إبراز سعة البيانات برقم عملاق واضح ووحدة ملوّنة مع وسم السعر الرسمي للكرت.
/// 3. وسوم مواصفات خفيفة ومستديرة (عدد الكروت، الصلاحية، وقت الاستخدام، السعر الرسمي).
/// 4. قسم مالي وتجاري فائق الوضوح:
///    - إبراز السعر الرسمي الأساسي للحزمة والكرت بصراحة.
///    - بطاقتان مقارنتان صريحتان للشراء النقدي والآجل (سعر الكرت الصافي، إجمالي الحزمة، نسبة الخصم ومبلغ التوفير).
/// 5. قائمة إجراءات موحدة عبر [CustomPopupMenu].
class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    required this.onDetails,
    this.isExpanded = false,
    this.onToggleExpand,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
    this.canEdit = true,
    this.canDelete = true,
    this.actions,
  });

  final PackageEntity package;
  final VoidCallback onDetails;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = ColorResolver.resolve(
      package.packageColor,
      colors.primary,
    );
    final statusPres = EnumPresentationRegistry.resolvePackageStatus(
      package.packageStatus,
    );

    final hasAdminActions =
        (canEdit && (onEdit != null || onToggleStatus != null)) ||
        (canDelete && onDelete != null);

    final balanceParts = _splitBalance(package.balanceDisplay);

    final cardContent = Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppElevation.level2(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── القسم العلوي: اللوحة الملونة الاستعراضية ──
          _CardShowcase(
            package: package,
            accentColor: accentColor,
            statusLabel: statusPres.label,
            statusTone: statusPres.tone,
            balanceParts: balanceParts,
            hasAdminActions: hasAdminActions,
            canEdit: canEdit,
            canDelete: canDelete,
            onEdit: onEdit,
            onToggleStatus: onToggleStatus,
            onDelete: onDelete,
          ),

          // ── القسم السفلي: شبكة التسعير الشفافة والزر التفاعلي ──
          _CardCommercial(package: package, onDetails: onDetails),
        ],
      ),
    );

    return CustomInteractiveBounce(
      onTap: onDetails,
      child: package.isActive
          ? cardContent
          : Opacity(opacity: 0.75, child: cardContent),
    );
  }

  /// يفصل نص الرصيد مثل "3 جيجابايت" إلى رقم ووحدة
  static _BalanceParts _splitBalance(String display) {
    final trimmed = display.trim();
    final match = RegExp(r'^([\d.,]+)\s*(.*)$').firstMatch(trimmed);
    if (match != null) {
      return _BalanceParts(
        number: match.group(1) ?? trimmed,
        unit: match.group(2) ?? '',
      );
    }
    return _BalanceParts(number: trimmed, unit: '');
  }
}

class _BalanceParts {
  const _BalanceParts({required this.number, required this.unit});
  final String number;
  final String unit;
}

/// القسم العلوي الاستعراضي للبطاقة (Showcase Zone)
class _CardShowcase extends StatelessWidget {
  const _CardShowcase({
    required this.package,
    required this.accentColor,
    required this.statusLabel,
    required this.statusTone,
    required this.balanceParts,
    required this.hasAdminActions,
    required this.canEdit,
    required this.canDelete,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  final PackageEntity package;
  final Color accentColor;
  final String statusLabel;
  final SemanticTone statusTone;
  final _BalanceParts balanceParts;
  final bool hasAdminActions;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // الخلفية الملونة الناعمة
        Positioned.fill(
          child: Container(color: accentColor.withValues(alpha: 0.07)),
        ),

        // الهالة الدائرية الزخرفية في الزاوية
        Positioned(
          top: -40.r,
          left: -30.r,
          child: Container(
            width: 140.r,
            height: 140.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.05),
            ),
          ),
        ),

        // المحتوى الرئيسي
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ═══ الصف العلوي: الحالة + القائمة المنسدلة الموحدة ═══
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomStatusBadge(
                    label: statusLabel,
                    tone: statusTone,
                    isCompact: true,
                    showDot: true,
                  ),
                  if (hasAdminActions)
                    CustomPopupMenu<String>(
                      triggerDimension: 28.r,
                      triggerIconSize: 16.r,
                      triggerIcon: Icons.more_vert_rounded,
                      triggerBackgroundColor: colors.surface.withValues(
                        alpha: 0.85,
                      ),
                      triggerIconColor: colors.onSurfaceVariant,
                      items: [
                        if (canEdit && onEdit != null)
                          const CustomPopupItem(
                            value: 'edit',
                            label: 'تعديل',
                            icon: Icons.edit_outlined,
                          ),
                        if (canEdit && onToggleStatus != null)
                          CustomPopupItem(
                            value: 'status',
                            label: package.isActive ? 'تعطيل' : 'تفعيل',
                            icon: package.isActive
                                ? Icons.pause_circle_outline_rounded
                                : Icons.play_circle_outline_rounded,
                            iconColor: package.isActive
                                ? colors.amberAccent
                                : colors.success,
                          ),
                        if (canDelete && onDelete != null && canEdit)
                          const CustomPopupDivider(),
                        if (canDelete && onDelete != null)
                          const CustomPopupItem(
                            value: 'delete',
                            label: 'حذف',
                            icon: Icons.delete_outline_rounded,
                            isDestructive: true,
                          ),
                      ],
                      onSelected: (val) {
                        if (val == 'edit') onEdit?.call();
                        if (val == 'status') onToggleStatus?.call();
                        if (val == 'delete') onDelete?.call();
                      },
                    ),
                ],
              ),

              SizedBox(height: 10.h),

              // ═══ بطل البطاقة: سعة البيانات الضخمة ═══
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    balanceParts.number,
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w800,
                      color: package.isActive
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (balanceParts.unit.isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        balanceParts.unit,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: package.isActive
                              ? accentColor
                              : colors.onSurfaceVariant,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 6.h),

              // ═══ اسم الباقة ═══
              Text(
                package.packageName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 10.h),

              // ═══ وسوم المواصفات المدمجة (Specs Tags) ═══
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  _SpecTag(
                    icon: Icons.layers_outlined,
                    label: '${package.packageVoucherCount} كرت',
                  ),
                  _SpecTag(
                    icon: Icons.calendar_today_outlined,
                    label: package.validityDisplay,
                  ),
                  if (package.packageUptime != null &&
                      package.packageUptime! > 0)
                    _SpecTag(
                      icon: Icons.timer_outlined,
                      label: package.uptimeDisplay,
                    ),
                  if (package.networkName != null &&
                      package.networkName!.isNotEmpty)
                    _SpecTag(
                      icon: Icons.hub_outlined,
                      label: package.networkName!,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// وسم المواصفة البيضاوي الأنيق
class _SpecTag extends StatelessWidget {
  const _SpecTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.12),
          width: 0.8.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.r,
            color: colors.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTypography.badgeText.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// القسم التجاري والتسعيري الشفاف للبطاقة (Commercial & Pricing Zone)
class _CardCommercial extends StatelessWidget {
  const _CardCommercial({required this.package, required this.onDetails});

  final PackageEntity package;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cashDiscountPct = package.packageDefaultCashDiscount;
    final creditDiscountPct = package.packageDefaultCreditDiscount;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outline.withValues(alpha: 0.08),
            width: 1.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ═══ السعر الرسمي الأساسي المعلن للباقة ═══
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.12),
                width: 0.8.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sell_outlined,
                      size: 14.r,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'السعر الرسمي الأساسي:',
                      style: AppTypography.badgeText.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${AmountFormatter.formatValue(package.packageVoucherPrice)} ر.ي',
                        style: AppTypography.badgeText.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' (${AmountFormatter.formatValue(package.unitVoucherPrice)} للكرت)',
                        style: AppTypography.badgeText.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // ═══ بطاقتا المقارنة الصريحة (شراء نقدي vs شراء آجل) ═══
          Row(
            children: [
              // مسار الشراء النقدي
              Expanded(
                child: _DealPathCard(
                  title: 'شراء نقدي',
                  icon: Icons.payments_rounded,
                  themeColor: colors.success,
                  discountPercent: cashDiscountPct,
                  effectiveTotalPrice: package.effectiveCashPrice,
                  unitPrice: package.unitCashPrice,
                  savingsAmount: package.cashDiscountAmount,
                ),
              ),

              SizedBox(width: 8.w),

              // مسار الشراء الآجل
              Expanded(
                child: _DealPathCard(
                  title: 'شراء آجل',
                  icon: Icons.credit_score_rounded,
                  themeColor: colors.info,
                  discountPercent: creditDiscountPct,
                  effectiveTotalPrice: package.effectiveCreditPrice,
                  unitPrice: package.unitCreditPrice,
                  savingsAmount: package.creditDiscountAmount,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ═══ زر استعراض التفاصيل ═══
          CustomInteractiveBounce(
            onTap: onDetails,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 9.h),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.12),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'عرض تفاصيل الباقة الكاملة',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 12.r,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة مقارنة مسار الشراء (نقدي أو آجل)
class _DealPathCard extends StatelessWidget {
  const _DealPathCard({
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.discountPercent,
    required this.effectiveTotalPrice,
    required this.unitPrice,
    required this.savingsAmount,
  });

  final String title;
  final IconData icon;
  final Color themeColor;
  final double discountPercent;
  final double effectiveTotalPrice;
  final double unitPrice;
  final double savingsAmount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(9.r),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.22),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── العنوان وشارة الخصم ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13.r, color: themeColor),
                  SizedBox(width: 4.w),
                  Text(
                    title,
                    style: AppTypography.badgeText.copyWith(
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              if (discountPercent > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'خصم ${discountPercent.toStringAsFixed(0)}%',
                    style: AppTypography.badgeText.copyWith(
                      color: themeColor,
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 6.h),

          // ── سعر الكرت الصافي ──
          Text(
            'سعر الكرت:',
            style: AppTypography.badgeText.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AmountFormatter.formatValue(unitPrice),
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  height: 1.1,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'ر.ي',
                style: AppTypography.badgeText.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 5.h),
          Divider(
            height: 1.h,
            color: themeColor.withValues(alpha: 0.15),
            thickness: 0.8.w,
          ),
          SizedBox(height: 5.h),

          // ── إجمالي الحزمة ومبلغ التوفير ──
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'إجمالي: ',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                TextSpan(
                  text:
                      '${AmountFormatter.formatValue(effectiveTotalPrice)} ر.ي',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (savingsAmount > 0) ...[
            SizedBox(height: 2.h),
            Text(
              'وفر ${AmountFormatter.formatValue(savingsAmount)} ر.ي',
              style: AppTypography.badgeText.copyWith(
                color: themeColor,
                fontWeight: FontWeight.w700,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
