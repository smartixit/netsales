import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
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
/// - كلاس واحد في ملف واحد بمسؤولية واحدة واضحة (One Public Class Per File).
/// - واجهة تصريحية بحتة (Pure Declarative UI) خالية تماماً من منطق الأعمال والشروط المتفرعة.
/// - مطابقة تامة للمعمارية الموحدة المنفذة في شاشات الطلبات، الفواتير، والعضويات.
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
        // 1. ترويسة الصفحة وبطاقات المؤشرات والبحث والتصفية
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
                        shape: AppButtonShape.pill,
                        size: AppButtonSize.small,
                        onPressed: () =>
                            Get.toNamed<void>(AppRoutes.packageForm),
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

              Obx(
                () => CustomSearchFilterBar<String?>(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  searchHint: 'بحث باسم الباقة، المعرف، أو الرصيد...',
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
            return const SliverToBoxAdapter(
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 4,
                  cardHeight: 156,
                  maxColumns: 1,
                  hasLeading: true,
                ),
              ),
            );
          }

          if (error != null && isEmpty) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'تعذر جلب كتالوج الباقات',
                subtitle: error,
                onRetry: controller.refreshCatalog,
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: hasFilter
                    ? Icons.search_off_rounded
                    : Icons.wifi_tethering_off_rounded,
                title: hasFilter
                    ? 'لا توجد باقات مطابقة'
                    : 'لا توجد باقات كروت مسجلة حالياً',
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                    : 'يمكنك البدء بإنشاء باقات كروت الإنترنت وتحديد أسعارها ونسب خصمها.',
                actionLabel: hasFilter ? 'مسح عوامل التصفية' : null,
                onAction: hasFilter ? controller.resetFilters : null,
              ),
            );
          }

          final packageCount = controller.packages.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) return AppSpacing.vSm;
              final packageIndex = index ~/ 2;
              final package = controller.packages[packageIndex];

              return Obx(() {
                final isExpanded =
                    controller.expandedPackageId.value == package.packageId;

                return PackageCard(
                  key: ValueKey<String>('voucher-package-${package.packageId}'),
                  package: package,
                  isExpanded: isExpanded,
                  onToggleExpand: () =>
                      controller.toggleAccordion(package.packageId),
                  onDetails: () => controller.openPackageDetails(package),
                  onEdit: controller.canEditPackage
                      ? () => controller.initEditForm(package)
                      : null,
                  onToggleStatus: () => controller.promptToggleStatus(package),
                  onDelete: controller.canDeletePackage
                      ? () => controller.promptDeletePackage(package)
                      : null,
                );
              });
            }, childCount: packageCount == 0 ? 0 : packageCount * 2 - 1),
          );
        }),

        // 3. ذيل التحميل الإضافي الموحد (CustomCursorLoadMore)
        SliverToBoxAdapter(
          child: Obx(
            () => CustomCursorLoadMore(
              hasMore: controller.hasMore,
              isLoading: controller.isLoadingMore.value,
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
