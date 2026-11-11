import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_delete_confirm_dialog.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';

/// قائمة باقات الكروت المخصصة للهواتف الذكية مع ترقيم الصفحات القائم على المؤشر (Infinite Scroll)
class PackageCatalogList extends GetView<PackageCatalogController> {
  const PackageCatalogList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredPackages;
      final isLoadingMore = controller.isLoadingMore.value;

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >=
              scrollInfo.metrics.maxScrollExtent - 200) {
            controller.loadMorePackages();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          itemCount: items.length + (isLoadingMore ? 1 : 0),
          separatorBuilder: (context, i) => AppSpacing.vSm,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: CustomSkeletonCard(height: 110.h),
              );
            }

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
        ),
      );
    });
  }
}
