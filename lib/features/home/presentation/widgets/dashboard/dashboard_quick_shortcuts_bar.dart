import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط الاختصارات السريعة (DashboardQuickShortcutsBar)
/// ============================================================================
/// يتيح للمستخدم الوصول المباشر للعمليات التشغيلية بنقرة واحدة
/// دون إجباره على التنقل بين القوائم المعقدة.
class DashboardQuickShortcutsBar extends StatelessWidget {
  final VoidCallback? onNewInvoiceTap;
  final VoidCallback? onNewRequestTap;
  final VoidCallback? onManagePosTap;
  final VoidCallback? onWalletTap;

  const DashboardQuickShortcutsBar({
    super.key,
    this.onNewInvoiceTap,
    this.onNewRequestTap,
    this.onManagePosTap,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vMd,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ShortcutItem(
              icon: Icons.post_add_rounded,
              label: 'فاتورة جديدة',
              color: colors.primary,
              onTap: onNewInvoiceTap,
            ),
            _ShortcutItem(
              icon: Icons.add_shopping_cart_rounded,
              label: 'طلب كروت',
              color: colors.secondary,
              onTap: onNewRequestTap,
            ),
            _ShortcutItem(
              icon: Icons.storefront_rounded,
              label: 'نقاط البيع',
              color: colors.tertiary,
              onTap: onManagePosTap,
            ),
            _ShortcutItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'شحن المحفظة',
              color: colors.warning,
              onTap: onWalletTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: CustomInteractiveBounce(
        onTap: onTap ?? () {},
        child: Column(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.xlRadius,
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.r,
              ),
            ),
            AppSpacing.vXs,
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

