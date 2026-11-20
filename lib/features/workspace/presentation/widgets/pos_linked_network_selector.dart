import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// Explicit selector for the supplier network linked to the active POS.
class PosLinkedNetworkSelector extends StatelessWidget {
  const PosLinkedNetworkSelector({super.key, required this.controller});

  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      if (controller.isLoadingNetworks.value && controller.networkLinks.isEmpty) {
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
              TextButton(
                onPressed: controller.retryNetworks,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
      }

      final activeLinks = controller.networkLinks
          .where((link) => link.status)
          .toList(growable: false);

      if (activeLinks.isEmpty) {
        return const CustomEmptyState(
          icon: Icons.hub_outlined,
          title: 'لا توجد شبكة مرتبطة',
          subtitle: 'اربط نقطة البيع بشبكة مزودة أو تحقق من حالة الارتباط.',
        );
      }

      if (controller.selectedNetworkLink.value == null) {
        return CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر الشبكة المورّدة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vSm,
              Text(
                'لديك أكثر من شبكة مرتبطة. اختر الشبكة التي تريد عرض طلباتها وفواتيرها.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              AppSpacing.vMd,
              _NetworkChoices(
                links: activeLinks,
                selectedId: null,
                onSelected: controller.selectNetwork,
              ),
            ],
          ),
        );
      }

      return CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الشبكة المورّدة',
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            AppSpacing.vXs,
            _NetworkChoices(
              links: activeLinks,
              selectedId: controller.selectedNetworkLink.value!.networkId,
              onSelected: controller.selectNetwork,
            ),
          ],
        ),
      );
    });
  }
}

class _NetworkChoices extends StatelessWidget {
  const _NetworkChoices({
    required this.links,
    required this.selectedId,
    required this.onSelected,
  });

  final List links;
  final int? selectedId;
  final Future<void> Function(dynamic link, {int? index, bool forceRefresh}) onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var index = 0; index < links.length; index++)
          Builder(
            builder: (context) {
              final link = links[index];
              final selected = link.networkId == selectedId;
              return CustomInteractiveBounce(
                onTap: () => onSelected(link, index: index),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 240.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: selected ? colors.primary : colors.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        size: 16.r,
                        color: selected ? colors.primary : colors.onSurfaceVariant,
                      ),
                      AppSpacing.hSm,
                      Flexible(
                        child: Text(
                          link.displayNetworkName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: selected ? FontWeight.bold : FontWeight.medium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
