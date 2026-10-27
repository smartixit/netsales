import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// منصة العمليات والإجراءات السريعة (DashboardQuickShortcutsBar)
/// ============================================================================
/// رصيف إجراءات تنفيذي مدمج يتيح للمشغل إصدار الفواتير وطلب الكروت
/// وإدارة الوكلاء والمحافظ بأسرع مسار نقر وبدون تعقيد.
class DashboardQuickShortcutsBar extends StatelessWidget {
  final bool isSuperAdmin;
  final VoidCallback? onNewInvoiceTap;
  final VoidCallback? onNewRequestTap;
  final VoidCallback? onManageNetworksTap;
  final VoidCallback? onManagePosTap;
  final VoidCallback? onAuditOperationsTap;
  final VoidCallback? onWalletTap;

  const DashboardQuickShortcutsBar({
    super.key,
    this.isSuperAdmin = false,
    this.onNewInvoiceTap,
    this.onNewRequestTap,
    this.onManageNetworksTap,
    this.onManagePosTap,
    this.onAuditOperationsTap,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ترويسة الرصيف التنفيذي (محمية ومتجاوبة)
        Row(
          children: [
            Expanded(
              child: Text(
                isSuperAdmin
                    ? 'الإجراءات والرقابة السيادية'
                    : 'العمليات والإجراءات الميدانية',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppSpacing.hSm,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: AppRadius.fullRadius,
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    'مسار سريع',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        AppSpacing.vMd,

        // شبكة البطاقات التنفيذية الذكية (2 في كل صف بتصميم عمودي تنفيذي مانع للاقتصاص)
        if (isSuperAdmin) ...[
          Row(
            children: [
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.cell_tower_rounded,
                  title: 'إدارة الشبكات',
                  subtitle: 'مراجعة واعتماد المزودين',
                  color: colors.primary,
                  onTap: onManageNetworksTap,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.point_of_sale_rounded,
                  title: 'نقاط التوزيع',
                  subtitle: 'مراجعة واعتماد الوكلاء',
                  color: colors.secondary,
                  onTap: onManagePosTap,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'العمليات والفوترة',
                  subtitle: 'سجل تداول المنظومة',
                  color: colors.tertiary,
                  onTap: onAuditOperationsTap,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'المركز المالي',
                  subtitle: 'إشراف ورقابة المحافظ',
                  color: colors.warning,
                  onTap: onWalletTap,
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'فاتورة مبيعات',
                  subtitle: 'إصدار كاش / آجل',
                  color: colors.primary,
                  onTap: onNewInvoiceTap,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.inventory_2_rounded,
                  title: 'توريد كروت',
                  subtitle: 'طلب رصيد شبكي',
                  color: colors.secondary,
                  onTap: onNewRequestTap,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.storefront_rounded,
                  title: 'نقاط التوزيع',
                  subtitle: 'متابعة الوكلاء',
                  color: colors.tertiary,
                  onTap: onManagePosTap,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: _ExecutiveActionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'إدارة المحفظة',
                  subtitle: 'الرصيد والتحويل',
                  color: colors.warning,
                  onTap: onWalletTap,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// بطاقة إجراء تنفيذي رشيقة بهندسة عمودية تمنع اقتصاص النصوص
class _ExecutiveActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ExecutiveActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap ?? () {},
      child: Container(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.25),
            width: 1.w,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                      color: color.withValues(alpha: 0.22),
                      width: 1.w,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 19.r),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.35),
                ),
              ],
            ),
            AppSpacing.vSm,
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vXxs,
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
