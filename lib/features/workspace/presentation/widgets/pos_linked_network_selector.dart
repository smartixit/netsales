import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/models/pos_linked_network_option_view_model.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class PosLinkedNetworkSelector extends StatelessWidget {
  const PosLinkedNetworkSelector({super.key, required this.controller});

  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      if (controller.isLoadingNetworks.value &&
          controller.networkLinks.isEmpty) {
        return CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 18.r,
                height: 18.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
              AppSpacing.hMd,
              Text(
                'جارٍ تحميل الشبكات المرتبطة',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      final error = controller.networksError.value;
      if (error != null && controller.networkLinks.isEmpty) {
        return CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                error,
                style: AppTypography.bodySmall.copyWith(color: colors.error),
              ),
              AppSpacing.vSm,
              CustomButton.text(
                text: 'إعادة المحاولة',
                onPressed: controller.retryNetworks,
              ),
            ],
          ),
        );
      }

      final activeLinks = controller.linkedNetworkOptions;

      if (activeLinks.isEmpty) {
        return const CustomEmptyState(
          icon: Icons.hub_outlined,
          title: 'لا توجد شبكة مرتبطة',
          subtitle: 'اربط نقطة البيع بشبكة مزودة أو تحقق من حالة الارتباط.',
        );
      }

      final selected = controller.selectedNetworkLink.value;
      return CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selected == null ? 'اختر الشبكة المورّدة' : 'الشبكة المورّدة',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (selected == null) ...[
              AppSpacing.vXs,
              Text(
                'لديك أكثر من شبكة مرتبطة. اختر الشبكة التي تريد عرض نشاطها.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            AppSpacing.vMd,
            _NetworkChoices(
              links: activeLinks,
              selectedNetworkPosId: selected?.networkPosId,
              onSelected: controller.selectNetworkLink,
            ),
            if (controller.hasMoreNetworks.value) ...[
              AppSpacing.vSm,
              CustomButton.text(
                text: 'تحميل المزيد من الشبكات',
                onPressed: controller.loadMoreNetworks,
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _NetworkChoices extends StatelessWidget {
  const _NetworkChoices({
    required this.links,
    required this.selectedNetworkPosId,
    required this.onSelected,
  });

  final List<PosLinkedNetworkOptionViewModel> links;
  final int? selectedNetworkPosId;
  final Future<void> Function(int networkPosId) onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final link in links)
          CustomInteractiveBounce(
            onTap: () => onSelected(link.networkPosId),
            child: Container(
              constraints: BoxConstraints(maxWidth: 240.w),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: link.networkPosId == selectedNetworkPosId
                    ? colors.primary.withValues(alpha: 0.12)
                    : colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: link.networkId == selectedId
                      ? colors.primary
                      : colors.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    link.networkId == selectedId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16.r,
                    color: link.networkId == selectedId
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                  AppSpacing.hSm,
                  Flexible(
                    child: Text(
                      link.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: link.networkId == selectedId
                            ? FontWeight.bold
                            : FontWeight.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
