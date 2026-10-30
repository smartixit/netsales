import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/features/partners/presentation/widgets/sheets/link_partner_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// ============================================================================
/// رأس التبويب القطاعي للشركاء والتوزيع (PartnersSegmentedHeader)
/// ============================================================================
/// يدمج شريط التبديل القطاعي التنفيذي مع زر إجراء سريع سياقي ذكي ينشط للتسجيل والربط.
class PartnersSegmentedHeader extends StatelessWidget {
  final PartnersController controller;

  const PartnersSegmentedHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeIndex = controller.activeSegmentIndex.value;
      final actionText = activeIndex == 0
          ? 'شبكة'
          : (activeIndex == 1 ? 'وكيل' : 'ربط');
      final actionIcon = activeIndex == 0
          ? Icons.add_business_rounded
          : (activeIndex == 1
              ? Icons.person_add_alt_1_rounded
              : Icons.link_rounded);

      return Row(
        children: [
          // 1. شريط التبديل القطاعي الموحد (الشبكات | الوكلاء | العقود)
          Expanded(
            child: CustomSegmentedBar(
              selectedIndex: activeIndex,
              onSegmentChanged: controller.changeSegment,
              items: [
                CustomSegmentItem(
                  label: 'الشبكات',
                  count: controller.networks.length,
                  highlightBadge: controller.pendingNetworksCount > 0,
                  icon: Icons.hub_rounded,
                ),
                CustomSegmentItem(
                  label: 'الوكلاء',
                  count: controller.posList.length,
                  highlightBadge: controller.pendingPosCount > 0,
                  icon: Icons.storefront_rounded,
                ),
                CustomSegmentItem(
                  label: 'العقود',
                  count: controller.networkPosList.length,
                  icon: Icons.swap_horiz_rounded,
                ),
              ],
            ),
          ),

          AppSpacing.hSm,

          // 2. زر الإجراء السريع السياقي المتكيف مع قياس الشاشة
          if (MediaQuery.sizeOf(context).width < 360)
            CustomButton.icon(
              icon: actionIcon,
              tooltip: actionText,
              dimension: 40.r,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                if (activeIndex == 0) {
                  Get.toNamed(AppRoutes.registerNetwork);
                } else if (activeIndex == 1) {
                  Get.toNamed(AppRoutes.registerPos);
                } else {
                  LinkPartnerSheet.show(context, controller: controller);
                }
              },
            )
          else
            CustomButton.primary(
              text: actionText,
              icon: actionIcon,
              height: 42.h,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              onPressed: () {
                if (activeIndex == 0) {
                  Get.toNamed(AppRoutes.registerNetwork);
                } else if (activeIndex == 1) {
                  Get.toNamed(AppRoutes.registerPos);
                } else {
                  LinkPartnerSheet.show(context, controller: controller);
                }
              },
            ),
        ],
      );
    });
  }
}
