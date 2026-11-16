import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_coordinator_controller.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_entity_picker_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_network_picker_tile.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_pos_picker_tile.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// النافذة السفلية لاختيار وتبديل الشبكات ونقاط البيع المرتبطة بالمستخدم (WorkspaceEntityPickerSheet)
class WorkspaceEntityPickerSheet extends StatelessWidget {
  final AppWorkspace currentWorkspace;

  const WorkspaceEntityPickerSheet({super.key, required this.currentWorkspace});

  /// يعرض نافذة اختيار الكيان؛ تحميل البيانات وتهيئة الحالة مسؤولية Controller.
  static Future<void> show(
    BuildContext context, {
    required AppWorkspace currentWorkspace,
  }) {
    return CustomBottomSheet.show<void>(
      title: 'الكيانات ومساحات العمل',
      subtitle: 'اختر الشبكة أو نقطة البيع للتنقل الفوري للعمليات',
      leadingIcon: Icons.hub_rounded,
      child: WorkspaceEntityPickerSheet(currentWorkspace: currentWorkspace),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = WorkspaceEntityPickerController.to;
    final coordinator = Get.isRegistered<WorkspaceCoordinatorController>()
        ? WorkspaceCoordinatorController.to
        : null;

    return Obx(() {
      final isLoading = controller.isLoading.value;
      final errorMessage = controller.errorMessage.value;
      final networks = controller.networks;
      final pointsOfSale = controller.pointsOfSale;
      final activeNetId = controller.activeNetworkId;
      final activePosId = controller.activePosId;
      final currentSegment = controller.selectedSegment.value;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط التبديل التفاعلي الموحد (CustomSegmentedBar)
          CustomSegmentedBar(
            selectedIndex: currentSegment,
            onSegmentChanged: (idx) => controller.selectedSegment.value = idx,
            items: [
              CustomSegmentItem(
                label: 'شبكاتك',
                count: isLoading && networks.isEmpty ? 0 : networks.length,
                icon: Icons.hub_rounded,
              ),
              CustomSegmentItem(
                label: 'نقاط البيع',
                count:
                    isLoading && pointsOfSale.isEmpty
                        ? 0
                        : pointsOfSale.length,
                icon: Icons.storefront_rounded,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          // قائمة الكيانات المعروضة مع Skeleton Shimmer فوري عند التحميل
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 340.h),
            child: SingleChildScrollView(
              child:
                  isLoading
                      ? Column(
                          children: [
                            const CustomSkeletonCard(height: 72),
                            SizedBox(height: AppSpacing.sm),
                            const CustomSkeletonCard(height: 72),
                            SizedBox(height: AppSpacing.sm),
                            const CustomSkeletonCard(height: 72),
                          ],
                        )
                  : errorMessage != null &&
                        networks.isEmpty &&
                        pointsOfSale.isEmpty
                  ? CustomEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'تعذر تحميل البيانات',
                      subtitle: errorMessage,
                    )
                  : currentSegment == 0
                  ? (networks.isEmpty
                        ? const CustomEmptyState(
                            icon: Icons.hub_outlined,
                            title: 'لا توجد شبكات مرتبطة بالحساب',
                            subtitle:
                                'لم يتم العثور على شبكات مسجلة لهذا الحساب.',
                          )
                        : Column(
                            children: networks.map((network) {
                              final isSelected =
                                  currentWorkspace == AppWorkspace.network &&
                                  network.networkId == activeNetId;
                              return WorkspaceNetworkPickerTile(
                                network: network,
                                isSelected: isSelected,
                                onTap: () => controller.selectNetwork(network),
                              );
                            }).toList(),
                          ))
                  : (pointsOfSale.isEmpty
                        ? const CustomEmptyState(
                            icon: Icons.storefront_outlined,
                            title: 'لا توجد نقاط بيع مرتبطة بالحساب',
                            subtitle: 'لم يتم العثور على نقاط بيع مصرح بها لهذا الحساب.',
                          )
                        : Column(
                            children: pointsOfSale.map((pos) {
                              final isSelected =
                                  currentWorkspace == AppWorkspace.pos &&
                                  pos.posId == activePosId;
                              return WorkspacePosPickerTile(
                                pos: pos,
                                isSelected: isSelected,
                                onTap: () => controller.selectPos(pos),
                              );
                            }).toList(),
                          )),
            ),
          ),

          // زر التبديل المباشر بين مساحتي العمل إذا كان مصرحاً له
          if (coordinator != null && coordinator.canSwitchWorkspace) ...[
            SizedBox(height: AppSpacing.sm),
            Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : colors.outlineVariant,
            ),
            SizedBox(height: AppSpacing.xs),
            CustomInteractiveBounce(
              onTap: () {
                Get.back<void>();
                coordinator.toggleWorkspace();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF131D2E)
                      : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 18.r,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تبديل مساحة العمل الحالية',
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            coordinator.switchWorkspaceTooltip,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13.r,
                      color: colors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
