import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_catalog_empty_state.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_catalog_grid.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_catalog_list.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_filter_bottom_sheet.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_search_filter_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة كتالوج باقات الكروت — مسؤوليتها تركيب الصفحة فقط دون أي دوال بناء خاصة
class PackageCatalogScreen extends GetView<PackageCatalogController> {
  const PackageCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isTablet = AppBreakpoints.isTablet(context);

    return CustomAppScaffold(
      appBar: AppBar(
        title: Text(
          'كتالوج باقات الكروت',
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          CustomButton.icon(
            icon: Icons.tune_rounded,
            tooltip: 'فلترة وترتيب الباقات',
            backgroundColor: Colors.transparent,
            foregroundColor: colors.primary,
            onPressed: () => PackageFilterBottomSheet.show(controller),
          ),
          CustomButton.icon(
            icon: Icons.refresh_rounded,
            tooltip: 'تحديث الكتالوج',
            backgroundColor: Colors.transparent,
            foregroundColor: colors.onSurfaceVariant,
            onPressed: () => controller.refreshCatalog(),
          ),
          AppSpacing.hXs,
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.initCreateForm();
          Get.toNamed<void>(AppRoutes.packageForm);
        },
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'إنشاء باقة كروت',
          style: AppTypography.labelLarge.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. شريط البحث والفلترة القطاعية
          const PackageSearchFilterHeader(),

          // 2. محتوى القائمة مع حالات التحميل والخطأ والفراغ
          Expanded(
            child: Obx(() {
              // أ. حالة التحميل بالوميض (Shimmer Loading)
              if (controller.isLoading.value) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CustomSkeletonFeed(
                    itemCount: 4,
                    cardHeight: 140.h,
                  ),
                );
              }

              // ب. حالة الخطأ مع خيار إعادة المحاولة
              if (controller.errorMessage.value != null &&
                  controller.packages.isEmpty) {
                return Center(
                  child: CustomErrorState(
                    title: 'تعذر تحميل كتالوج الباقات',
                    subtitle: controller.errorMessage.value,
                    onRetry: () => controller.refreshCatalog(),
                  ),
                );
              }

              // ج. حالة القائمة الفارغة
              if (controller.filteredPackages.isEmpty) {
                return const Center(child: PackageCatalogEmptyState());
              }

              // د. القائمة أو الشبكة التكيفية مع سحب للتحديث
              return RefreshIndicator.adaptive(
                onRefresh: () => controller.refreshCatalog(),
                child: isTablet
                    ? const PackageCatalogGrid()
                    : const PackageCatalogList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}
