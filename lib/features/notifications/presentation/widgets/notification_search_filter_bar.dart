import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/widgets/badges/custom_filter_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شريط البحث والتصفية المتقدم لمركز الإشعارات (NotificationSearchFilterBar)
///
/// يدمج حقل البحث اللحظي مع شرائح تصفية حالة القراءة وتصنيفات الدومين.
class NotificationSearchFilterBar extends StatelessWidget {
  const NotificationSearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = NotificationController.to;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── حقل البحث ──
          Obx(
            () => CustomTextField(
              controller: controller.searchController,
              hint: 'بحث في الإشعارات والتنبيهات...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.searchQuery.value.isNotEmpty
                  ? CustomButton.icon(
                      icon: Icons.clear_rounded,
                      iconSize: 18,
                      dimension: 36,
                      backgroundColor: Colors.transparent,
                      foregroundColor: colors.onSurfaceVariant,
                      onPressed: () {
                        controller.searchController.clear();
                      },
                    )
                  : null,
              label: 'بحث في الإشعارات...',
            ),
          ),

          SizedBox(height: 8.h),

          // ── شرائح التصفية الأفقية ──
          Obx(() {
            final activeReadFilter = controller.selectedFilter.value;
            final activeCategory = controller.selectedCategory.value;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // حالة القراءة
                  CustomFilterChip(
                    label: 'الكل',
                    isSelected:
                        activeReadFilter == null && activeCategory == null,
                    onSelected: controller.resetFilters,
                  ),
                  SizedBox(width: 6.w),
                  CustomFilterChip(
                    label: 'غير المقروءة',
                    isSelected: activeReadFilter == false,
                    count: controller.unreadCount.value > 0
                        ? controller.unreadCount.value
                        : null,
                    onSelected: () => controller.setFilter(false),
                  ),
                  SizedBox(width: 6.w),
                  CustomFilterChip(
                    label: 'المقروءة',
                    isSelected: activeReadFilter == true,
                    onSelected: () => controller.setFilter(true),
                  ),

                  // فاصل عمودي ناعم
                  Container(
                    width: 1,
                    height: 20.h,
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),

                  // تصنيفات الدومين
                  CustomFilterChip(
                    label: 'مالية',
                    isSelected: activeCategory == 'FINANCIAL',
                    onSelected: () => controller.setCategory('FINANCIAL'),
                  ),
                  SizedBox(width: 6.w),
                  CustomFilterChip(
                    label: 'عمليات',
                    isSelected: activeCategory == 'OPERATIONAL',
                    onSelected: () => controller.setCategory('OPERATIONAL'),
                  ),
                  SizedBox(width: 6.w),
                  CustomFilterChip(
                    label: 'أمان',
                    isSelected: activeCategory == 'SECURITY',
                    onSelected: () => controller.setCategory('SECURITY'),
                  ),
                  SizedBox(width: 6.w),
                  CustomFilterChip(
                    label: 'دعم فني',
                    isSelected: activeCategory == 'SUPPORT',
                    onSelected: () => controller.setCategory('SUPPORT'),
                  ),
                  SizedBox(width: 6.w),
                  CustomFilterChip(
                    label: 'النظام',
                    isSelected: activeCategory == 'SYSTEM',
                    onSelected: () => controller.setCategory('SYSTEM'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
