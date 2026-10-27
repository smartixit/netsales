import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// شريط تحديد نمط العملية التجاري (OperationsSaleTypeBar)
/// ============================================================================
/// مفتاح قطاعي فاخر للتبديل بين البيع النقدي (CASH) والآجل (CREDIT)
/// متوافق كلياً مع كود الألوان والحركات والكلين كود وكافة أحجام الشاشات.
class OperationsSaleTypeBar extends StatelessWidget {
  final String selectedSaleType;
  final ValueChanged<String> onChanged;

  const OperationsSaleTypeBar({
    super.key,
    required this.selectedSaleType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCash = selectedSaleType == 'CASH';

    return Container(
      padding: EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // 1. خيار البيع النقدي
          Expanded(
            child: CustomInteractiveBounce(
              onTap: () => onChanged('CASH'),
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.standard,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isCash ? colors.primary : Colors.transparent,
                  borderRadius: AppRadius.smRadius,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        size: 15.r,
                        color: isCash ? colors.onPrimary : colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXs,
                      Text(
                        'بيع نقدي',
                        style: AppTypography.buttonMedium.copyWith(
                          color: isCash ? colors.onPrimary : colors.onSurfaceVariant,
                          fontWeight: isCash ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          AppSpacing.hXs,

          // 2. خيار البيع الآجل
          Expanded(
            child: CustomInteractiveBounce(
              onTap: () => onChanged('CREDIT'),
              child: AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.standard,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: !isCash ? colors.error : Colors.transparent,
                  borderRadius: AppRadius.smRadius,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.credit_score_rounded,
                        size: 15.r,
                        color: !isCash ? colors.onError : colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXs,
                      Text(
                        'بيع آجل',
                        style: AppTypography.buttonMedium.copyWith(
                          color: !isCash ? colors.onError : colors.onSurfaceVariant,
                          fontWeight: !isCash ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
