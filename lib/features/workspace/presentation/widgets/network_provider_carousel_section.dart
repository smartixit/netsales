import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/executive_network_card.dart';
import 'package:netsales/widgets/carousels/custom_carousel_slider.dart';

/// قسم كاروسيل بطاقات الشبكات التابعة للمزود (NetworkProviderCarouselSection)
class NetworkProviderCarouselSection extends StatelessWidget {
  final NetworkWorkspaceController controller;

  const NetworkProviderCarouselSection({
    super.key,
    required this.controller,
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
        ),
        AppSpacing.vSm,
        CustomCarouselSlider<NetworkEntity>(
          items: networks,
          currentIndex: networks
              .indexWhere((n) => n.networkId == selectedId)
              .clamp(0, networks.length - 1),
          height: 205,
          viewportFraction: 0.88,
          itemBuilder: (context, network, index) {
            final isSelected = network.networkId == selectedId;
            final salesValue = controller.formatNetworkSales(network, isSelected);
            final posCount = controller.formatNetworkPosCount(network, isSelected);

            return ExecutiveNetworkCard(
              network: network,
              isSelected: isSelected,
              cardIndex: index,
              salesValue: salesValue,
              posCountText: posCount,
              onTap: () => controller.selectNetwork(network.networkId),
            );
          },
          onPageChanged: (index) {
            if (index >= 0 && index < networks.length) {
              controller.selectNetwork(networks[index].networkId);
            }
          },
        ),
      ],
    );
  }
}
