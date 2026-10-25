import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';

/// ============================================================================
/// بطاقة أطراف العملية المالية (InvoicePartiesCard)
/// ============================================================================
/// تعرض طرفي المعاملة المالية: الشبكة المصدّرة للرصيد ونقطة البيع المستلمة.
class InvoicePartiesCard extends StatelessWidget {
  final SaleInvoiceEntity invoice;

  const InvoicePartiesCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                color: colors.primary,
                size: 18.r,
              ),
              AppSpacing.hXs,
              Text(
                'أطراف المعاملة المالية',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Row(
            children: [
              // طرف الشبكة المصدّرة
              Expanded(
                child: _PartyTile(
                  icon: Icons.wifi_tethering_rounded,
                  iconBg: colors.primary.withValues(alpha: 0.12),
                  iconColor: colors.primary,
                  roleLabel: 'شبكة الإنترنت المصدّرة',
                  partyName: invoice.networkName ?? 'الشبكة #${invoice.networkId}',
                  badgeText: 'المزوّد',
                ),
              ),
              AppSpacing.hSm,
              // نقطة البيع المستلمة
              Expanded(
                child: _PartyTile(
                  icon: Icons.storefront_rounded,
                  iconBg: colors.secondary.withValues(alpha: 0.12),
                  iconColor: colors.secondary,
                  roleLabel: 'نقطة البيع المستلمة',
                  partyName: invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                  badgeText: invoice.posCode != null ? '#${invoice.posCode}' : 'الوكيل',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartyTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String roleLabel;
  final String partyName;
  final String badgeText;

  const _PartyTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.roleLabel,
    required this.partyName,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(icon, color: iconColor, size: 16.r),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.xsRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Text(
            roleLabel,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10.sp,
            ),
          ),
          AppSpacing.vXxs,
          Text(
            partyName,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
