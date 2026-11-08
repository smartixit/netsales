import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// مركز دخول عمليات المالية في مساحة عمل مزود الشبكة.
/// لا يجري أي حساب أو تحميل مالي؛ يوجّه إلى الشاشات التي تجلب بياناتها من API.
class NetworkFinanceWorkspaceHub extends StatelessWidget {
  const NetworkFinanceWorkspaceHub({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: colors.onPrimary,
                    size: 28,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مركز العمليات المالية',
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        'إدارة محافظ الشبكة، تحصيل مديونيات نقاط البيع، ومراجعة سندات السداد.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vXl,
          Text(
            'الإجراءات المالية',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
            ),
          ),
          AppSpacing.vXs,
          Text(
            'اختر الإجراء المطلوب. الأرصدة والتسويات النهائية مصدرها الخادم.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vLg,
          SizedBox(
            width: double.infinity,
            child: CustomButton.primary(
              text: 'تحصيل سداد مديونية نقطة بيع',
              prefix: Icons.payments_rounded,
              size: AppButtonSize.large,
              width: double.infinity,
              onPressed: () => Get.toNamed<void>(AppRoutes.repaymentCollection),
            ),
          ),
          AppSpacing.vMd,
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final actionWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacing.md) / 2;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: actionWidth,
                    child: _FinanceHubAction(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'محفظة الشبكة',
                      subtitle: 'الرصيد والحركات ودفتر الأستاذ',
                      onTap: () => Get.toNamed<void>(
                        AppRoutes.networkWalletStatement,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: actionWidth,
                    child: _FinanceHubAction(
                      icon: Icons.receipt_long_outlined,
                      title: 'سجل سندات السداد',
                      subtitle: 'تصفية السندات ومراجعة حالاتها',
                      onTap: () => Get.toNamed<void>(
                        AppRoutes.repaymentHistory,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FinanceHubAction extends StatelessWidget {
  const _FinanceHubAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomButton.outline(
      onPressed: onTap,
      width: double.infinity,
      height: 88,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      foregroundColor: colors.onSurface,
      borderColor: colors.outlineVariant,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.onPrimaryContainer, size: 21),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hXs,
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
