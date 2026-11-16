import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/models/network_provider_card_view_model.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_network_card.dart';
import 'package:netsales/widgets/carousels/custom_carousel_slider.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// قسم كاروسيل بطاقات الشبكات التابعة للمزود (NetworkProviderCarouselSection)
class NetworkProviderCarouselSection extends StatelessWidget {
  final NetworkWorkspaceController controller;
  final VoidCallback onInvitePos;

  const NetworkProviderCarouselSection({
    super.key,
    required this.controller,
    required this.onInvitePos,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final networks = controller.networks;
    final selectedId = controller.selectedNetworkId.value;

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
                    'الشبكات التابعة لحسابك',
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
                    onTap: onInvitePos,
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
                            Icons.qr_code_2_rounded,
                            size: 14.r,
                            color: colors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'دعوة QR +',
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
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${networks.length} شبكات',
                      style: AppTypography.badgeText.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vSm,
        CustomCarouselSlider<NetworkProviderCardViewModel>(
          items: controller.providerCards,
          currentIndex: networks
              .indexWhere((n) => n.networkId == selectedId)
              .clamp(0, networks.length - 1),
          height: 205,
          viewportFraction: 0.88,
          itemBuilder: (context, item, index) => ExecutiveNetworkCard(
            item: item,
            onTap: () => controller.selectNetwork(item.networkId),
          ),
          onPageChanged: (index) {
            if (index >= 0 && index < networks.length) {
              controller.selectNetwork(
                controller.providerCards[index].networkId,
              );
            }
          },
        ),
      ],
    );
  }
}
