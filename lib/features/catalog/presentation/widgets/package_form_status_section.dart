import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/inputs/custom_switch_list_tile.dart';

/// قسم حالة تفعيل الباقة (نشطة أو معطلة فور الحفظ)
class PackageFormStatusSection extends GetView<PackageCatalogController> {
  const PackageFormStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isActive = controller.packageActiveStatus.value;
      return CustomSwitchListTile(
        title: 'تفعيل الباقة فور الحفظ',
        subtitle: isActive
            ? 'الباقة ستكون متاحة مباشرة لطلب الوكلاء في نقاط البيع'
            : 'الباقة ستكون معطلة ومخفية عن الوكلاء في نقاط البيع',
        value: isActive,
        activeIcon: Icons.check_circle_outline_rounded,
        inactiveIcon: Icons.highlight_off_rounded,
        activeColor: colors.success,
        onChanged: (val) {
          controller.packageActiveStatus.value = val;
        },
      );
    });
  }
}
