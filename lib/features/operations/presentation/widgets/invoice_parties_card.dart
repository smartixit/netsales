import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';

/// ============================================================================
/// بطاقة أطراف العملية المالية السيادية (InvoicePartiesCard)
/// ============================================================================
/// تعرض طرفي المعاملة المالية بنمط سجل التبادل والتحويل المؤسسي:
/// شبكة الإنترنت المزوّدة ونقطة البيع المستلمة مع رموز التعريف وأدوار الصلاحية.
class InvoicePartiesCard extends StatelessWidget {
  final SaleInvoiceEntity invoice;

  const InvoicePartiesCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCash = invoice.isCash;
    final themeColor = isCash ? colors.primary : colors.warning;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 1.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ترويسة مسار المعاملة ──
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: themeColor,
                  size: 16.r,
                ),
              ),
              AppSpacing.hXs,
              Text(
                'مسار أطراف المعاملة المالية',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
          AppSpacing.vMd,

          // ── بطاقتا الطرفين المتجاورتان ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. طرف الشبكة المزودة
              Expanded(
                child: _PartyLedgerPod(
                  icon: Icons.wifi_tethering_rounded,
                  accentColor: colors.primary,
                  roleLabel: 'شبكة الإنترنت المصدّرة',
                  partyName: invoice.networkName ?? 'الشبكة #${invoice.networkId}',
                  idBadge: 'المزوّد',
                ),
              ),

              AppSpacing.hSm,

              // 2. نقطة البيع المستلمة
              Expanded(
                child: _PartyLedgerPod(
                  icon: Icons.storefront_rounded,
                  accentColor: themeColor,
                  roleLabel: 'نقطة البيع المستلمة',
                  partyName: invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                  idBadge: invoice.posCode != null ? '#${invoice.posCode}' : 'الوكيل',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartyLedgerPod extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String roleLabel;
  final String partyName;
  final String idBadge;

  const _PartyLedgerPod({
    required this.icon,
    required this.accentColor,
    required this.roleLabel,
    required this.partyName,
    required this.idBadge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.2),
          width: 0.8.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.18),
                      accentColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 16.r,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.22),
                    width: 0.7.w,
                  ),
                ),
                child: Text(
                  idBadge,
                  style: AppTypography.labelSmall.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Text(
            roleLabel,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
              fontSize: 9.5.sp,
            ),
          ),
          AppSpacing.vXxs,
          Text(
            partyName,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 12.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
