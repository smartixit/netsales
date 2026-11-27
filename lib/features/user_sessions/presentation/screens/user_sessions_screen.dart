import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/features/user_sessions/presentation/controllers/user_sessions_controller.dart';
import 'package:netsales/features/user_sessions/presentation/widgets/user_session_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

/// شاشة جلسات تسجيل الدخول بأسلوب قيد — نقيّة عبر [GetView<UserSessionsController>].
class UserSessionsScreen extends GetView<UserSessionsController> {
  const UserSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      showBackButton: true,
      appBarTitle: 'جلسات تسجيل الدخول',
      body: CustomRefreshablePage.slivers(
        onRefresh: controller.loadSessions,
        maxContentWidth: 720,
        scrollKey: const PageStorageKey<String>('user-sessions-scroll'),
        slivers: [
          SliverToBoxAdapter(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomSearchFilterBar<UserSessionStatus?>(
                    searchController: controller.searchController,
                    searchQuery: controller.searchQuery.value,
                    searchHint: 'ابحث بعنوان IP أو معلومات الجهاز...',
                    onClearSearch: controller.clearSearch,
                    selectedFilter: controller.statusFilter.value,
                    filterOptions: controller.filterOptions,
                    onFilterChanged: controller.setStatusFilter,
                    kpiCards: controller.buildKpiCards(context),
                    selectedKpiKey: controller.statusFilter.value?.wireValue,
                    isKpiLoading:
                        controller.isLoading.value && controller.sessions.isEmpty,
                    onKpiSelected: controller.onKpiSelected,
                    resultsCount: controller.isLoading.value &&
                            controller.sessions.isEmpty
                        ? null
                        : controller.sessions.length,
                    recordLabel: 'جلسة',
                    hasActiveFilters: controller.hasActiveFilters,
                    onClearAll: controller.clearFilters,
                  ),
                  AppSpacing.vMd,
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoading.value && controller.sessions.isEmpty) {
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
                controller.sessions.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomErrorState(
                  title: 'تعذر تحميل جلسات الدخول',
                  subtitle: controller.errorMessage.value,
                  onRetry: controller.loadSessions,
                ),
              );
            }

            final items = controller.sessions;
            if (items.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomEmptyState.boxed(
                  icon: Icons.sensors_off_rounded,
                  title: 'لا توجد جلسات مطابقة',
                  subtitle: controller.hasActiveFilters
                      ? 'جرّب تعديل البحث أو مسح الفلاتر.'
                      : 'ستظهر هنا كافة جلسات تسجيل الدخول الخاصة بحسابك.',
                ),
              );
            }

            return SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => AppSpacing.vSm,
              itemBuilder: (_, index) {
                final session = items[index];
                return UserSessionCard(
                  session: session,
                  onTap: () => controller.openSessionDetails(session),
                  onCopyIp: (session.ipAddress?.trim().isNotEmpty == true)
                      ? () =>
                          controller.copyValue('عنوان IP', session.ipAddress!)
                      : null,
                  onTerminate: (!session.isCurrent && session.isActive)
                      ? () => controller.terminateSession(session)
                      : null,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
