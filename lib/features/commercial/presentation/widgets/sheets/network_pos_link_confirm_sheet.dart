import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_detail_row.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ورقة سفلية لتأكيد واعتماد ربط نقطة البيع بالشبكة بعد مسح رمز الدعوة المشفر بالكاميرا
class NetworkPosLinkConfirmSheet extends StatelessWidget {
  const NetworkPosLinkConfirmSheet({
    super.key,
    required this.preview,
    required this.onConfirm,
    this.onCancel,
  });

  final NetworkPosLinkPreviewEntity preview;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  /// عرض النافذة السفلية الموحدة للمعاينة والتأكيد
  static Future<bool?> show({
    required NetworkPosLinkPreviewEntity preview,
    required Future<bool> Function() onConfirm,
  }) {
    return CustomBottomSheet.show<bool>(
      title: 'تأكيد الارتباط التجاري',
      subtitle: 'تم فحص وقراءة رمز الدعوة المشفر بنجاح',
      leadingIcon: Icons.link_rounded,
      child: NetworkPosLinkConfirmSheet(
        preview: preview,
        onConfirm: () async {
          final success = await onConfirm();
          if (success) {
            Get.back<bool>(result: true);
          }
        },
        onCancel: () => Get.back<bool>(result: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusPres = EnumPresentationRegistry.resolveNetworkStatus(
      preview.network.typedStatus,
      serverLabel: preview.network.statusLabel,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(16.r),
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
                    Icon(
                      Icons.verified_rounded,
                      color: colors.primary,
                      size: 22.r,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'بيانات مزود الشبكة المعتمد',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                    const Spacer(),
                    CustomStatusBadge(
                      label: statusPres.label,
                      tone: statusPres.tone,
                      icon: statusPres.icon,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  preview.displayNetworkName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                CommercialDetailRow(
                  icon: Icons.tag_rounded,
                  label: 'المعرف المرجعي:',
                  value: preview.displayNetworkReference,
                ),
                CommercialDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'هاتف الدعم:',
                  value: preview.displayNetworkPhone,
                ),
                CommercialDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'الموقع الجغرافي:',
                  value: preview.displayNetworkLocation,
                ),
                CommercialDetailRow(
                  icon: Icons.timer_outlined,
                  label: 'صلاحية الدعوة:',
                  value: preview.formattedExpiry,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'إلغاء',
                  size: AppButtonSize.medium,
                  shape: AppButtonShape.pill,
                  onPressed: onCancel ?? () => Get.back<bool>(result: false),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: CustomButton.primary(
                  text: 'تأكيد وإتمام الارتباط',
                  icon: Icons.check_circle_outline_rounded,
                  size: AppButtonSize.medium,
                  shape: AppButtonShape.pill,
                  onPressed: onConfirm,
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
