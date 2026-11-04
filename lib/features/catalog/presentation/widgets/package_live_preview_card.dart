import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';

/// بطاقة المعاينة الاسترشادية للأسعار الصافية (للعرض فقط - غير ملزمة مالياً)
class PackageLivePreviewCard extends GetView<PackageCatalogController> {
  const PackageLivePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      return Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: AppSpacing.lg,
                  color: colors.primary,
                ),
                AppSpacing.hXs,
                Expanded(
                  child: Text(
                    'معاينة استرشادية للأسعار الصافية المتوقعة',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vXs,
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الصافي النقدي: ${AmountFormatter.format(controller.previewEffectiveCashPrice.value.toString())}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'الصافي الآجل: ${AmountFormatter.format(controller.previewEffectiveCreditPrice.value.toString())}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

