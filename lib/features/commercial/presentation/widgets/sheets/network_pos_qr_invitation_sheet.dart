import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/qr/custom_qr_code.dart';

/// ورقة سفلية لعرض رمز دعوة الارتباط التجاري المشفر (QR Code) لمشغل الشبكة
class NetworkPosQrInvitationSheet extends StatelessWidget {
  const NetworkPosQrInvitationSheet({
    super.key,
    required this.challenge,
    required this.onRevoke,
  });

  final NetworkPosLinkChallengeEntity challenge;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. رمز QR
          Center(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: .2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CustomQrCode(
                data: challenge.payload,
                size: 200.r,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // 2. كود الدعوة مع زر النسخ السريع
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .4),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'كود الارتباط المباشر',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        challenge.payload,
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CustomButton.secondary(
                  text: 'نسخ',
                  icon: Icons.copy_rounded,
                  size: AppButtonSize.small,
                  onPressed: () =>
                      UrlLauncherService.copyToClipboard(challenge.payload),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // 3. إرشادات الاستخدام
          Text(
            'قم بمشاركة هذا الرمز أو كود الدعوة مع نقطة البيع لمسحه وتأكيد الارتباط التجاري فورياً.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // 4. أزرار التحكم
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'إلغاء الدعوة',
                  icon: Icons.block_rounded,
                  size: AppButtonSize.medium,
                  onPressed: () {
                    Get.back<void>();
                    onRevoke();
                  },
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: CustomButton.primary(
                  text: 'إغلاق',
                  size: AppButtonSize.medium,
                  onPressed: () => Get.back<void>(),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
