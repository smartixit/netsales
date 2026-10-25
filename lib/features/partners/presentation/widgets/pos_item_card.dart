import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/features/partners/domain/entities/pos_entity.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/reject_partner_dialog.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة استعراض نقطة البيع / الوكيل (PosItemCard)
/// ============================================================================
/// بطاقة تفاعلية تعرض تفاصيل نقطة البيع، الوكيل، وحالته التشغيلية مع أزرار الإجراءات.
class PosItemCard extends StatelessWidget {
  final PosEntity pos;
  final PartnersController controller;

  const PosItemCard({
    super.key,
    required this.pos,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // تحديد لون شارة الحالة
    late final Color statusBg;
    late final Color statusFg;

    if (pos.isActive) {
      statusBg = colors.successContainer;
      statusFg = colors.success;
    } else if (pos.isPending) {
      statusBg = colors.warningContainer;
      statusFg = colors.warning;
    } else if (pos.isRejected) {
      statusBg = colors.errorContainer;
      statusFg = colors.error;
    } else {
      statusBg = colors.surfaceContainerHighest;
      statusFg = colors.onSurfaceVariant;
    }

    return CustomInteractiveBounce(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppElevation.level1(context),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 1.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ترويسة البطاقة: الأيقونة، اسم نقطة البيع، وشارة الحالة
            Row(
              children: [
                // أيقونة نقطة البيع
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.storefront_rounded,
                      color: colors.secondary,
                      size: 24.r,
                    ),
                  ),
                ),
                AppSpacing.hSm,
                // اسم نقطة البيع والمنطقة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pos.posName,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vXxs,
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13.r,
                            color: colors.onSurfaceVariant,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              '${pos.governorateName ?? ''} - ${pos.directorateName ?? ''}',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // شارة الحالة
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    pos.statusLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: statusFg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,
            Divider(color: colors.outlineVariant.withValues(alpha: 0.2)),
            AppSpacing.vXs,

            // 2. تفاصيل الوكيل ورقم الهاتف
            Row(
              children: [
                Icon(
                  Icons.person_pin_circle_outlined,
                  size: 14.r,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    pos.agentName ?? 'غير محدد',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (pos.posPhoneNumber != null &&
                    pos.posPhoneNumber!.isNotEmpty) ...[
                  Icon(
                    Icons.phone_outlined,
                    size: 14.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    pos.posPhoneNumber!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),

            AppSpacing.vXs,

            // 3. عداد الشبكات المرتبطة
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hub_outlined,
                    size: 12.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${pos.networksCount ?? 0} شبكات مرتبطة',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // 4. أزرار الإجراءات للطلبات المعلقة
            if (pos.isPending) ...[
              AppSpacing.vSm,
              Row(
                children: [
                  Expanded(
                    child: CustomButton.primary(
                      text: 'اعتماد النقطة',
                      icon: Icons.check_rounded,
                      height: 38.h,
                      onPressed: () => controller.confirmApprovePos(pos),
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: CustomButton.danger(
                      text: 'رفض الطلب',
                      icon: Icons.close_rounded,
                      height: 38.h,
                      onPressed: () => RejectPartnerDialog.show(
                        context,
                        isNetwork: false,
                        id: pos.posId,
                        name: pos.posName,
                        controller: controller,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // 5. إجراء إصدار فاتورة مبيعات مباشرة لنقطة البيع المفعلة
            if (pos.isActive) ...[
              AppSpacing.vSm,
              CustomButton.outline(
                text: 'إصدار فاتورة مبيعات',
                icon: Icons.receipt_long_rounded,
                height: 38.h,
                onPressed: () => CreateSaleInvoiceSheet.show(
                  context,
                  preselectedPosId: pos.posId,
                  preselectedPosName: pos.posName,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
