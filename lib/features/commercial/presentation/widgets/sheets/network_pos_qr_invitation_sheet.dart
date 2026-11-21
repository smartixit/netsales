import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/qr/custom_qr_code.dart';

/// ورقة سفلية لعرض رمز دعوة الارتباط التجاري المعتمد (QR Code) لمشغل الشبكة
///
/// تلتزم بأعلى معايير الأمان والتصميم المؤسسي:
/// - تشفير كامل: تعرض رمز الـ QR عبر [CustomQrCode] دون تسريب أي بيانات تشفير حساسة في نصوص الواجهة.
/// - تمثيل حالة الدعوة عبر المحرك المركزي الموحد [EnumPresentationRegistry].
/// - إرشادات أمان واضحة للطرفين.
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
    final statusPres = EnumPresentationRegistry.resolveLinkingChallengeStatus(
      challenge.typedStatus,
      serverLabel: challenge.statusLabel,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. رمز QR داخل إطار حماية وتصميم معتمد
          Center(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: .2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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

          // 2. حالة الدعوة والصلاحية الأمنية
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomStatusBadge(
                  label: statusPres.label,
                  tone: statusPres.tone,
                  icon: statusPres.icon,
                ),
                if (challenge.expiresAt != null) ...[
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'صالح لمدة 15 دقيقة',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // 3. إرشادات الأمان والاستخدام
          Text(
            'وجّه التاجر لمسح رمز الـ QR عبر كاميرا التطبيق في نقطة البيع لإتمام وتأكيد الارتباط التجاري فورياً.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
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
