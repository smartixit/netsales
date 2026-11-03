import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/pos_details_bottom_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// بطاقة نقطة البيع التفاعلية ضمن دليل شبكة المزود
class NetworkPosCard extends GetView<CommercialDirectoryController> {
  const NetworkPosCard({super.key, required this.link});

  final NetworkPosLinkEntity link;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pos = link.pos;

    final isActive = link.status;
    final statusColor = isActive ? colors.success : colors.error;

    return CustomInteractiveBounce(
      onTap: () {
        if (pos != null) {
          PosDetailsBottomSheet.show(pos: pos);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ترويسة البطاقة: الشعار، الاسم، وشارة الحالة
            Row(
              children: [
                // صورة أو أيقونة نقطة البيع
                if (pos?.posProfileLogoUrl != null &&
                    pos!.posProfileLogoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: CustomCachedImage(
                      url: pos.posProfileLogoUrl!,
                      width: 48.r,
                      height: 48.r,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      color: colors.primary,
                      size: 26.r,
                    ),
                  ),

                AppSpacing.hMd,

                // اسم نقطة البيع ورقم الهاتف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pos?.posName ?? 'نقطة بيع #${link.posId}',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vXxs,
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14.r,
                            color: colors.onSurfaceVariant,
                          ),
                          AppSpacing.hXxs,
                          Text(
                            pos?.posPhoneNumber.isNotEmpty == true
                                ? pos!.posPhoneNumber
                                : 'لا يوجد هاتف',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // شارة الحالة (Badge)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.hXxs,
                      Text(
                        isActive ? 'نشط' : 'معطل',
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // 2. المعرف الفريد UUID مع زر النسخ
            if (pos?.posUuid.isNotEmpty == true)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      size: 16.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXs,
                    Expanded(
                      child: Text(
                        pos!.posUuid,
                        style: AppTypography.labelSmall.copyWith(
                          fontFamily: 'monospace',
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CustomButton.icon(
                      icon: Icons.copy_rounded,
                      iconSize: 16.r,
                      dimension: 28.r,
                      tooltip: 'نسخ المعرف',
                      onPressed: () async {
                        await UrlLauncherService.copyToClipboard(pos.posUuid);
                        CustomToast.show(
                          message: 'تم نسخ معرف نقطة البيع',
                          icon: Icons.copy_rounded,
                        );
                      },
                    ),
                  ],
                ),
              ),

            AppSpacing.vMd,

            // 3. أزرار التحكم والإجراءات الموحدة
            Row(
              children: [
                // زر تبديل الحالة الموحد
                Expanded(
                  child: CustomButton.outline(
                    text: isActive ? 'تعطيل الارتباط' : 'تفعيل الارتباط',
                    icon: isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    onPressed: () =>
                        controller.toggleLinkStatus(link.networkPosId),
                  ),
                ),

                AppSpacing.hSm,

                // زر فك الارتباط الموحد مع حوار التأكيد التحذيري
                CustomButton.danger(
                  text: 'فك الارتباط',
                  icon: Icons.link_off_rounded,
                  onPressed: () {
                    CustomDialog.danger(
                      title: 'فك ارتباط نقطة البيع',
                      message:
                          'هل أنت متأكد من رغبتك في فك ارتباط "${pos?.posName ?? 'نقطة البيع'}" بالشبكة؟ سيؤدي ذلك لتعليق طلبات التوريد بالجملة.',
                      confirmLabel: 'تأكيد فك الارتباط',
                      cancelLabel: 'إلغاء',
                      onConfirm: () => controller.unlinkPos(link.networkPosId),
                    ).showDialog(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
