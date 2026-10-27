import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط العمليات والحركات الأخيرة (DashboardRecentOperationsFeed)
/// ============================================================================
/// يعرض شريطاً زمنياً بأحدث فواتير البيع وطلبات الكروت مع تفاصيل المبلغ والحالة.
class DashboardRecentOperationsFeed extends StatelessWidget {
  final List<DashboardActivityEntity> activities;
  final ValueChanged<DashboardActivityEntity>? onActivityTap;
  final bool isMasked;

  const DashboardRecentOperationsFeed({
    super.key,
    required this.activities,
    this.onActivityTap,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'العمليات الأخيرة',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (activities.isNotEmpty)
              Text(
                'آخر ${activities.length} حركة',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        AppSpacing.vMd,

        if (activities.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.xxl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                AppSpacing.vSm,
                Text(
                  'لا توجد عمليات مسجلة في هذه الفترة',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => AppSpacing.vSm,
            itemBuilder: (context, index) {
              final item = activities[index];
              return _ActivityItemTile(
                activity: item,
                isMasked: isMasked,
                onTap: () => onActivityTap?.call(item),
              );
            },
          ),
      ],
    );
  }
}

class _ActivityItemTile extends StatelessWidget {
  final DashboardActivityEntity activity;
  final VoidCallback? onTap;
  final bool isMasked;

  const _ActivityItemTile({
    required this.activity,
    this.onTap,
    this.isMasked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isInvoice = activity.isInvoice;
    final formattedAmount = isMasked
        ? '••••••••'
        : AmountFormatter.formatValue(activity.amount);

    return CustomInteractiveBounce(
      onTap: onTap ?? () {},
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isInvoice
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.secondary.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Icon(
                isInvoice ? Icons.receipt_rounded : Icons.move_to_inbox_rounded,
                color: isInvoice ? colors.primary : colors.secondary,
                size: 20.r,
              ),
            ),
            AppSpacing.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    activity.partyName,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            AppSpacing.hSm,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedAmount,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      'ر.ي',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXxs,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    activity.statusLabel.isNotEmpty
                        ? activity.statusLabel
                        : activity.status,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

