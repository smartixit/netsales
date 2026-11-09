import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';

/// بطاقة تفاصيل الاشتراك النشط ورأسه (SubscriptionHeaderCard)
class SubscriptionHeaderCard extends StatelessWidget {
  final ProviderSubscriptionEntity subscription;
  final VoidCallback? onActivateEarly;
  final bool isActionLoading;

  const SubscriptionHeaderCard({
    super.key,
    required this.subscription,
    this.onActivateEarly,
    this.isActionLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = subscription.isActive;
    final statusColor = isActive ? colors.success : colors.warning;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isActive
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  color: colors.primary,
                  size: 28.sp,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            subscription.planName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            subscription.statusLabel,
                            style: AppTypography.badgeText.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vXxs,
                    Text(
                      subscription.planDesc ??
                          'باقة الاشتراك السحابية المعتمدة للشبكة',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vLg,
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            height: 1,
          ),
          AppSpacing.vMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoColumn(
                title: 'قيمة الباقة',
                value:
                    '${AmountFormatter.formatValue(subscription.planPrice)} YER',
                icon: Icons.payments_outlined,
              ),
              _InfoColumn(
                title: 'صلاحية الباقة',
                value: '${subscription.planValidity} يوماً',
                icon: Icons.calendar_month_outlined,
              ),
              _InfoColumn(
                title: 'المتبقي',
                value: '${subscription.remainingDays} يوماً',
                icon: Icons.hourglass_bottom_rounded,
                isHighlight: subscription.remainingDays <= 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _InfoColumn({
    required this.title,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: colors.onSurfaceVariant),
            AppSpacing.hXxs,
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
        AppSpacing.vXxs,
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? colors.error : colors.onSurface,
          ),
        ),
      ],
    );
  }
}
