import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';

/// Compact supplier-network selector. Selection rules remain in the controller:
/// a single active link may be selected automatically, multiple links require
/// an explicit choice, and the saved relationship is preserved.
class PosLinkedNetworkSelector extends StatelessWidget {
  const PosLinkedNetworkSelector({super.key, required this.controller});

  final PosWorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingNetworks.value &&
          controller.linkedNetworkOptions.isEmpty) {
        return CustomSurfaceCard(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 17.r,
                height: 17.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
              AppSpacing.hSm,
              Text(
                'جارٍ تحميل شبكات التوريد',
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

      final selectedId = controller.selectedNetworkPosId;
      final selected = activeLinks.firstWhereOrNull(
        (link) => link.networkPosId == selectedId,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              children: [
                Icon(Icons.hub_rounded, color: colors.primary, size: 19.r),
                AppSpacing.hSm,
                Text(
                  'شبكة التوريد',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vXs,
          CustomPopupMenu<int>(
            enabled: activeLinks.length > 1,
            minWidth: 220.w,
            trigger: Container(
              constraints: BoxConstraints(minHeight: 48.h),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.035),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_tree_rounded,
                    color: colors.primary,
                    size: 18.r,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      selected?.displayName ?? 'اختر شبكة التوريد',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onSurfaceVariant,
                    size: 21.r,
                  ),
                ],
              ),
            ),
            items: activeLinks
                .map(
                  (link) => CustomPopupItem<int>(
                    value: link.networkPosId,
                    label: link.displayName,
                    icon: Icons.hub_outlined,
                    trailing: link.networkPosId == selectedId
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: colors.primary,
                            size: 17.r,
                          )
                        : null,
                  ),
                )
                .toList(growable: false),
            onSelected: controller.selectNetworkLink,
          ),
          if (controller.hasMoreNetworks.value) ...[
            AppSpacing.vXs,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CustomButton.text(
                text: 'تحميل المزيد من الشبكات',
                onPressed: controller.loadMoreNetworks,
              ),
            ),
          ],
        ],
      );
    });
  }
}
