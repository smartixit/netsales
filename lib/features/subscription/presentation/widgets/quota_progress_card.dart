import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/subscription/domain/entities/feature_quota_item_entity.dart';

/// بطاقة عرض الحصة والاستهلاك الفعلي مع مؤشر التقدم اللوني (QuotaProgressCard)
class QuotaProgressCard extends StatelessWidget {
  final FeatureQuotaItemEntity quota;

  const QuotaProgressCard({super.key, required this.quota});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // تحديد اللون بناءً على حالة الاستهلاك
    final Color progressColor;
    final String statusText;
    final Color statusTextColor;

    if (quota.isUnlimited) {
      progressColor = colors.primary;
      statusText = 'غير محدود';
      statusTextColor = colors.primary;
    } else if (quota.isExhausted) {
      progressColor = colors.error;
      statusText = 'نفدت الحصة';
      statusTextColor = colors.error;
    } else if (quota.isNearExhaustion) {
      progressColor = colors.warning;
      statusText = 'على وشك النفاد';
      statusTextColor = colors.warning;
    } else {
      progressColor = colors.success;
      statusText = 'متاح';
      statusTextColor = colors.success;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: quota.isExhausted
              ? colors.error.withValues(alpha: 0.3)
              : quota.isNearExhaustion
              ? colors.warning.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quota.featureName,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (quota.featureDesc != null &&
                        quota.featureDesc!.isNotEmpty) ...[
                      AppSpacing.vXxs,
                      Text(
                        quota.featureDesc!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusTextColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  statusText,
                  style: AppTypography.badgeText.copyWith(
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vMd,

          // شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: quota.isUnlimited ? 1.0 : quota.percentage,
              minHeight: 8.h,
              backgroundColor: colors.outlineVariant.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          AppSpacing.vSm,

          // أرقام الاستهلاك والمتبقي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                quota.isUnlimited
                    ? 'الاستهلاك: ${AmountFormatter.formatValue(quota.consumedValue)}'
                    : 'الاستهلاك: ${AmountFormatter.formatValue(quota.consumedValue)} / ${AmountFormatter.formatValue(quota.quotaLimit)}',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                quota.isUnlimited
                    ? 'المتبقي: ∞'
                    : 'المتبقي: ${AmountFormatter.formatValue(quota.remainingValue)}',
                style: AppTypography.bodySmall.copyWith(
                  color: quota.isExhausted ? colors.error : colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
