import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_partner_card.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة دليل الشركاء والعلاقات التجارية الموحدة (CommercialDirectoryScreen)
///
/// تجسد المعمارية المؤسسية النظيفة (Enterprise Clean Architecture):
/// - كلاس واحد في ملف واحد بمسؤولية واحدة واضحة (One Public Class Per File).
/// - واجهة تصريحية بحتة (Pure Declarative UI) خالية تماماً من منطق الأعمال والشروط المتفرعة.
/// - تعتمد نمط الاستراتيجية (Strategy Pattern) باستهلاك العقد المعماري الموحد [BaseCommercialDirectoryController]،
///   بحيث تتكيف الشاشة تلقائياً وفق مساحة العمل المحقونة (مساحة الشبكة أو نقطة البيع).
class CommercialDirectoryScreen
    extends GetView<BaseCommercialDirectoryController> {
  const CommercialDirectoryScreen({
    super.key,
    this.embedded = false,
    this.isNetwork,
  });

  final bool embedded;
  final bool? isNetwork;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshDirectory,
      onLoadMore: controller.loadMoreLinks,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey: const PageStorageKey<String>('commercial-directory-scroll'),
      slivers: [
        // 1. ترويسة الصفحة وبطاقات المؤشرات والبحث والتصفية
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => CustomPageHeroCard(
                  title: controller.pageTitle,
                  subtitle: controller.pageSubtitle,
                  icon: controller.pageIcon,
                  action: controller.headerAction,
                ),
              ),

              Obx(
                () => CustomStatusSummaryStrip(
                  cards: controller.buildKpiCards(context),
                  isLoading:
                      controller.isLoading.value && controller.links.isEmpty,
                  selectedKey: controller.statusFilter.value,
                  onSelectKey: controller.setStatusFilter,
                ),
              ),

              Obx(
                () => CustomSearchFilterBar<String?>(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  searchHint: controller.searchHint,
                  selectedFilter: controller.statusFilter.value,
                  filterOptions: controller.buildFilterOptions(context),
                  onFilterChanged: controller.setStatusFilter,
                  onClearSearch: controller.searchController.clear,
                ),
              ),

              Obx(
                () =>
                    controller.buildExtraFilters(context) ??
                    const SizedBox.shrink(),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. حالات القائمة (تحميل، خطأ، فراغ) أو بطاقات الشركاء التجاريين
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.links.isEmpty;
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
                title: 'تعذر جلب الشركاء التجاريين',
                subtitle: error,
                onRetry: controller.refreshDirectory,
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: hasFilter
                    ? Icons.search_off_rounded
                    : (controller.isNetworkView
                          ? Icons.storefront_outlined
                          : Icons.hub_outlined),
                title: hasFilter
                    ? 'لا يوجد شركاء مطابقين للبحث'
                    : (controller.isNetworkView
                          ? 'لا توجد نقاط بيع مرتبطة حالياً'
                          : 'لا توجد شبكات تزويد مرتبطة حالياً'),
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                    : (controller.isNetworkView
                          ? 'قم بمشاركة رمز دعوة الانضمام (QR) لربط أول نقطة بيع بشبكتك.'
                          : 'قم بمسح رمز QR لدعوة المزود لإتمام الارتباط التجاري.'),
                actionLabel: hasFilter ? 'مسح عوامل التصفية' : null,
                onAction: hasFilter ? controller.resetFilters : null,
              ),
            );
          }

          final linkCount = controller.links.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) return AppSpacing.vSm;
              final linkIndex = index ~/ 2;
              final link = controller.links[linkIndex];

              return Obx(() {
                final isExpanded =
                    controller.expandedLinkId.value == link.networkPosId;

                return CommercialPartnerCard(
                  key: ValueKey<String>('commercial-link-${link.networkPosId}'),
                  link: link,
                  isNetworkView: controller.isNetworkView,
                  isExpanded: isExpanded,
                  onToggleExpand: () =>
                      controller.toggleAccordion(link.networkPosId),
                  onDetails: () => controller.openPartnerDetails(link),
                  actions: controller.buildCardActions(context, link),
                );
              });
            }, childCount: linkCount == 0 ? 0 : (linkCount * 2) - 1),
          );
        }),

        // 3. ذيل التحميل الإضافي الموحد (CustomCursorLoadMore)
        SliverToBoxAdapter(
          child: Obx(
            () => CustomCursorLoadMore(
              hasMore: controller.hasMore,
              isLoading: controller.isLoadingMore.value,
              error: controller.loadMoreError.value,
              onPressed: controller.loadMoreLinks,
            ),
          ),
        ),
      ],
    );

    if (embedded) return content;

    return Obx(
      () => CustomAppScaffold(appBarTitle: controller.pageTitle, body: content),
    );
  }
}
