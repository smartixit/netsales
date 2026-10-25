import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/network_pos_item_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// قائمة تدفق عقود الشراكة والتوزيع (NetworkPosFeed)
/// ============================================================================
/// تدير حالات التحميل، الفراغ، وتدفق بطاقات عقود الربط بين الشبكات ونقاط البيع.
class NetworkPosFeed extends StatelessWidget {
  final PartnersController controller;

  const NetworkPosFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الأولي
      if (controller.isLoading.value && controller.networkPosList.isEmpty) {
        return const CustomSkeletonFeed(itemCount: 4, cardHeight: 120);
      }

      final items = controller.filteredNetworkPosList;

      // 2. حالة الفراغ
      if (items.isEmpty) {
        final isFiltering = controller.searchQuery.value.isNotEmpty ||
            controller.selectedStatusFilter.value != 'ALL';
        return CustomEmptyState(
          title: isFiltering
              ? 'لا توجد عقود مطابقة'
              : 'لا توجد عقود توزيع مسجلة',
          subtitle: isFiltering
              ? 'جرّب تعديل عبارة البحث أو تغيير فلتر الحالة المعروضة'
              : 'لم يتم ربط أي نقاط بيع بشبكات الإنترنت حتى الآن',
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
            return NetworkPosItemCard(
              link: items[index],
              controller: controller,
            );
          },
        ),
      );
    });
  }
}
