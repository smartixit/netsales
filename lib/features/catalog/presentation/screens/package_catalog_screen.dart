import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/dialogs/package_action_dialogs.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة كتالوج الباقات للشبكة (PackageCatalogScreen)
///
/// تجسد المعمارية المؤسسية النظيفة (Enterprise Clean Architecture):
/// - كلاس واحد في ملف واحد بمسؤولية تركيبية بحتة (Pure Declarative Page Composition).
/// - خالية تماماً من منطق الأعمال والشروط المتفرعة.
/// - استهلاك مباشر للمكونات العامة الموحدة وشريط المؤشرات والترقيم بالمؤشر.
class PackageCatalogScreen extends GetView<PackageCatalogController> {
  const PackageCatalogScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshCatalog,
      onLoadMore: controller.loadMorePackages,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey: const PageStorageKey<String>('package-catalog-scroll'),
      slivers: [
        // 1. ترويسة الصفحة وبطاقات المؤشرات وشريط البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: 'كتالوج الباقات',
                subtitle: 'إدارة وتسعير باقات كروت الإنترنت وتحديد نسب الخصم النقدي والآجل.',
                icon: Icons.inventory_2_rounded,
                action: controller.canCreatePackage
                    ? CustomButton.primary(
                        text: 'إنشاء باقة كروت',
                        icon: Icons.add_rounded,
                        shape: AppButtonShape.rounded,
                        size: AppButtonSize.small,
                        onPressed: controller.navigateToCreate,
                      )
                    : null,
              ),

              Obx(
                () => CustomStatusSummaryStrip(
                  cards: controller.buildKpiCards(context),
                  isLoading:
                      controller.isLoading.value && controller.packages.isEmpty,
                  selectedKey: controller.currentFilterKey,
                  onSelectKey: controller.onFilterKeySelected,
                ),
              ),
              AppSpacing.vSm,

              Obx(
                () => CustomSearchFilterBar<String?>(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  searchHint: 'بحث باسم الباقة أو معرفها...',
                  selectedFilter: controller.currentFilterKey,
                  filterOptions: controller.buildFilterOptions(context),
                  onFilterChanged: controller.onFilterKeySelected,
                  onClearSearch: controller.searchController.clear,
                ),
              ),

              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. حالات القائمة (تحميل، خطأ، فراغ) أو عناصر باقات الكروت
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.packages.isEmpty;
          final hasFilter =
              controller.statusFilter.value != null ||
              controller.searchQuery.value.trim().isNotEmpty;

          if (isLoading && isEmpty) {
            return SliverToBoxAdapter(
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 4,
                  cardHeight: 180.h,
                ),
              ),
            );
          }

          if (error != null && isEmpty) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'تعذر تحميل كتالوج الباقات',
                subtitle: error,
                onRetry: controller.refreshCatalog,
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: Icons.inventory_2_outlined,
                title: hasFilter
                    ? 'لا توجد باقات مطابقة للبحث'
                    : 'كتالوج الباقات فارغ',
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو إلغاء التصفية لإظهار كافة الباقات.'
                    : 'لم تقم الشبكة بإضافة أي باقات كروت بعد. يمكنك البدء بإنشاء أول باقة الآن.',
                actionLabel: controller.canCreatePackage && !hasFilter
                    ? 'إنشاء أول باقة كروت'
                    : null,
                onAction: controller.canCreatePackage && !hasFilter
                    ? controller.navigateToCreate
                    : null,
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final package = controller.packages[index];
              final isExpanded =
                  controller.expandedPackageId.value == package.packageId;

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: PackageCard(
                  package: package,
                  isExpanded: isExpanded,
                  onToggleExpand: () =>
                      controller.toggleExpanded(package.packageId),
                  onDetails: () => controller.navigateToDetails(package),
                  onEdit: () => controller.navigateToEdit(package),
                  onToggleStatus: () =>
                      PackageActionDialogs.showToggleStatusConfirmation(
                        context,
                        package: package,
                        onConfirm: () =>
                            controller.togglePackageStatus(package),
                      ),
                  onDelete: () => PackageActionDialogs.showDeleteConfirmation(
                    context,
                    package: package,
                    onConfirm: () => controller.deletePackage(package),
                  ),
                  canEdit: controller.canEditPackage,
                  canDelete: controller.canDeletePackage,
                ),
              );
            }, childCount: controller.packages.length),
          );
        }),

        // 3. مؤشر تحميل المزيد بالمؤشر
        SliverToBoxAdapter(
          child: Obx(
            () => CustomCursorLoadMore(
              isLoading: controller.isLoadingMore.value,
              hasMore: controller.hasMore,
              error: controller.loadMoreError.value,
              onPressed: controller.loadMorePackages,
            ),
          ),
        ),
      ],
    );

    if (embedded) return content;

    return CustomAppScaffold(appBarTitle: 'كتالوج الباقات', body: content);
  }
}
