import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ============================================================================
/// بطاقة ملاحظات وتفاصيل طلب التوريد (RequestNotesCard)
/// ============================================================================
/// تعرض التعليمات الميدانية والملاحظات المرفقة بطلب التوريد بنمط مذكرة سيادية.
class RequestNotesCard extends StatelessWidget {
  final String note;

  const RequestNotesCard({
    super.key,
    required this.note,
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
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 1.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.notes_rounded,
              color: colors.primary,
              size: 18.r,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملاحظات وتعليمات الطلب',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  note,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
