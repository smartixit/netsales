import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/pos_item_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// قائمة تدفق نقاط البيع والوكلاء (PosListFeed)
/// ============================================================================
/// تدير حالات التحميل، الفراغ، وتدفق بطاقات نقاط البيع مع السحب للتحديث.
class PosListFeed extends StatelessWidget {
  final PartnersController controller;

  const PosListFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الأولي
      if (controller.isLoading.value && controller.posList.isEmpty) {
        return const CustomSkeletonFeed(itemCount: 4, cardHeight: 130);
      }

      final items = controller.filteredPosList;

      // 2. حالة الفراغ
      if (items.isEmpty) {
        final isFiltering = controller.searchQuery.value.isNotEmpty ||
            controller.selectedStatusFilter.value != 'ALL';
        return CustomEmptyState(
          title: isFiltering
              ? 'لا توجد نتائج مطابقة'
              : 'لا توجد نقاط بيع مسجلة',
          subtitle: isFiltering
              ? 'جرّب تعديل عبارة البحث أو تغيير فلتر الحالة المعروضة'
              : 'لم يتم تسجيل أي نقاط بيع أو وكلاء توزيع في النظام حتى الآن',
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
            return PosItemCard(
              pos: items[index],
              controller: controller,
            );
          },
        ),
      );
    });
  }
}
