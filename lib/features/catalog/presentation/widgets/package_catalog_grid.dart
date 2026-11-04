import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_delete_confirm_dialog.dart';

/// شبكة باقات الكروت المخصصة للأجهزة اللوحية (Tablet GridView)
class PackageCatalogGrid extends GetView<PackageCatalogController> {
  const PackageCatalogGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredPackages;

      return GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.1,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final package = items[index];
          return PackageCard(
            package: package,
            onTap: () {
              controller.selectPackage(package);
              Get.toNamed<void>(AppRoutes.packageDetails);
            },
            onToggleStatus: () => controller.togglePackageStatus(package),
            onEdit: () {
              controller.initEditForm(package);
              Get.toNamed<void>(AppRoutes.packageForm);
            },
            onDelete: () => PackageDeleteConfirmDialog.show(
              packageName: package.packageName,
              onConfirm: () => controller.deletePackage(package.packageId),
            ),
          );
        },
      );
    });
  }
}
