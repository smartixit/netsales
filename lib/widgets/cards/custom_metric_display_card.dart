import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';

/// بطاقة عرض الإحصائيات والمؤشرات المالية الموحدة (CustomMetricDisplayCard)
class CustomMetricDisplayCard extends StatelessWidget {
  const CustomMetricDisplayCard({super.key, required this.data});

  final CustomMetricCardData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: data.isPrimary
              ? data.accentColor.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.35),
          width: data.isPrimary ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: data.isPrimary
                ? data.accentColor.withValues(alpha: 0.06)
                : colors.shadow.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.r),
                  border: Border.all(
                    color: data.accentColor.withValues(alpha: 0.20),
                    width: 0.8,
                  ),
                ),
                child: Icon(data.icon, size: 16.r, color: data.accentColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.caption != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        data.caption!,
                        style: AppTypography.caption.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 9.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  data.value,
                  style: AppTypography.titleMedium.copyWith(
                    color: data.isPrimary ? data.accentColor : colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.sp,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (data.unit != null) ...[
                  SizedBox(width: 3.w),
                  Text(
                    data.unit!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
