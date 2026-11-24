import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
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

/// بطاقة باقة كروت الإنترنت — تصميم الكبسولات المخملية الفاخرة (Velvet Pods Concept)
///
/// تم بناء الهيكل المعماري وفق أعلى معايير واجهات FinTech الفاخرة:
/// 1. الهيدر الاستعراضي:
///    - علامة مائية رقيقة وخافتة لفئة الكرت في الخلفية (`Watermark Face Value`).
///    - ختم الفئة الرسمي وشارة الحالة في صف تفاعلي منظم مع القائمة الموحدة [CustomPopupMenu].
///    - سعة البيانات الضخمة واسم الباقة ووسوم المواصفات المقتضبة.
/// 2. القاعدة التجارية الفاخرة (Velvet Pods):
///    - كبسولتان مخمليتان مستقلتان للشراء النقدي والآجل.
///    - شريط لوني علوي مميز (زمردي للنقدي وملكي للآجل) بسماكة `3.w`.
///    - خطوط عريضة ومريحة لسعر الكرت، نسبة الخصم، مبلغ الوفر، وإجمالي الحزمة.
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

    final balanceParts = _ShowcaseHeroQuota(balanceValue: package.packageBalance, balanceUnit: '', packageName: '',);

    final cardContent = Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: AppElevation.level2(context),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
          width: 1.w,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. اللوحة الاستعراضية العلوية ──
          _VelvetHeaderShowcase(
            package: package,
            accentColor: accentColor,
            statusLabel: statusPres.label,
            statusTone: statusPres.tone,
            balance: balanceParts,
            hasAdminActions: hasAdminActions,
            canEdit: canEdit,
            canDelete: canDelete,
            onEdit: onEdit,
            onToggleStatus: onToggleStatus,
            onDelete: onDelete,
          ),

          // ── 2. مقصورة الكبسولتين المخمليتين للتسعير (النموذج 2) ──
          _VelvetCommercialSection(
            package: package,
            accentColor: accentColor,
            onDetails: onDetails,
          ),
        ],
      ),
    );

    return CustomInteractiveBounce(
      onTap: onDetails,
      child: package.isActive
          ? cardContent
          : Opacity(opacity: 0.72, child: cardContent),
    );
  }
}

/// سعة البيانات الكبرى واسم الباقة بنفس أسلوب وهوية الكتالوج
class _ShowcaseHeroQuota extends StatelessWidget {
  const _ShowcaseHeroQuota({
    required this.balanceValue,
    required this.balanceUnit,
    required this.packageName,
  });

