import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_text_styles.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_detail_row.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ورقة سفلية لاستعراض التفاصيل الكاملة للشريك التجاري (شبكة أو نقطة بيع)
class CommercialPartnerDetailsSheet extends StatelessWidget {
  const CommercialPartnerDetailsSheet({
    super.key,
    required this.link,
    this.isNetworkView = true,
  });

  final NetworkPosLinkEntity link;
  final bool isNetworkView;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final partnerName =
        isNetworkView ? link.displayPosName : link.displayNetworkName;
    final partnerRef =
        isNetworkView ? link.displayPosReference : link.displayNetworkReference;
    final phone = isNetworkView ? link.posPhone : link.networkPhone;
    final manager =
        isNetworkView ? link.posOwnerName : link.networkOwnerName;
    final location =
        isNetworkView ? link.posLocation : link.networkLocation;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. رأس البطاقة التعريفية
          Center(
            child: Column(
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isNetworkView
                        ? Icons.storefront_rounded
                        : Icons.hub_rounded,
                    color: colors.primary,
                    size: 32.r,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  partnerName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  partnerRef,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                CustomStatusBadge(
                  label: link.isActive ? 'ارتباط نشط' : 'ارتباط مجمد',
                  type: link.isActive
                      ? StatusBadgeType.success
                      : StatusBadgeType.warning,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // 2. قائمة التفاصيل المعيارية
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .3),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                CommercialDetailRow(
                  icon: Icons.phone_android_rounded,
                  label: 'رقم الهاتف',
                  value: phone,
                  onTap: () => UrlLauncherService.openDialer(phone),
                ),
                Divider(
                    color: colors.outlineVariant.withValues(alpha: .4),
                    height: 12.h),
                CommercialDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'المسؤول التجاري',
                  value: manager,
                ),
                Divider(
                    color: colors.outlineVariant.withValues(alpha: .4),
                    height: 12.h),
                CommercialDetailRow(
                  icon: Icons.place_outlined,
                  label: 'العنوان والموقع',
                  value: location,
                ),
                Divider(
                    color: colors.outlineVariant.withValues(alpha: .4),
                    height: 12.h),
                CommercialDetailRow(
                  icon: Icons.event_available_rounded,
                  label: 'تاريخ بدء الارتباط',
                  value: link.formattedLinkedDate,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // 3. زر الإغلاق
          CustomButton.primary(
            text: 'إغلاق',
            size: AppButtonSize.medium,
            onPressed: () => Get.back<void>(),
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
