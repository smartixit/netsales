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
import 'package:netsales/core/utils/date_formatter.dart';
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
                  // زر تبديل الحالة ومؤشر السريان
                  CustomInteractiveBounce(
                    onTap: onToggleStatus,
                    child: _buildStatusBadge(context),
                  ),
              ],
            ),

            if (discount.discountStartDate != null || discount.discountEndDate != null) ...[
              AppSpacing.vXs,
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 13.r,
                    color: colors.onSurfaceVariant,
                  ),
                  AppSpacing.hXxs,
                  Expanded(
                    child: Text(
                      _formatValidityDates(discount),
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

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

  Widget _buildStatusBadge(BuildContext context) {
    final colors = context.colors;
    final String label;
    final Color badgeColor;
    final Color containerColor;
    final IconData icon;

    final validityState = discount.validityState?.toUpperCase();
    if (validityState != null) {
      switch (validityState) {
        case 'EFFECTIVE':
          label = 'سارٍ حالياً';
          badgeColor = colors.success;
          containerColor = colors.successContainer.withValues(alpha: 0.4);
          icon = Icons.check_circle_rounded;
          break;
        case 'SCHEDULED':
          label = 'مجدول';
          badgeColor = colors.primary;
          containerColor = colors.primaryContainer.withValues(alpha: 0.4);
          icon = Icons.schedule_rounded;
          break;
        case 'EXPIRED':
          label = 'منتهي';
          badgeColor = colors.error;
          containerColor = colors.errorContainer.withValues(alpha: 0.4);
          icon = Icons.timer_off_outlined;
          break;
        case 'DISABLED':
          label = 'معطل';
          badgeColor = colors.error;
          containerColor = colors.errorContainer.withValues(alpha: 0.4);
          icon = Icons.pause_circle_rounded;
          break;
        case 'DELETED':
          label = 'محذوف';
          badgeColor = colors.error;
          containerColor = colors.errorContainer.withValues(alpha: 0.4);
          icon = Icons.delete_outline_rounded;
          break;
        default:
          label = 'سارٍ حالياً';
          badgeColor = colors.success;
          containerColor = colors.successContainer.withValues(alpha: 0.4);
          icon = Icons.check_circle_rounded;
      }
    } else if (!discount.isActive) {
      label = 'معطل';
      badgeColor = colors.error;
      containerColor = colors.errorContainer.withValues(alpha: 0.4);
      icon = Icons.pause_circle_rounded;
    } else if (discount.isEffectiveNow == true) {
      label = 'سارٍ حالياً';
      badgeColor = colors.success;
      containerColor = colors.successContainer.withValues(alpha: 0.4);
      icon = Icons.check_circle_rounded;
    } else {
      // حالة محايدة عند عدم توفر حالة السريان من الخادم (بدون احتساب محلي من ساعة الجهاز)
      label = 'غير محدد';
      badgeColor = colors.onSurfaceVariant;
      containerColor = colors.surfaceContainer.withValues(alpha: 0.4);
      icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.r,
            color: badgeColor,
          ),
          AppSpacing.hXxs,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValidityDates(VoucherPackageDiscountEntity d) {
    final start = d.discountStartDate != null
        ? DateTime.tryParse(d.discountStartDate!)
        : null;
    final endStr = d.displayEndDate ?? d.discountEndDate;
    final end = endStr != null ? DateTime.tryParse(endStr) : null;

    if (start != null && end != null) {
      return 'الصلاحية: من ${DateFormatter.date(start)} إلى ${DateFormatter.date(end)}';
    } else if (start != null) {
      return 'سارٍ اعتباراً من: ${DateFormatter.date(start)}';
    } else if (end != null) {
      return 'سارٍ حتى: ${DateFormatter.date(end)}';
    }
    return 'صلاحية مفتوحة';
  }
}
