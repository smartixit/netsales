import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class ProcurementEditModeBanner extends StatelessWidget {
  const ProcurementEditModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: .28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_clock_rounded,
              size: 18.r,
              color: colors.primary,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أطراف العملية التوريدية ثابتة أثناء التعديل',
                  style: AppTypography.labelLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  'تم تثبيت الشبكة المورّدة ونقطة البيع لضمان دقة اتفاقية الأسعار والائتمان المعتمد. يمكنك تعديل طريقة الدفع، الملاحظات، والكميات بحرية.\nإذا أردت توريد طلب لشبكة أخرى، يمكنك إلغاء هذا الطلب وإنشاء طلب جديد.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
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
