import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:netsales/features/partners/presentation/widgets/sheets/pos_wallet_management_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// بطاقة نقطة البيع والوكيل التنفيذية المحدثة (PosItemCard)
/// ============================================================================
/// تصميم فاخر يبرز هوية الوكيل التجاري وبيانات التوزيع وإجراء إصدار الفاتورة المباشر.
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

    // تحديد اللون والسمة الدلالية لحالة نقطة البيع
    final statusColor = pos.isActive
        ? colors.success
        : (pos.isPending
            ? colors.warning
            : (pos.isRejected ? colors.error : colors.onSurfaceVariant));

    final statusBgColor = pos.isActive
        ? colors.successContainer
        : (pos.isPending
            ? colors.warningContainer
            : (pos.isRejected
                ? colors.errorContainer
                : colors.surfaceContainerHighest));

    final statusIcon = pos.isActive
        ? Icons.verified_rounded
        : (pos.isPending
            ? Icons.hourglass_top_rounded
            : (pos.isRejected
                ? Icons.cancel_outlined
                : Icons.pause_circle_outline));

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
              // وعاء البطاقة مع التدرج الشبكي المحيطي
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. ترويسة البطاقة: أيقونة نقطة البيع، الاسم، وشارة الحالة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // أيقونة نقطة البيع السكويركل بتوهج لوني
                        Container(
                          width: 42.r,
                          height: 42.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.secondary.withValues(alpha: 0.18),
                                colors.secondary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: colors.secondary.withValues(alpha: 0.28),
                              width: 0.8.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.storefront_rounded,
                            color: colors.secondary,
                            size: 22.r,
                          ),
                        ),

                        AppSpacing.hSm,

                        // الاسم والمنطقة الجغرافية
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
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Text(
                                      '${pos.governorateName ?? ''} • ${pos.directorateName ?? ''}',
                                      style: AppTypography.labelSmall.copyWith(
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

                        AppSpacing.hXs,

                        // شارة الحالة المصقولة
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 4.h,
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
                              Icon(
                                statusIcon,
                                size: 12.r,
                                color: statusColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                pos.statusLabel,
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
                    Divider(
                      color: colors.outlineVariant.withValues(alpha: 0.18),
                      height: 1.h,
                    ),
                    AppSpacing.vSm,

                    // 2. تفاصيل الوكيل ورقم التواصل المباشر
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
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pos.posPhoneNumber != null &&
                            pos.posPhoneNumber!.isNotEmpty) ...[
                          CustomInteractiveBounce(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: pos.posPhoneNumber!),
                              );
                              CustomSnackbar.show(
                                title: 'تم النسخ',
                                message: 'تم نسخ رقم هاتف نقطة البيع بنجاح.',
                                type: SnackType.info,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 12.r,
                                    color: colors.secondary,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    pos.posPhoneNumber!,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    AppSpacing.vSm,

                    // 3. شريط عداد الشبكات المرتبطة ومعرف النقطة
                    Row(
                      children: [
                        _PosCountBadge(
                          icon: Icons.hub_outlined,
                          label: '${pos.networksCount ?? 0} شبكات مرتبطة',
                          color: colors.primary,
                        ),
                        const Spacer(),
                        _PosCountBadge(
                          icon: Icons.tag_rounded,
                          label: '#${pos.posUuid}',
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),

                    // 4. أزرار الإجراءات للطلبات قيد المراجعة
                    if (pos.isPending) ...[
                      AppSpacing.vMd,
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton.primary(
                              text: 'اعتماد النقطة',
                              icon: Icons.check_circle_outline_rounded,
                              height: 38.h,
                              onPressed: () => controller.confirmApprovePos(pos),
                            ),
                          ),
                          AppSpacing.hSm,
                          Expanded(
                            child: CustomButton.danger(
                              text: 'رفض الطلب',
                              icon: Icons.cancel_outlined,
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

                    // 5. إجراء إصدار فاتورة مبيعات سريعة للنقطة المعتمدة
                    if (pos.isActive) ...[
                      AppSpacing.vSm,
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton.primary(
                              text: 'إصدار فاتورة مبيعات',
                              icon: Icons.receipt_long_rounded,
                              height: 36.h,
                              onPressed: () => CreateSaleInvoiceSheet.show(
                                context,
                                preselectedPosId: pos.posId,
                                preselectedPosName: pos.posName,
                              ),
                            ),
                          ),
                          AppSpacing.hSm,
                          _PosOptionsButton(
                            pos: pos,
                            controller: controller,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // الشريط العمودي الدلالي لحالة نقطة البيع على الحافة البادئة
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

/// ============================================================================
/// شارة إحصائية مصغرة مستقلة لبيانات نقطة البيع
/// ============================================================================
class _PosCountBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PosCountBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.2),
          width: 0.6.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 9.5.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// قائمة خيارات نقطة البيع المنبثقة
/// ============================================================================
class _PosOptionsButton extends StatelessWidget {
  final PosEntity pos;
  final PartnersController controller;

  const _PosOptionsButton({
    required this.pos,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: colors.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
            side: BorderSide(
              color: colors.outline.withValues(alpha: 0.12),
            ),
          ),
          elevation: 4,
          shadowColor: AppElevation.level3(context).first.color,
        ),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 150.w),
        icon: Icon(
          Icons.more_vert_rounded,
          color: colors.onSurfaceVariant,
          size: 19.r,
        ),
        tooltip: 'خيارات الوكيل',
        position: PopupMenuPosition.under,
        onSelected: (value) {
          switch (value) {
            case 'invoice':
              CreateSaleInvoiceSheet.show(
                context,
                preselectedPosId: pos.posId,
                preselectedPosName: pos.posName,
              );
              break;
            case 'wallet':
              final networkId = controller.networks.isNotEmpty
                  ? controller.networks.first.networkId
                  : 1;
              final networkName = controller.networks.isNotEmpty
                  ? controller.networks.first.networkName
                  : null;
              PosWalletManagementSheet.show(
                context,
                networkId: networkId,
                posId: pos.posId,
                posName: pos.posName,
                networkName: networkName,
              );
              break;
            case 'copy_uuid':
              Clipboard.setData(ClipboardData(text: pos.posUuid));
              CustomSnackbar.show(
                title: 'تم النسخ',
                message: 'تم نسخ معرّف الوكيل #${pos.posUuid} بنجاح.',
                type: SnackType.info,
              );
              break;
            case 'copy_phone':
              if (pos.posPhoneNumber != null) {
                Clipboard.setData(ClipboardData(text: pos.posPhoneNumber!));
                CustomSnackbar.show(
                  title: 'تم النسخ',
                  message: 'تم نسخ رقم الهاتف بنجاح.',
                  type: SnackType.info,
                );
              }
              break;
          }
        },
        itemBuilder: (ctx) => [
          PopupMenuItem<String>(
            value: 'wallet',
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    color: colors.primary, size: 16.r),
                AppSpacing.hSm,
                Text(
                  'المحفظة والتحويل المالي',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'invoice',
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: colors.secondary, size: 16.r),
                AppSpacing.hSm,
                Text(
                  'إصدار فاتورة مبيعات',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (pos.posPhoneNumber != null)
            PopupMenuItem<String>(
              value: 'copy_phone',
              child: Row(
                children: [
                  Icon(Icons.phone_outlined,
                      color: colors.secondary, size: 16.r),
                  AppSpacing.hSm,
                  Text(
                    'نسخ رقم الهاتف',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          PopupMenuItem<String>(
            value: 'copy_uuid',
            child: Row(
              children: [
                Icon(Icons.copy_rounded,
                    color: colors.onSurfaceVariant, size: 16.r),
                AppSpacing.hSm,
                Text(
                  'نسخ معرّف الوكيل',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
