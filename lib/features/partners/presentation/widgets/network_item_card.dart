import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/partners/domain/entities/network_entity.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/reject_partner_dialog.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// بطاقة استعراض مزود الشبكة (NetworkItemCard)
/// ============================================================================
/// بطاقة تفاعلية تعرض تفاصيل مزود الشبكة وحالته التشغيلية وإجراءات الاعتماد/الرفض.
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

    // تحديد لون شارة الحالة
    late final Color statusBg;
    late final Color statusFg;

    if (network.isActive) {
      statusBg = colors.successContainer;
      statusFg = colors.success;
    } else if (network.isPending) {
      statusBg = colors.warningContainer;
      statusFg = colors.warning;
    } else if (network.isRejected) {
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
            // 1. ترويسة البطاقة: الشعار، الاسم، وشارة الحالة
            Row(
              children: [
                // أيقونة / شعار الشبكة
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.wifi_tethering_rounded,
                      color: colors.primary,
                      size: 24.r,
                    ),
                  ),
                ),
                AppSpacing.hSm,
                // اسم الشبكة والموقع
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
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              '${network.governorateName ?? ''} - ${network.directorateName ?? ''}',
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
                    network.statusLabel,
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

            // 2. تفاصيل المالك وجهات الاتصال
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
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (network.networkPhoneNumber != null &&
                    network.networkPhoneNumber!.isNotEmpty) ...[
                  Icon(
                    Icons.phone_outlined,
                    size: 14.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    network.networkPhoneNumber!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),

            AppSpacing.vXs,

            // 3. عدادات نقاط البيع والباقات
            Row(
              children: [
                _buildCountChip(
                  context,
                  icon: Icons.storefront_outlined,
                  label: '${network.posCount ?? 0} نقطة بيع',
                ),
                AppSpacing.hXs,
                _buildCountChip(
                  context,
                  icon: Icons.confirmation_number_outlined,
                  label: '${network.packagesCount ?? 0} باقة كروت',
                ),
              ],
            ),

            // 4. أزرار الإجراءات للطلبات قيد المراجعة
            if (network.isPending) ...[
              AppSpacing.vSm,
              Row(
                children: [
                  Expanded(
                    child: CustomButton.primary(
                      text: 'اعتماد الشبكة',
                      icon: Icons.check_rounded,
                      height: 38.h,
                      onPressed: () => controller.confirmApproveNetwork(network),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: colors.onSurfaceVariant),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
