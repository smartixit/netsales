import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/network_item_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// قائمة تدفق مزودي الشبكات (NetworksFeed)
/// ============================================================================
/// تدير حالات التحميل، الفراغ، وتدفق بطاقات مزودي الشبكات مع السحب للتحديث.
class NetworksFeed extends StatelessWidget {
  final PartnersController controller;

  const NetworksFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الأولي
      if (controller.isLoading.value && controller.networks.isEmpty) {
        return const CustomSkeletonFeed(itemCount: 4, cardHeight: 130);
      }

      final items = controller.filteredNetworks;

      // 2. حالة الفراغ
      if (items.isEmpty) {
        final isFiltering = controller.searchQuery.value.isNotEmpty ||
            controller.selectedStatusFilter.value != 'ALL';
        return CustomEmptyState(
          title: isFiltering
              ? 'لا توجد نتائج مطابقة'
              : 'لا يوجد مزودو شبكات مسجلون',
          subtitle: isFiltering
              ? 'جرّب تعديل عبارة البحث أو تغيير فلتر الحالة المعروضة'
              : 'لم يتم تسجيل أي مزودي شبكات إنترنت في النظام حتى الآن',
        );
      }

      // 3. حالة النجاح مع السحب للتحديث
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadAllData(isRefresh: true),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xs,
          ),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) => AppSpacing.vXs,
          itemBuilder: (context, index) {
            return NetworkItemCard(
              network: items[index],
              controller: controller,
            );
          },
        ),
      );
    });
  }
}
