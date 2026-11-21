import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_kpi_strip.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_search_filter_bar.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';

/// شاشة مركز الإشعارات والتنبيهات الموجهة داخل التطبيق (NotificationCenterScreen - VIP)
///
/// صُممت الشاشة وفق المعيار الهندسي الأعلى:
/// - ملف تركيبي صفحة (Page-Level Composition) لا يتجاوز 160 سطراً.
/// - خالٍ تماماً من دوال البناء الخاصة (_buildXxx Helpers) والفئات المضمنة.
/// - شريط مؤشرات تنفيذية VIP في المقدمة، يعقبه شريط بحث وتصفية متكامل.
/// - حالات تفاعلية قياسية (CustomStateView, CustomEmptyState, CustomErrorState).
/// - عزل واستدعاء سلس لعناصر القائمة عبر بطاقة [NotificationItemCard] مع التحميل التدريجي.
class NotificationCenterScreen extends GetView<NotificationController> {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'مركز الإشعارات',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            Obx(() {
              final unread = controller.unreadCount.value;
              if (unread <= 0) return const SizedBox.shrink();
              return Container(
                margin: EdgeInsetsDirectional.only(start: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  unread > 99 ? '99+' : unread.toString(),
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          Obx(() {
            final hasUnread =
                controller.unreadCount.value > 0 ||
                controller.notifications.any((n) => !n.isRead);

            if (!hasUnread) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: CustomButton.text(
                text: 'تعليم الكل كمقروء',
                loading: controller.isMarkingAllRead.value,
                foregroundColor: colors.primary,
                onPressed: controller.markAllAsRead,
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // 1. شريط المؤشرات الحيوية التنفيذية (KPIs)
          const NotificationKpiStrip(),

          // 2. شريط البحث المباشر وشرائح التصفية
          const NotificationSearchFilterBar(),

          // 3. شريط عداد النتائج والتصفية الموحد
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Obx(
              () => CustomResultsCounterBar(
                count: controller.filteredNotifications.length,
                recordLabel: 'إشعار',
                isFiltered:
                    controller.searchQuery.value.isNotEmpty ||
                    controller.selectedFilter.value != null ||
                    controller.selectedCategory.value != null,
                isLoading:
                    controller.isLoading.value &&
                    controller.notifications.isEmpty,
                onClear: controller.resetFilters,
              ),
            ),
          ),

          // 4. منطقة المحتوى وحالات العرض القياسية
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const CustomStateView.loading(
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: CustomStateSkeleton(
                    layout: CustomStateSkeletonLayout.list,
                    itemCount: 4,
                    cardHeight: 120,
                  ),
                );
              }

              if (controller.errorMessage.value != null &&
                  controller.notifications.isEmpty) {
                return CustomErrorState(
                  title: controller.errorMessage.value!,
                  onRetry: () => controller.loadNotifications(isRefresh: true),
                );
              }

              if (controller.filteredNotifications.isEmpty) {
                return CustomEmptyState(
                  title: 'لا توجد إشعارات',
                  subtitle: controller.selectedFilter.value == false
                      ? 'لا توجد أي إشعارات غير مقروءة في الوقت الحالي.'
                      : 'سوف تظهر هنا كافة التنبيهات وإشعارات العمليات فور ورودها.',
                  icon: Icons.notifications_none_rounded,
                  actionLabel: 'تحديث القائمة',
                  onAction: () => controller.loadNotifications(isRefresh: true),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadInitialData(),
                color: colors.primary,
                backgroundColor: colors.surface,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200 &&
                        controller.hasMore &&
                        !controller.isLoadingMore.value) {
                      controller.loadMoreNotifications();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    itemCount:
                        controller.filteredNotifications.length +
                        (controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.filteredNotifications.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          child: CustomStateView.loading(
                            presentation: CustomStatePresentation.skeletonOnly,
                            skeleton: CustomStateSkeleton(
                              layout: CustomStateSkeletonLayout.cards,
                              itemCount: 1,
                              cardHeight: 80.h,
                              maxColumns: 1,
                              minItemWidth: 180,
                            ),
                          ),
                        );
                      }

                      final item = controller.filteredNotifications[index];
                      return NotificationItemCard(
                        notification: item,
                        onTap: () => controller.onNotificationTap(item),
                        onMarkAsRead: () => controller.markAsRead(item),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
