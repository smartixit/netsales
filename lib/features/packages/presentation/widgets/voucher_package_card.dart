import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// مُمَدِّد استخراج اللون المخصص للباقة من قاعدة البيانات عبر CustomColorPicker
extension VoucherPackageColorExtension on VoucherPackageEntity {
  Color? get parsedColor => packageColor != null && packageColor!.trim().isNotEmpty
      ? CustomColorPicker.parseHex(packageColor)
      : null;
}

/// ============================================================================
/// بطاقة باقة كروت الإنترنت المؤسسية (VoucherPackageCard)
/// ============================================================================
/// تعرض تفاصيل الباقة، السعر، الحصص، الصلاحية، نسب الخصم النقدية والآجلة،
/// وتعتمد الهوية البصرية للون الباقة المحفوظ في قاعدة البيانات وتنسيق المبالغ عبر AmountFormatter.
class VoucherPackageCard extends StatelessWidget {
  final VoucherPackageEntity package;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddDiscount;

  const VoucherPackageCard({
    super.key,
    required this.package,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onAddDiscount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brandColor = package.parsedColor ?? colors.primary;

    return CustomInteractiveBounce(
      onTap: onEdit,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: package.isActive
                ? colors.outlineVariant
                : colors.error.withValues(alpha: 0.2),
            width: 1.w,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط لوني نحيف يعكس لون الباقة من قاعدة البيانات
              Container(
                height: 4.h,
                width: double.infinity,
                color: package.isActive
                    ? brandColor
                    : colors.outlineVariant,
              ),

              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ترويسة البطاقة: الأيقونة الملونة، الاسم، ومفتاح الحالة
                    Row(
                      children: [
                        Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: brandColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: brandColor.withValues(alpha: 0.35),
                              width: 1.w,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.confirmation_number_outlined,
                              color: brandColor,
                              size: 22.r,
                            ),
                          ),
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package.packageName,
                                style: AppTypography.titleMedium.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (package.networkName != null) ...[
                                AppSpacing.vXxs,
                                Text(
                                  package.networkName!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.outline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        AppSpacing.hSm,
                        // زر تبديل الحالة المباشر
                        CustomInteractiveBounce(
                          onTap: onToggleStatus,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: package.isActive
                                  ? colors.successContainer.withValues(alpha: 0.4)
                                  : colors.errorContainer.withValues(alpha: 0.4),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: package.isActive
                                    ? colors.success.withValues(alpha: 0.3)
                                    : colors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  package.isActive
                                      ? Icons.check_circle_rounded
                                      : Icons.pause_circle_rounded,
                                  size: 14.r,
                                  color: package.isActive
                                      ? colors.success
                                      : colors.error,
                                ),
                                AppSpacing.hXxs,
                                Text(
                                  package.isActive ? 'مفعلة' : 'معطلة',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: package.isActive
                                        ? colors.success
                                        : colors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vMd,

                    // شريط المواصفات التقنية
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        if (package.packageBalance != null &&
                            package.packageBalance! > 0)
                          _VoucherSpecChip(
                            icon: Icons.data_usage_rounded,
                            label:
                                '${AmountFormatter.formatValue(package.packageBalance!, decimalPlaces: 0)} MB',
                          ),
                        if (package.packageValidity != null &&
                            package.packageValidity!.isNotEmpty)
                          _VoucherSpecChip(
                            icon: Icons.schedule_rounded,
                            label: '${package.packageValidity} يوم',
                          ),
                        if (package.packageUptime != null &&
                            package.packageUptime!.isNotEmpty)
                          _VoucherSpecChip(
                            icon: Icons.timer_outlined,
                            label: '${package.packageUptime} ساعة',
                          ),
                        _VoucherSpecChip(
                          icon: Icons.layers_outlined,
                          label: '${package.packageVoucherCount} كرت/حزمة',
                        ),
                      ],
                    ),

                    AppSpacing.vMd,

                    // السعر وهوامش الخصم منسقة عبر AmountFormatter
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'سعر الجمهور',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                AppSpacing.vXxs,
                                Text(
                                  '${AmountFormatter.formatValue(package.packageVoucherPrice, decimalPlaces: 0)} ر.ي',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: brandColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.w,
                            height: 32.h,
                            color: colors.outlineVariant,
                          ),
                          AppSpacing.hSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'خصم نقداً (${AmountFormatter.formatValue(package.packageDefaultCashDiscount, decimalPlaces: 0)}%)',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                AppSpacing.vXxs,
                                Text(
                                  '${AmountFormatter.formatValue(package.defaultEffectiveCashPrice, decimalPlaces: 0)} ر.ي',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1.w,
                            height: 32.h,
                            color: colors.outlineVariant,
                          ),
                          AppSpacing.hSm,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'خصم آجلاً (${AmountFormatter.formatValue(package.packageDefaultCreditDiscount, decimalPlaces: 0)}%)',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                AppSpacing.vXxs,
                                Text(
                                  '${AmountFormatter.formatValue(package.defaultEffectiveCreditPrice, decimalPlaces: 0)} ر.ي',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.vMd,

                    // شريط الإجراءات والعمليات السريعة
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton.outline(
                            text: 'تخصيص خصم لوكيل',
                            icon: Icons.add_circle_outline_rounded,
                            size: AppButtonSize.small,
                            onPressed: onAddDiscount,
                          ),
                        ),
                        AppSpacing.hSm,
                        CustomButton.icon(
                          icon: Icons.edit_outlined,
                          size: AppButtonSize.small,
                          onPressed: onEdit,
                        ),
                        AppSpacing.hXs,
                        CustomButton.icon(
                          icon: Icons.delete_outline_rounded,
                          foregroundColor: colors.error,
                          size: AppButtonSize.small,
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ودجت مستقل لمواصفات الباقة وفق قاعدة منع دوال البناء المساعدة نهائياً
class _VoucherSpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _VoucherSpecChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: colors.onSurfaceVariant),
          AppSpacing.hXxs,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