  final String balanceValue;
  final String balanceUnit;
  final String packageName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              balanceValue,
              style: AppTypography.displayMedium.copyWith(
                fontSize: 38.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: AppRadius.sm,
                    offset: Offset(0, AppSpacing.xxs),
                  ),
                ],
              ),
            ),
            if (balanceUnit.isNotEmpty) ...[
              AppSpacing.hXs,
              Text(
                balanceUnit,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.executiveGoldAccent,
                  height: 1.0,
                ),
              ),
            ],
          ],
        ),
        AppSpacing.vXs,
        Text(
          packageName,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// رأس البطاقة الاستعراضي مع العلامة المائية الفاخرة
class _VelvetHeaderShowcase extends StatelessWidget {
  const _VelvetHeaderShowcase({
    required this.package,
    required this.accentColor,
    required this.statusLabel,
    required this.statusTone,
    required this.balance,
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
  final _ShowcaseHeroQuota balance;
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
      children: [
        // الخلفية اللونية الشفافة للباقة
        Positioned.fill(
          child: Container(color: accentColor.withValues(alpha: 0.06)),
        ),

        // ── الدائرة العائمة الزخرفية الناعمة في رأس الكرت ──
        Positioned(
          bottom: -45.r,
          left: -35.r,
          child: IgnorePointer(
            child: Container(
              width: 150.r,
              height: 150.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),

        // العلامة المائية الرقيقة في رأس الكرت
        Positioned(
          top: 50.h,
          bottom: 50.h,
          left: 12.w,
          child: IgnorePointer(
            child: Text(
              AmountFormatter.formatValue(package.packageVoucherPrice, decimalPlaces: 0),
              style: TextStyle(
                fontSize: 64.sp,
                fontWeight: FontWeight.w900,
                color: accentColor.withValues(alpha: 0.08),
                letterSpacing: -2,
                height: 0.9,
              ),
            ),
          ),
        ),

        // المحتوى الرئيسي
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── الصف الأول: شارة الحالة + ختم فئة الكرت + القائمة الموحدة ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomStatusBadge(
                    label: statusLabel,
                    tone: statusTone,
                    isCompact: true,
                    showDot: true,
                  ),
                  const Spacer(),

                  // ختم فئة الكرت الرسمي
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'فئة ',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${AmountFormatter.formatValue(package.packageVoucherPrice)} ر.ي',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (hasAdminActions) ...[
                    SizedBox(width: 8.w),
                    CustomPopupMenu<String>(
                      // triggerDimension: 28.r,
                      // triggerIconSize: 16.r,
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
                ],
              ),

              SizedBox(height: 10.h),

              // ── الصف الثاني: سعة البيانات البارزة ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    balance.balanceValue,
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: package.isActive
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                      height: 1.0,
                    ),
                  ),
                  if (balance.balanceUnit.isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    Text(
                      balance.balanceUnit,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: package.isActive
                            ? accentColor
                            : colors.onSurfaceVariant,
                        height: 1.0,
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 6.h),

              // ── الصف الثالث: اسم الباقة ──
              Text(
                package.packageName,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8.h),

              // ── الصف الرابع: وسوم المواصفات المقتضبة ──
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: [
                  _VelvetSpecPill(
                    icon: Icons.layers_outlined,
                    label: '${package.packageVoucherCount} كرت',
                  ),
                  _VelvetSpecPill(
                    icon: Icons.timer_outlined,
                    label: package.uptimeDisplay,
                  ),
                  _VelvetSpecPill(
                    icon: Icons.calendar_today_outlined,
                    label: package.validityDisplay,
                  ),
                  // if (package.networkName != null &&
                  //     package.networkName!.isNotEmpty)
                  //   _VelvetSpecPill(
                  //     icon: Icons.hub_outlined,
                  //     label: package.networkName!,
                  //   ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// وسم مقتضب للمواصفات
class _VelvetSpecPill extends StatelessWidget {
  const _VelvetSpecPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
          width: 0.8.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11.r,
            color: colors.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTypography.badgeText.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// قسم الكبسولتين المخمليتين (Velvet Commercial Section — النموذج 2)
class _VelvetCommercialSection extends StatelessWidget {
  const _VelvetCommercialSection({
    required this.package,
    required this.accentColor,
    required this.onDetails,
  });

  final PackageEntity package;
  final Color accentColor;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cashDiscount = package.packageDefaultCashDiscount;
    final creditDiscount = package.packageDefaultCreditDiscount;

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.5),
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
          // ═══ الكبسولتان المخمليتان جنباً إلى جنب بتوزيع رأسي داخلي نقي ═══
          Row(
            children: [
              // كبسولة الشراء النقدي
              Expanded(
                child: _VelvetDealPod(
                  title: '🟢 نقدي',
                  themeColor: colors.success,
                  discountPercent: cashDiscount,
                  voucherPrice: package.effectiveCashPrice,
                  voucherSavings: package.cashDiscountAmount,
                  totalPrice: package.totalCashPrice,
                ),
              ),

              SizedBox(width: 10.w),

              // كبسولة الشراء الآجل
              Expanded(
                child: _VelvetDealPod(
                  title: '🔵 آجل',
                  themeColor: colors.info,
                  discountPercent: creditDiscount,
                  voucherPrice: package.effectiveCreditPrice,
                  voucherSavings: package.creditDiscountAmount,
                  totalPrice: package.totalCreditPrice,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ═══ زر استعراض التفاصيل ═══
          // CustomButton.primary(
          //   onPressed: onDetails,
          //   text: 'عرض تفاصيل الباقة',
          //   size: AppButtonSize.small,
          //   icon: Icons.chevron_right_rounded,
          //   width: double.infinity,
          // ),

          // CustomInteractiveBounce(
          //   onTap: onDetails,
          //   child: Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.symmetric(vertical: 8.h),
          //     decoration: BoxDecoration(
          //       color: colors.surface,
          //       borderRadius: BorderRadius.circular(AppRadius.sm),
          //       border: Border.all(
          //         color: colors.outline.withValues(alpha: 0.12),
          //         width: 0.8.w,
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(
          //           'عرض تفاصيل الباقة',
          //           style: AppTypography.labelMedium.copyWith(
          //             fontWeight: FontWeight.w700,
          //             color: colors.onSurface,
          //           ),
          //         ),
          //         SizedBox(width: 6.w),
          //         Icon(
          //           Icons.arrow_back_ios_new_rounded,
          //           size: 11.r,
          //           color: colors.onSurfaceVariant,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

/// الكبسولة المخملية المستقلة (Velvet Deal Pod)
class _VelvetDealPod extends StatelessWidget {
  const _VelvetDealPod({
    required this.title,
    required this.themeColor,
    required this.discountPercent,
    required this.voucherPrice,
    required this.voucherSavings,
    required this.totalPrice,
  });

  final String title;
  final Color themeColor;
  final double discountPercent;
  final double voucherPrice;
  final double voucherSavings;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── الشريط اللوني العلوي المميز للكبسولة ──
          Container(height: 3.h, width: double.infinity, color: themeColor),

          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 9.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── السطر 1: عنوان المسار + شارة الخصم ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                    if (discountPercent > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'خصم ${discountPercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 4.h),

                // ── السطر 2: سعر الكرت الصافي ──
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        AmountFormatter.formatValue(voucherPrice),
                        style: TextStyle(
                          fontSize: 17.5.sp,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'ر.ي',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // ── السطر 3: مقدار الوفر بالكرت ──
                Text(
                  voucherSavings > 0
                      ? 'وفر ${AmountFormatter.formatValue(voucherSavings)} بالكرت'
                      : 'السعر الصافي',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: voucherSavings > 0
                        ? themeColor
                        : colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 3.h),

                // ── السطر 4: إجمالي الحزمة ──
                Text(
                  'حزمة: ${AmountFormatter.formatValue(totalPrice)} ر.ي',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
