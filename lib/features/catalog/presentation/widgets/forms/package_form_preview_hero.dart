import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_voucher_card_showcase.dart';

/// هيرو المحاكاة الحية المباشرة لكرت الباقة أثناء الإنشاء أو التعديل (Live Voucher Simulator Hero)
///
/// يعكس تفاعل صاحب الشبكة المباشر مع المنتج، ويحدث بطاقة الكرت ثلاثية الأبعاد فورياً مع كل لمسة
class PackageFormPreviewHero extends GetView<PackageFormController> {
  const PackageFormPreviewHero({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18.r,
                  color: colors.primary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'المعاينة الحية لكرت الإنترنت الرقمي',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            Text(
              'محاكاة تفاعلية فورية',
              style: AppTypography.badgeText.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Obx(() {
          final preview = controller.livePreviewPackage;
          return PackageVoucherCardShowcase(
            package: preview,
            showPricingSummary: false,
            previewPricing: PackageVoucherPreviewPricing(
              basePrice: controller.liveBasePrice.value,
              cashDiscountRate: controller.liveCashDiscountRate.value,
              creditDiscountRate: controller.liveCreditDiscountRate.value,
            ),
          );
        }),
      ],
    );
  }
}
