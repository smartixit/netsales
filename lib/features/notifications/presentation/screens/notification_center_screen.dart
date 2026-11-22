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
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// شاشة مركز الإشعارات والتنبيهات الموجهة داخل التطبيق (NotificationCenterScreen - VIP)
///
/// صُممت الشاشة وفق المعيار الهندسي الأعلى:
/// - مبنية بنمط [CustomRefreshablePage.slivers] الموحد لجميع شاشات المنظومة مع مطابقة هوامش الشاشة المركزية بالكامل.
/// - تجميع عناصر التحكم العلوية (المؤشرات، البحث والتصفية، وعداد النتائج) في شريحة موحدة.
/// - ظهور حالة التحميل [CustomStateView.loading] بالهيكل الشبحي فوراً عند الفلترة أو البحث أو التحديث.
/// - استخدام [CustomCursorLoadMore] القياسي في ذيل القائمة للترقيم اللانهائي.
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
              padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
              child: CustomButton.icon(
                icon: Icons.done_all_rounded,
                tooltip: 'تعليم الكل كمقروء',
                size: AppButtonSize.small,
                foregroundColor: colors.primary,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
                loading: controller.isMarkingAllRead.value,
                onPressed: controller.markAllAsRead,
              ),
            );
          }),
        ],
      ),
      body: CustomRefreshablePage.slivers(
        onRefresh: () => controller.loadInitialData(),
        onLoadMore: controller.loadMoreNotifications,
        hasMorePredicate: () =>
            controller.hasMore && !controller.isLoadingMore.value,
        slivers: [
          // 1. ترويسة الصفحة الموحدة: المؤشرات الحيوية، البحث والتصفية، وعداد النتائج
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NotificationKpiStrip(),
                SizedBox(height: AppSpacing.xs),
                const NotificationSearchFilterBar(),
                SizedBox(height: AppSpacing.xs),
                Obx(
                  () => CustomResultsCounterBar(
                    count: controller.filteredNotifications.length,
                    recordLabel: 'إشعار',
                    isFiltered:
                        controller.searchQuery.value.isNotEmpty ||
                        controller.selectedFilter.value != null ||
                        controller.selectedCategory.value != null,
                    isLoading: controller.isLoading.value,
                    onClear: controller.resetFilters,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),

          // 2. منطقة المحتوى: حالات التحميل والخطأ والفراغ أو عناصر الإشعارات
          Obx(() {
            // إظهار هيكل التحميل الموحد عند أي عملية جلب أو فلترة أو بحث
            if (controller.isLoading.value) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CustomStateView.loading(
                    presentation: CustomStatePresentation.skeletonOnly,
                    skeleton: CustomStateSkeleton(
                      layout: CustomStateSkeletonLayout.list,
                      itemCount: 4,
                      cardHeight: 120,
                      maxColumns: 1,
                      hasLeading: true,
                    ),
                  ),
                ),
              );
            }

            if (controller.errorMessage.value != null &&
                controller.notifications.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomErrorState(
                  title: 'تعذر تحميل الإشعارات',
                  subtitle: controller.errorMessage.value,
                  onRetry: () => controller.loadNotifications(isRefresh: true),
                ),
              );
            }

            if (controller.filteredNotifications.isEmpty) {
              final isSearching = controller.searchQuery.value
                  .trim()
                  .isNotEmpty;
              final isFiltering =
                  controller.selectedFilter.value != null ||
                  controller.selectedCategory.value != null;

              if (isSearching) {
                return SliverToBoxAdapter(
                  child: CustomEmptyState.search(
                    query: controller.searchQuery.value.trim(),
                    onClearSearch: controller.resetFilters,
                  ),
                );
              }

              if (isFiltering) {
                return SliverToBoxAdapter(
                  child: CustomEmptyState(
                    icon: Icons.filter_alt_off_rounded,
                    title: 'لا توجد إشعارات مطابقة للتصفية',
                    subtitle: 'جرّب تغيير فئة الإشعارات المحددة أو تصفية حالة القراءة.',
                    actionLabel: 'إعادة تعيين الفلاتر',
                    actionIcon: Icons.refresh_rounded,
                    onAction: controller.resetFilters,
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: CustomEmptyState(
                  title: 'لا توجد إشعارات',
                  subtitle: 'سوف تظهر هنا كافة التنبيهات وإشعارات العمليات فور ورودها.',
                  icon: Icons.notifications_none_rounded,
                  actionLabel: 'تحديث القائمة',
                  actionIcon: Icons.refresh_rounded,
                  onAction: () => controller.loadNotifications(isRefresh: true),
                ),
              );
            }

            final items = controller.filteredNotifications;

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return NotificationItemCard(
                  key: ValueKey('notification_${item.notificationId}'),
                  notification: item,
                  onTap: () => controller.onNotificationTap(item),
                  onMarkAsRead: () => controller.markAsRead(item),
                );
              }, childCount: items.length),
            );
          }),

          // 3. ذيل التحميل الإضافي الموحد (CustomCursorLoadMore)
          SliverToBoxAdapter(
            child: Obx(
              () => CustomCursorLoadMore(
                hasMore: controller.hasMore,
                isLoading: controller.isLoadingMore.value,
                error: null,
                onPressed: controller.loadMoreNotifications,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
