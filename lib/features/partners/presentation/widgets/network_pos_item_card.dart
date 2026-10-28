import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/features/partners/domain/entities/network_pos_entity.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/sheets/pos_wallet_management_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// بطاقة عقد الشراكة والتوزيع المحدثة (NetworkPosItemCard)
/// ============================================================================
/// تصميم انسيابي يحاكي السندات والعقود التجارية الذكية (Connected Distribution Bond)،
/// يربط طرفي الشراكة (الشبكة ونقطة البيع) مع إمكانية التبديل اللحظي للحالة وإصدار الفواتير.
class NetworkPosItemCard extends StatelessWidget {
  final NetworkPosEntity link;
  final PartnersController controller;

  const NetworkPosItemCard({
    super.key,
    required this.link,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final statusColor = link.isActive ? colors.success : colors.error;
    final statusBgColor =
        link.isActive ? colors.successContainer : colors.errorContainer;
    final statusIcon =
        link.isActive ? Icons.verified_rounded : Icons.pause_circle_outline;

    return CustomInteractiveBounce(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.level1(context),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.lgRadius,
          child: Stack(
            children: [
              // وعاء البطاقة مع التدرج الشبكي
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      statusColor.withValues(alpha: 0.06),
                      colors.surface.withValues(alpha: 0.40),
                      colors.surfaceContainerLowest,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  borderRadius: AppRadius.lgRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.28),
                    width: 1.w,
                  ),
                ),
                padding: EdgeInsetsDirectional.only(
                  start: 16.w,
                  end: 14.w,
                  top: 14.h,
                  bottom: 14.h,
                ),
                child: Column(
                  children: [
                    // 1. جسر الربط الثنائي بين طرفي العقد (الشبكة <---> نقطة البيع)
                    Row(
                      children: [
                        // طرف مزود الشبكة
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer
                                  .withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.22),
                                width: 0.8.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5.r),
                                  decoration: BoxDecoration(
                                    color: colors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.wifi_tethering_rounded,
                                    color: colors.primary,
                                    size: 16.r,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'مزود الشبكة',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                      AppSpacing.vXxs,
                                      Text(
                                        link.networkName ??
                                            'شبكة #${link.networkId}',
                                        style:
                                            AppTypography.bodySmall.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // أيقونة الارتباط المركزية المتوهجة
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withValues(alpha: 0.16),
                                  colors.surfaceContainerHighest,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.35),
                                width: 1.w,
                              ),
                            ),
                            child: Icon(
                              Icons.swap_horiz_rounded,
                              size: 18.r,
                              color: statusColor,
                            ),
                          ),
                        ),

                        // طرف نقطة التوزيع / الوكيل
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer
                                  .withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: colors.secondary.withValues(alpha: 0.22),
                                width: 0.8.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5.r),
                                  decoration: BoxDecoration(
                                    color: colors.secondary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    color: colors.secondary,
                                    size: 16.r,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'نقطة التوزيع',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: colors.secondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                      AppSpacing.vXxs,
                                      Text(
                                        link.posName ?? 'نقطة #${link.posId}',
                                        style:
                                            AppTypography.bodySmall.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vSm,
                    Divider(
                      color: colors.outlineVariant.withValues(alpha: 0.18),
                      height: 1.h,
                    ),
                    AppSpacing.vSm,

                    // 2. تفاصيل الموقع الجغرافي وشارة الحالة الموحدة
                    Row(
                      children: [
                        if (link.governorateName != null &&
                            link.governorateName!.isNotEmpty) ...[
                          Icon(
                            Icons.location_on_outlined,
                            size: 13.r,
                            color: colors.onSurfaceVariant,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              '${link.governorateName ?? ''} • ${link.directorateName ?? ''}',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else
                          const Spacer(),

                        // شارة الحالة
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 3.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: AppRadius.fullRadius,
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.25),
                              width: 0.8.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon,
                                  size: 11.r, color: statusColor),
                              SizedBox(width: 4.w),
                              Text(
                                link.statusLabel,
                                style: AppTypography.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.vSm,

                    // 3. أزرار التحكم والعمليات المباشرة
                    Row(
                      children: [
                        // زر إصدار فاتورة مبيعات سريعة
                        Expanded(
                          child: CustomButton.primary(
                            text: 'فاتورة كروت',
                            icon: Icons.receipt_long_rounded,
                            height: 36.h,
                            onPressed: () => CreateSaleInvoiceSheet.show(
                              context,
                              preselectedPosId: link.posId,
                              preselectedPosName: link.posName,
                            ),
                          ),
                        ),

                        AppSpacing.hSm,

                        // زر إدارة المحفظة المشتركة والتحويل المالي
                        Expanded(
                          child: CustomButton.secondary(
                            text: 'المحفظة المشتركة',
                            icon: Icons.account_balance_wallet_rounded,
                            height: 36.h,
                            onPressed: () => PosWalletManagementSheet.show(
                              context,
                              networkId: link.networkId,
                              posId: link.posId,
                              posName: link.posName ?? 'نقطة البيع',
                              networkName: link.networkName,
                            ),
                          ),
                        ),

                        AppSpacing.hSm,

                        // قائمة خيارات العقد المنبثقة الموحدة
                        CustomPopupMenu<String>(
                          tooltip: 'خيارات العقد',
                          onSelected: (value) async {
                            if (value == 'toggle') {
                              final confirmed =
                                  await CustomDialog.showConfirmation(
                                title: link.isActive
                                    ? 'تأكيد تجميد العقد'
                                    : 'تأكيد تفعيل العقد',
                                message: link.isActive
                                    ? 'هل أنت متأكد من تجميد عقد الارتباط بين "${link.networkName}" و"${link.posName}"؟ لن يتمكن الوكيل من طلب الكروت مؤقتاً.'
                                    : 'هل أنت متأكد من إعادة تفعيل عقد الارتباط بين "${link.networkName}" و"${link.posName}"؟',
                                confirmLabel: link.isActive
                                    ? 'نعم، تجميد العقد'
                                    : 'نعم، تفعيل العقد',
                                cancelLabel: 'إلغاء',
                              );
                              if (confirmed == true) {
                                await controller
                                    .toggleLinkStatus(link.networkPosId);
                              }
                            } else if (value == 'copy') {
                              Clipboard.setData(
                                ClipboardData(text: link.networkPosId.toString()),
                              );
                              CustomSnackbar.show(
                                title: 'تم النسخ',
                                message:
                                    'تم نسخ معرّف العقد #${link.networkPosId} بنجاح.',
                                type: SnackType.info,
                              );
                            }
                          },
                          items: [
                            CustomPopupItem<String>(
                              value: 'toggle',
                              label: link.isActive
                                  ? 'تجميد عقد الشراكة'
                                  : 'تفعيل عقد الشراكة',
                              icon: link.isActive
                                  ? Icons.pause_circle_outline_rounded
                                  : Icons.play_circle_outline_rounded,
                              iconColor:
                                  link.isActive ? colors.error : colors.success,
                              isDestructive: link.isActive,
                            ),
                            const CustomPopupDivider<String>(),
                            CustomPopupItem<String>(
                              value: 'copy',
                              label: 'نسخ معرّف العقد (#${link.networkPosId})',
                              icon: Icons.copy_rounded,
                              iconColor: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // الشريط العمودي الدلالي لحالة العقد
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4.w,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
