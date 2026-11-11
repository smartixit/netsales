import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_delete_confirm_dialog.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';

/// شبكة باقات الكروت المخصصة للأجهزة اللوحية مع ترقيم الصفحات القائم على المؤشر (Infinite Scroll)
class PackageCatalogGrid extends GetView<PackageCatalogController> {
  const PackageCatalogGrid({super.key});

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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final package = items[index];
                  return PackageCard(
                    package: package,
                    onTap: () {
                      controller.selectPackage(package);
                      Get.toNamed<void>(AppRoutes.packageDetails);
                    },
                    onToggleStatus: () =>
                        controller.togglePackageStatus(package),
                    onEdit: () {
                      controller.initEditForm(package);
                      Get.toNamed<void>(AppRoutes.packageForm);
                    },
                    onDelete: () => PackageDeleteConfirmDialog.show(
                      packageName: package.packageName,
                      onConfirm: () =>
                          controller.deletePackage(package.packageId),
                    ),
                  );
                }, childCount: items.length),
              ),
            ),
            if (isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.cardPadding,
                    vertical: AppSpacing.xs,
                  ),
                  child: CustomSkeletonCard(height: 140.h),
                ),
              ),
          ],
        ),
      );
    });
  }
}
