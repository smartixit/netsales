import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_network_carousel_card.dart';
import 'package:netsales/widgets/carousels/custom_carousel_slider.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// قسم كاروسيل بطاقات الشبكات المرتبطة بنقطة البيع (PosConnectedNetworksCarouselSection)
/// متطابق هندسياً ومعمارياً مع قسم NetworkProviderCarouselSection في مساحة الشبكة
class PosConnectedNetworksCarouselSection extends StatelessWidget {
  final PosWorkspaceController controller;
  final VoidCallback onLinkNetwork;

  const PosConnectedNetworksCarouselSection({
    super.key,
    required this.controller,
    required this.onLinkNetwork,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.hub_rounded, color: colors.primary, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'شبكاتك المرتبطة',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomInteractiveBounce(
                    onTap: onLinkNetwork,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.35),
                          width: 0.9,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 14.r,
                            color: colors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'ربط شبكة +',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.networkLinks.isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '${controller.networkLinks.length}${controller.hasMoreNetworks.value ? '+' : ''} شبكة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vMd,
        if (controller.isLoadingNetworks.value)
          const CustomSkeletonCard(height: 190)
        else if (controller.networksError.value != null)
          CustomErrorState.boxed(
            title: 'تعذر تحميل الشبكات',
            subtitle: 'لم نتمكن من جلب علاقات نقطة البيع.',
            onRetry: controller.retryNetworks,
          )
        else if (controller.networkLinks.isEmpty)
          CustomEmptyState.boxed(
            title: 'لا توجد شبكات مرتبطة حالياً',
            subtitle:
                'اربط نقطة البيع بمزود شبكة عبر مسح رمز QR لبدء طلب باقات الكروت فورياً.',
            icon: Icons.hub_outlined,
            actionLabel: 'مسح رمز QR للربط',
            actionIcon: Icons.qr_code_scanner_rounded,
            onAction: onLinkNetwork,
          )
        else
          CustomCarouselSlider<NetworkPosLinkEntity>(
            items: controller.networkLinks,
            currentIndex: controller.currentNetworkIndex.value,
            height: 205,
            viewportFraction: 0.88,
            itemBuilder: (context, link, index) => PosNetworkCarouselCard(
              link: link,
              cardIndex: index,
              isSelected:
                  controller.selectedNetworkLink.value?.networkId ==
                  link.networkId,
              wallet:
                  controller.selectedNetworkLink.value?.networkId ==
                          link.networkId
                      ? controller.selectedWallet.value
                      : null,
              onTap: () => controller.onNetworkPageChanged(index),
            ),
            onPageChanged: controller.onNetworkPageChanged,
          ),
      ],
    );
  }
}
