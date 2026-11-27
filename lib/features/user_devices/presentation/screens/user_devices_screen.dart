import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/user_device_status.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/user_devices/presentation/controllers/user_devices_controller.dart';
import 'package:netsales/features/user_devices/presentation/widgets/user_device_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

/// شاشة الأجهزة المقترنة بأسلوب قيد — نقيّة عبر [GetView<UserDevicesController>].
class UserDevicesScreen extends GetView<UserDevicesController> {
  const UserDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'الأجهزة المقترنة',
      body: CustomRefreshablePage.slivers(
        onRefresh: controller.loadDevices,
        maxContentWidth: 720,
        scrollKey: const PageStorageKey<String>('user-devices-scroll'),
        slivers: [
          SliverToBoxAdapter(
            child: Obx(() {
              final filtered = controller.filteredDevices;
              final otherCount = controller.otherDevices.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomSearchFilterBar<UserDeviceStatus?>(
                    searchController: controller.searchController,
                    searchQuery: controller.searchQuery.value,
                    searchHint: 'ابحث باسم الجهاز أو المعرف أو النوع...',
                    onClearSearch: controller.clearSearch,
                    selectedFilter: controller.statusFilter.value,
                    filterOptions: controller.filterOptions,
                    onFilterChanged: controller.setStatusFilter,
                    kpiCards: controller.buildKpiCards(context),
                    selectedKpiKey: controller.statusFilter.value?.wireValue,
                    isKpiLoading:
                        controller.isLoading.value && controller.allDevices.isEmpty,
                    onKpiSelected: controller.onKpiSelected,
                    resultsCount: controller.isLoading.value &&
                            controller.allDevices.isEmpty
                        ? null
                        : filtered.length,
                    totalCount: controller.allDevices.length,
                    recordLabel: 'جهاز',
                    hasActiveFilters: controller.hasActiveFilters,
                    onClearAll: controller.clearFilters,
                  ),
                  if (otherCount > 0 && !controller.isLoading.value) ...[
                    AppSpacing.vSm,
                    CustomSurfaceCard(
                      padding: EdgeInsets.all(AppSpacing.md),
                      backgroundColor: colors.error.withValues(alpha: 0.05),
                      borderColor: colors.error.withValues(alpha: 0.25),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phonelink_erase_rounded,
                            color: colors.error,
                          ),
                          AppSpacing.hMd,
                          Expanded(
                            child: Text(
                              'لديك $otherCount أجهزة أخرى متصلة. يمكنك إنهاء جلساتها فوراً.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colors.onSurface),
                            ),
                          ),
                          AppSpacing.hSm,
                          CustomButton(
                            text: 'إنهاء الكل',
                            variant: AppButtonVariant.danger,
                            size: AppButtonSize.small,
                            loading: controller.isActionLoading.value,
                            onPressed: controller.logoutOtherDevices,
                          ),
                        ],
                      ),
                    ),
                  ],
                  AppSpacing.vMd,
                ],
              );
            }),
          ),
          Obx(() {
            if (controller.isLoading.value && controller.allDevices.isEmpty) {
              return const SliverToBoxAdapter(
                child: CustomStateView.loading(
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: CustomStateSkeleton(
                    layout: CustomStateSkeletonLayout.list,
                    itemCount: 3,
                    cardHeight: 118,
                    hasLeading: true,
                  ),
                ),
              );
            }

            if (controller.errorMessage.value != null &&
                controller.allDevices.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomErrorState(
                  title: 'تعذر تحميل الأجهزة المقترنة',
                  subtitle: controller.errorMessage.value,
                  onRetry: controller.loadDevices,
                ),
              );
            }

            final devices = controller.filteredDevices;
            if (devices.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomEmptyState.boxed(
                  icon: Icons.devices_other_rounded,
                  title: 'لا توجد أجهزة مطابقة',
                  subtitle: controller.hasActiveFilters
                      ? 'جرّب تعديل البحث أو مسح الفلاتر.'
                      : 'ستظهر هنا كافة أجهزتك المقترنة بحسابك.',
                ),
              );
            }

            return SliverList.separated(
              itemCount: devices.length,
              separatorBuilder: (_, _) => AppSpacing.vSm,
              itemBuilder: (_, index) {
                final device = devices[index];
                final isCurrent = controller.isCurrentDevice(device);
                return UserDeviceCard(
                  device: device,
                  isCurrent: isCurrent,
                  onTap: () => controller.openDeviceDetails(device),
                  onCopyUuid: () =>
                      controller.copyValue('المعرف الفريد', device.deviceUuid),
                  onDisconnect: isCurrent
                      ? null
                      : () => controller.disconnectDevice(device),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
