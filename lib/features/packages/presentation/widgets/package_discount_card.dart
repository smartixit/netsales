import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/packages/domain/entities/voucher_package_discount_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة خصم باقة الكروت المخصص لنقطة بيع (PackageDiscountCard)
/// ============================================================================
/// تعرض نقطة البيع المستفيدة، الباقة المستهدفة، نسب الخصم الاستثنائية،
/// واحتساب فوري لصافي التكلفة وربح الوكيل منسقة عبر AmountFormatter.
class PackageDiscountCard extends StatelessWidget {
  final VoucherPackageDiscountEntity discount;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PackageDiscountCard({
    super.key,
    required this.discount,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final canEdit = PermissionService.to.can(AppPermissions.voucherPackagesEdit);
    final canDelete = PermissionService.to.can(AppPermissions.voucherPackagesDelete);
    final netCash = discount.effectiveCashPrice;
    final netCredit = discount.effectiveCreditPrice;
    final cashSavings = discount.cashSavings;
    final creditSavings = discount.creditSavings;

    return CustomInteractiveBounce(
      onTap: onEdit,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: discount.isActive
                ? colors.outlineVariant
                : colors.error.withValues(alpha: 0.2),
            width: 1.w,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ترويسة البطاقة: نقطة البيع، الباقة، وتبديل الحالة ──
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.storefront_outlined,
                      color: colors.secondary,
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
                        discount.posName ?? 'نقطة بيع #${discount.posId}',
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vXxs,
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 12.r,
                            color: colors.primary,
                          ),
                          AppSpacing.hXxs,
                          Expanded(
                            child: Text(
                              discount.packageName ??
                                  'باقة كروت #${discount.packageId}',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canEdit) AppSpacing.hSm,
                if (canEdit)
                  // زر تبديل الحالة
                  CustomInteractiveBounce(
                  onTap: onToggleStatus,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: discount.isActive
                          ? colors.successContainer.withValues(alpha: 0.4)
                          : colors.errorContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: discount.isActive
                            ? colors.success.withValues(alpha: 0.3)
                            : colors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          discount.isActive
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_rounded,
                          size: 14.r,
                          color: discount.isActive
                              ? colors.success
                              : colors.error,
                        ),
                        AppSpacing.hXxs,
                        Text(
                          discount.isActive ? 'مطبق' : 'معطل',
                          style: AppTypography.labelSmall.copyWith(
                            color: discount.isActive
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

            // ── مصفوفة الاحتساب اللحظي للخصم والتكلفة ──
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surfaceContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  // الخصم النقدي المخصص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خصم الكاش',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          '${AmountFormatter.formatValue(discount.discountCash, decimalPlaces: 0)}%',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (netCash != null && cashSavings != null) ...[
                          AppSpacing.vXxs,
                          Text(
                            'يدفع: ${AmountFormatter.formatValue(netCash, decimalPlaces: 0)} ر.ي (ربح ${AmountFormatter.formatValue(cashSavings, decimalPlaces: 0)} ر.ي)',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 1.w,
                    height: 40.h,
                    color: colors.outlineVariant,
                  ),
                  AppSpacing.hSm,
                  // الخصم الآجل المخصص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خصم الآجل',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          '${AmountFormatter.formatValue(discount.discountCredit, decimalPlaces: 0)}%',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (netCredit != null && creditSavings != null) ...[
                          AppSpacing.vXxs,
                          Text(
                            'يدفع: ${AmountFormatter.formatValue(netCredit, decimalPlaces: 0)} ر.ي (ربح ${AmountFormatter.formatValue(creditSavings, decimalPlaces: 0)} ر.ي)',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vMd,

            // ── شريط الإجراءات ──
            Row(
              children: [
                if (canEdit)
                  Expanded(
                    child: CustomButton.outline(
                      text: 'تعديل نسب الخصم',
                      icon: Icons.edit_outlined,
                      size: AppButtonSize.small,
                      onPressed: onEdit,
                    ),
                  ),
                if (canEdit) AppSpacing.hSm,
                if (canDelete)
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
    );
  }
}
