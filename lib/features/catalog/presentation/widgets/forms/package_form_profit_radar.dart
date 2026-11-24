import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_estimate_row.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_savings_progress_bar.dart';

/// رادار حاسبة الأرباح وهوامش الجملة الحية في نموذج الباقة (Package Form Profit Radar)
///
/// يحسب فورياً نصيب الكرت، هامش ربح نقطة البيع الصافي، ومؤشر التوفير
class PackageFormProfitRadar extends GetView<PackageFormController> {
  const PackageFormProfitRadar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final preview = controller.livePreviewPackage;
      final count = preview.packageVoucherCount;
      final base = preview.totalPackageBasePrice;
      final cashP = preview.totalCashPrice;
      final creditP = preview.totalCreditPrice;
      final cashD = preview.totalCashSavings;
      final unitBase = preview.packageVoucherPrice;
      final unitCash = preview.effectiveCashPrice;
      final unitCashSavings = preview.cashDiscountAmount;

      return Container(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        size: 20.r,
                        color: colors.primary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'رادار التسعير وهوامش الربح',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '$count كرت بالحزمة',
                  style: AppTypography.badgeText.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(
              height: AppSpacing.xl,
              color: colors.outlineVariant.withValues(alpha: 0.4),
            ),
            PackageEstimateRow(
              label: 'سعر الكرت الأساسي جملة:',
              value: AmountFormatter.formatValue(unitBase),
              badgeText: 'إجمالي الحزمة ${AmountFormatter.formatValue(base)}',
              color: colors.onSurface,
            ),
            SizedBox(height: AppSpacing.xs),
            PackageEstimateRow(
              label:
                  'سعر الكرت نقداً (خصم ${preview.packageDefaultCashDiscount.toString()}%):',
              value: AmountFormatter.formatValue(unitCash),
              badgeText:
                  'وفر ${AmountFormatter.formatValue(unitCashSavings)} للكرت',
              color: colors.success,
            ),
            SizedBox(height: AppSpacing.xs),
            PackageEstimateRow(
              label:
                  'سعر الكرت آجلاً (خصم ${preview.packageDefaultCreditDiscount.toString()}%):',
              value: AmountFormatter.formatValue(creditP / count),
              badgeText: 'إجمالي ${AmountFormatter.formatValue(creditP)}',
              color: colors.info,
            ),
            SizedBox(height: AppSpacing.md),
            PackageSavingsProgressBar(
              cashDiscountPercent: preview.packageDefaultCashDiscount,
              creditDiscountPercent: preview.packageDefaultCreditDiscount,
            ),
          ],
        ),
      );
    });
  }
}
