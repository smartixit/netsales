import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/reject_partner_dialog.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// بطاقة مزود الشبكة التنفيذية المحدثة (NetworkItemCard)
/// ============================================================================
/// تصميم فاخر يحاكي بطاقات الأعمال الرقمية في كبرى المنصات المؤسسية،
/// يدمج الهوية البصرية، مؤشرات التوزيع، وأزرار القرار التشغيلي اللحظي.
class NetworkItemCard extends StatelessWidget {
  final NetworkEntity network;
  final PartnersController controller;

  const NetworkItemCard({
    super.key,
    required this.network,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // تحديد اللون والسمة الدلالية لحالة الشبكة
    final statusColor = network.isActive
        ? colors.success
        : (network.isPending
            ? colors.warning
            : (network.isRejected ? colors.error : colors.onSurfaceVariant));

    final statusBgColor = network.isActive
        ? colors.successContainer
        : (network.isPending
            ? colors.warningContainer
            : (network.isRejected
                ? colors.errorContainer
                : colors.surfaceContainerHighest));

    final statusIcon = network.isActive
        ? Icons.verified_rounded
        : (network.isPending
            ? Icons.hourglass_top_rounded
            : (network.isRejected
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
                    // 1. ترويسة البطاقة: أيقونة الشبكة، الاسم، وشارة الحالة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // أيقونة الشبكة السداسية ذات التوهج المحيطي
                        Container(
                          width: 42.r,
                          height: 42.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.primary.withValues(alpha: 0.18),
                                colors.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.28),
                              width: 0.8.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.wifi_tethering_rounded,
                            color: colors.primary,
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
                                network.networkName,
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
                                      '${network.governorateName ?? ''} • ${network.directorateName ?? ''}',
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
                                network.statusLabel,
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

                    // 2. تفاصيل المالك ورقم التواصل
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14.r,
                          color: colors.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            network.ownerName ?? 'غير محدد',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (network.networkPhoneNumber != null &&
                            network.networkPhoneNumber!.isNotEmpty) ...[
                          CustomInteractiveBounce(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: network.networkPhoneNumber!,
                                ),
                              );
                              CustomSnackbar.show(
                                title: 'تم النسخ',
                                message:
                                    'تم نسخ رقم هاتف مزود الشبكة بنجاح.',
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
                                    color: colors.primary,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    network.networkPhoneNumber!,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.primary,
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

                    // 3. شريط مؤشرات الوكلاء والباقات والمعرف
                    Row(
                      children: [
                        _NetworkCountBadge(
                          icon: Icons.storefront_outlined,
                          label: '${network.posCount ?? 0} نقطة بيع',
                          color: colors.secondary,
                        ),
                        AppSpacing.hXs,
                        _NetworkCountBadge(
                          icon: Icons.confirmation_number_outlined,
                          label: '${network.packagesCount ?? 0} باقة كروت',
                          color: colors.tertiary,
                        ),
                        const Spacer(),
                        _NetworkCountBadge(
                          icon: Icons.tag_rounded,
                          label: '#${network.networkUuid}',
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),

                    // 4. أزرار الإجراءات للطلبات قيد المراجعة
                    if (network.isPending) ...[
                      AppSpacing.vMd,
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton.primary(
                              text: 'اعتماد الشبكة',
                              icon: Icons.check_circle_outline_rounded,
                              height: 38.h,
                              onPressed: () =>
                                  controller.confirmApproveNetwork(network),
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
                                isNetwork: true,
                                id: network.networkId,
                                name: network.networkName,
                                controller: controller,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // 5. إجراءات سريعة للشبكة المعتمدة
                    if (network.isActive) ...[
                      AppSpacing.vSm,
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton.outline(
                              text: 'باقات الكروت والأسعار',
                              icon: Icons.confirmation_number_outlined,
                              height: 36.h,
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.voucherPackages),
                            ),
                          ),
                          AppSpacing.hSm,
                          _NetworkOptionsButton(
                            network: network,
                            controller: controller,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // الشريط العمودي الدلالي لحالة الشبكة على الحافة البادئة
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
/// شارة إحصائية مصغرة مستقلة لبيانات الشبكة
/// ============================================================================
class _NetworkCountBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _NetworkCountBadge({
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
/// قائمة خيارات الشبكة المنبثقة
/// ============================================================================
class _NetworkOptionsButton extends StatelessWidget {
  final NetworkEntity network;
  final PartnersController controller;

  const _NetworkOptionsButton({
    required this.network,
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
        tooltip: 'خيارات الشبكة',
        position: PopupMenuPosition.under,
        onSelected: (value) {
          switch (value) {
            case 'filter_pos':
              controller.searchController.text = network.networkName;
              controller.onSearchSubmitted(network.networkName);
              controller.changeSegment(1);
              break;
            case 'copy_uuid':
              Clipboard.setData(ClipboardData(text: network.networkUuid));
              CustomSnackbar.show(
                title: 'تم النسخ',
                message: 'تم نسخ معرّف الشبكة #${network.networkUuid} بنجاح.',
                type: SnackType.info,
              );
              break;
            case 'packages':
              Get.toNamed(AppRoutes.voucherPackages);
              break;
          }
        },
        itemBuilder: (ctx) => [
          PopupMenuItem<String>(
            value: 'filter_pos',
            child: Row(
              children: [
                Icon(Icons.storefront_outlined,
                    color: colors.primary, size: 16.r),
                AppSpacing.hSm,
                Text(
                  'عرض وكلاء الشبكة',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'packages',
            child: Row(
              children: [
                Icon(Icons.confirmation_number_outlined,
                    color: colors.secondary, size: 16.r),
                AppSpacing.hSm,
                Text(
                  'إدارة الباقات والخصومات',
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
                  'نسخ معرّف الشبكة',
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
