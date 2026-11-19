import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_text_styles.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// ورقة سفلية لمسح/إدخال رمز دعوة الارتباط ومعاينة بيانات المزود لنقطة البيع
class PosQrConfirmLinkSheet extends StatelessWidget {
  const PosQrConfirmLinkSheet({
    super.key,
    required this.codeController,
    required this.preview,
    required this.onPreview,
    required this.onConfirm,
  });

  final TextEditingController codeController;
  final NetworkPosLinkPreviewEntity? preview;
  final VoidCallback onPreview;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. حقل إدخال كود الارتباط
          CustomTextField(
            controller: codeController,
            label: 'كود دعوة الارتباط أو الرمز المشفر',
            hint: 'أدخل كود الدعوة أو الصق الرمز...',
            prefixIcon: const Icon(Icons.qr_code_rounded),
            isRequired: true,
          ),
          SizedBox(height: AppSpacing.sm),

          // زر الفحص والمعاينة إذا لم تكن هناك معاينة بعد
          if (preview == null) ...[
            CustomButton.primary(
              text: 'فحص كود الدعوة',
              icon: Icons.search_rounded,
              size: AppButtonSize.medium,
              onPressed: onPreview,
            ),
          ],

          // 2. بطاقة معاينة بيانات الشبكة المزودة في حال تم فحص الرمز
          if (preview != null) ...[
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: .25),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: colors.primary, size: 22.r),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'بيانات مزود الشبكة المعتمد',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    preview!.network.displayName,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'هاتف الدعم: ${preview!.network.displayPhone}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'المقر: ${preview!.network.displayLocation}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // أزرار التأكيد
            Row(
              children: [
                Expanded(
                  child: CustomButton.outline(
                    text: 'إلغاء',
                    size: AppButtonSize.medium,
                    onPressed: () => Get.back<void>(),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: CustomButton.primary(
                    text: 'تأكيد الارتباط بالمزود',
                    icon: Icons.check_circle_rounded,
                    size: AppButtonSize.medium,
                    onPressed: () {
                      Get.back<void>();
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
