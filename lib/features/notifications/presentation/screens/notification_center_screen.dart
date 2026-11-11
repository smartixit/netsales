import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:netsales/widgets/badges/custom_filter_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شاشة مركز الإشعارات والتنبيهات الموجهة داخل التطبيق (NotificationCenterScreen)
class NotificationCenterScreen extends GetView<NotificationController> {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(
        title: Text(
          'مركز الإشعارات',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
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
          // شريط البحث وفلاتر التصفية
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                CustomTextField(
                  controller: controller.searchController,
                  hint: 'بحث في الإشعارات...',
                  prefixIcon: Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? CustomButton.icon(
                          icon: Icons.clear_rounded,
                          iconSize: 18,
                          dimension: 36,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                          onPressed: () {
                            controller.searchController.clear();
                          },
                        )
                      : null,
                  label: 'بحث في الإشعارات...',
                ),
                SizedBox(height: AppSpacing.sm),
                Obx(() {
                  final activeFilter = controller.selectedFilter.value;
                  return Row(
                    children: [
                      CustomFilterChip(
                        label: 'الكل',
                        isSelected: activeFilter == null,
                        onSelected: () => controller.setFilter(null),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      CustomFilterChip(
                        label: 'غير المقروءة',
                        isSelected: activeFilter == false,
                        count: controller.unreadCount.value > 0
                            ? controller.unreadCount.value
                            : null,
                        onSelected: () => controller.setFilter(false),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      CustomFilterChip(
                        label: 'المقروءة',
                        isSelected: activeFilter == true,
                        onSelected: () => controller.setFilter(true),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // قائمة الإشعارات وحالات التحميل والخطأ والفراغ
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const CustomSkeletonFeed();
              }

              if (controller.errorMessage.value != null &&
                  controller.notifications.isEmpty) {
                return CustomErrorState(
                  title: controller.errorMessage.value!,
                  onRetry: () => controller.loadNotifications(isRefresh: true),
                );
              }

              if (controller.notifications.isEmpty) {
                return CustomEmptyState(
                  title: 'لا توجد إشعارات',
                  subtitle: controller.selectedFilter.value == false
                      ? 'لا توجد أي إشعارات غير مقروءة في الوقت الحالي.'
                      : 'سوف تظهر هنا كافة التنبيهات وإشعارات العمليات فور ورودها.',
                  icon: Icons.notifications_none_rounded,
                  actionLabel: 'تحديث',
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
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    itemCount:
                        controller.notifications.length +
                        (controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.notifications.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          child: CustomSkeletonCard(height: 72.h),
                        );
                      }

                      final item = controller.notifications[index];
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
