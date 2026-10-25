import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// ============================================================================
/// ترويسة التبديل القطاعي لمركز الباقات (PackagesSegmentedHeader)
/// ============================================================================
/// ودجت مستقل يربط كلاس CustomSegmentedBar بالمتحكم عبر Obx لتوفير
/// تبديل سريع بين كتالوج الباقات ومصفوفة خصومات نقاط البيع.
class PackagesSegmentedHeader extends StatelessWidget {
  final PackagesController controller;

  const PackagesSegmentedHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Obx(
        () => CustomSegmentedBar(
          selectedIndex: controller.activeSegmentIndex.value,
          onSegmentChanged: controller.changeSegment,
          items: [
            CustomSegmentItem(
              label: 'باقات الكروت',
              count: controller.packages.length,
              icon: Icons.confirmation_number_outlined,
            ),
            CustomSegmentItem(
              label: 'خصومات نقاط البيع',
              count: controller.discounts.length,
              icon: Icons.percent_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
