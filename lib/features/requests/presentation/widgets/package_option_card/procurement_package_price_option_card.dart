import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// بطاقة خيار السعر (نقدي / آجل) في باقة التوريد
class ProcurementPackagePriceOptionCard extends StatelessWidget {
  const ProcurementPackagePriceOptionCard({
    super.key,
    required this.selectedMarkerKey,
    required this.label,
    required this.price,
    required this.discount,
    required this.money,
    required this.currency,
    required this.selected,
    required this.isDiscountLoading,
    this.isSecond = false,
  });

  final Key selectedMarkerKey;
  final String label;
  final double price;
  final double discount;
  final String Function(num) money;
  final String currency;
  final bool selected;
  final bool isSecond;
  final bool isDiscountLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: label,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        padding: EdgeInsetsDirectional.fromSTEB(8.r, 8.r, 8.r, 7.r),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: .10)
              : colors.surface,
          borderRadius: !isSecond
              ? BorderRadiusDirectional.only(
                  topStart: Radius.circular(AppRadius.md),
                  bottomStart: Radius.circular(AppRadius.md),
                  topEnd: Radius.circular(AppRadius.xs),
                  bottomEnd: Radius.circular(AppRadius.xs),
                )
              : BorderRadiusDirectional.only(
                  topStart: Radius.circular(AppRadius.xs),
                  bottomStart: Radius.circular(AppRadius.xs),
                  topEnd: Radius.circular(AppRadius.md),
                  bottomEnd: Radius.circular(AppRadius.md),
                ),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: .72)
                : colors.outlineVariant.withValues(alpha: .58),
            width: 1.25,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: .055),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: selected ? colors.primary : colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSpacing.hXxs,
                SizedBox(
                  width: 37.r,
                  height: 16.r,
                  child: Center(
                    child: selected
                        ? AnimatedOpacity(
                            duration: const Duration(milliseconds: 160),
                            opacity: 1,
                            child: Text(
                              'المحدد',
                              maxLines: 1,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.r,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                AppSpacing.hXxs,
                SizedBox.square(
                  dimension: 19.r,
                  child: selected
                      ? AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: 1,
                          child: Tooltip(
                            message: 'نوع البيع المحدد',
                            child: Container(
                              key: selectedMarkerKey,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(
                                      alpha: .20,
                                    ),
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 13.r,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            AppSpacing.vXs,
            if (isDiscountLoading)
              const CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.text,
                  lineCount: 2,
                  showCardSurface: false,
                ),
              )
            else if (discount > 0) ...{
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '${money(price)} $currency',
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 13.sp,
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              AppSpacing.vXxs,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 3.r),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.success.withValues(alpha: .18),
                    ),
                  ),
                  child: Text(
                    'خصم ${discount.toStringAsFixed(2)}٪',
                    maxLines: 1,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.success,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            } else
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'حسب التعرفة',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
