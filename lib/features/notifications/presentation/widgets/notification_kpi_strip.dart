import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_kpi_card.dart';

/// شريط المؤشرات التنفيذية لمركز الإشعارات (NotificationKpiStrip)
///
/// يعرض شريطاً أفقياً تفاعلياً بالمؤشرات الحيوية (الإجمالي، غير المقروء، مالية، أمان).
class NotificationKpiStrip extends StatelessWidget {
  const NotificationKpiStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final controller = NotificationController.to;

    return Obx(() {
      final isAllSelected =
          controller.selectedFilter.value == null &&
          controller.selectedCategory.value == null;
      final isUnreadSelected = controller.selectedFilter.value == false;
      final isFinancialSelected =
          controller.selectedCategory.value == 'FINANCIAL';
      final isSecuritySelected =
          controller.selectedCategory.value == 'SECURITY';

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            NotificationKpiCard(
              title: 'الإجمالي',
              count: controller.totalCount,
              icon: Icons.all_inbox_rounded,
              color: colors.primary,
              isSelected: isAllSelected,
              onTap: controller.resetFilters,
            ),
            SizedBox(width: 8.w),
            NotificationKpiCard(
              title: 'غير مقروء',
              count: controller.unreadCount.value,
              icon: Icons.mark_email_unread_rounded,
              color: const Color(0xFF00D2B4),
              isSelected: isUnreadSelected,
              onTap: () => controller.setFilter(
                controller.selectedFilter.value == false ? null : false,
              ),
            ),
            SizedBox(width: 8.w),
            NotificationKpiCard(
              title: 'مالية',
              count: controller.financialCount,
              icon: Icons.account_balance_wallet_rounded,
              color: colors.success,
              isSelected: isFinancialSelected,
              onTap: () => controller.setCategory('FINANCIAL'),
            ),
            SizedBox(width: 8.w),
            NotificationKpiCard(
              title: 'أمان',
              count: controller.securityCount,
              icon: Icons.security_rounded,
              color: colors.warning,
              isSelected: isSecuritySelected,
              onTap: () => controller.setCategory('SECURITY'),
            ),
          ],
        ),
      );
    });
  }
}
