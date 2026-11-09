import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/membership/presentation/controllers/membership_controller.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_add_form.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_list.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class MembershipScreen extends GetView<MembershipController> {
  const MembershipScreen({super.key});
  @override
  Widget build(BuildContext context) => Obx(() {
    final tenants = controller.isNetwork
        ? controller.networks
        : controller.positions;
    final tenantItems = controller.isNetwork
        ? controller.networks
              .map(
                (e) => DropdownItem<int>(
                  value: e.networkId,
                  child: Text(e.networkName),
                ),
              )
              .toList()
        : controller.positions
              .map(
                (e) =>
                    DropdownItem<int>(value: e.posId, child: Text(e.posName)),
              )
              .toList();
    if (controller.isLoadingTenants.value) {
      return const CustomSkeletonFeed(itemCount: 3);
    }
    if (controller.errorMessage.value != null && tenants.isEmpty) {
      return CustomErrorState(
        title: 'تعذر تحميل البيانات',
        subtitle: controller.errorMessage.value,
        onRetry: controller.loadTenants,
      );
    }
    if (tenants.isEmpty) {
      return const CustomEmptyState(
        title: 'لا توجد منشآت متاحة',
        subtitle: 'لا توجد شبكة أو نقطة بيع مرتبطة بحسابك لإدارة أعضائها.',
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              controller.isNetwork ? 'فريق الشبكة' : 'فريق نقطة البيع',
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.vXs,
            Text(
              'إدارة العضويات التشغيلية والصلاحيات داخل الشبكة المحددة.',
              style: AppTypography.bodyMedium,
            ),
            if (tenants.length > 1) ...[
              AppSpacing.vMd,
              CustomDropdown<int>(
                items: tenantItems,
                rxValue: controller.selectedTenantId,
                onChanged: controller.selectTenant,
                label: controller.tenantLabel,
                hint: 'اختر ${controller.tenantLabel}',
              ),
            ],
            AppSpacing.vLg,
            if (controller.selectedTenantId.value == null)
              const CustomEmptyState(
                title: 'حدد الشبكة أولاً',
                subtitle: 'اختر الشبكة أو نقطة البيع التي تريد إدارة فريقها.',
              )
            else ...[
              MembershipAddForm(controller: controller),
              AppSpacing.vLg,
            ],
            if (controller.selectedTenantId.value != null &&
                controller.isLoading.value)
              const CustomSkeletonFeed(itemCount: 4)
            else if (controller.selectedTenantId.value != null &&
                controller.errorMessage.value != null)
              CustomErrorState.boxed(
                title: 'تعذر تحميل الأعضاء',
                subtitle: controller.errorMessage.value,
                onRetry: controller.loadMembers,
              )
            else if (controller.selectedTenantId.value != null &&
                controller.members.isEmpty)
              const CustomEmptyState(
                title: 'لا يوجد أعضاء بعد',
                subtitle: 'أضف أول عضو تشغيلي إلى هذه الشبكة.',
              )
            else if (controller.selectedTenantId.value != null)
              MembershipList(controller: controller),
          ],
        ),
      ),
    );
  });
}
