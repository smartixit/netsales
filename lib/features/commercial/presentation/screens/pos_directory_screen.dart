import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_directory_controller.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';

class PosDirectoryScreen extends GetView<PosDirectoryController> {
  const PosDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBarTitle: 'إدارة نقاط البيع',
    body: CustomRefreshablePage.slivers(
      onRefresh: controller.refreshDirectory,
      onLoadMore: controller.loadMore,
      hasMorePredicate: () => controller.hasMore,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomPageHeroCard(
                title: 'نقاط البيع',
                subtitle: 'إدارة الكيانات وبياناتها الأساسية ومتابعة دورة حياتها.',
                icon: Icons.storefront_rounded,
              ),
              Obx(() => CustomSearchFilterBar<String?>(
                searchController: controller.searchController,
                searchQuery: controller.searchQuery.value,
                searchHint: 'ابحث باسم نقطة البيع أو بياناتها...',
                onClearSearch: controller.clearSearch,
                selectedFilter: controller.statusFilter.value,
                filterOptions: const [
                  CustomSearchFilterOption(value: null, label: 'الكل'),
                  CustomSearchFilterOption(value: 'ACTIVE', label: 'نشطة'),
                  CustomSearchFilterOption(value: 'PENDING', label: 'قيد المراجعة'),
                  CustomSearchFilterOption(value: 'SUSPENDED', label: 'موقوفة'),
                  CustomSearchFilterOption(value: 'REJECTED', label: 'مرفوضة'),
                ],
                onFilterChanged: controller.setStatusFilter,
              )),
              AppSpacing.vSm,
            ],
          ),
        ),
        Obx(() {
          if (controller.isLoading.value && controller.points.isEmpty) {
            return const SliverToBoxAdapter(
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 5,
                  cardHeight: 90,
                  hasLeading: true,
                ),
              ),
            );
          }
          if (controller.errorMessage.value != null && controller.points.isEmpty) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'تعذر تحميل نقاط البيع',
                subtitle: controller.errorMessage.value,
                onRetry: controller.refreshDirectory,
              ),
            );
          }
          if (controller.points.isEmpty) {
            return const SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: Icons.storefront_outlined,
                title: 'لا توجد نقاط بيع',
                subtitle: 'لا توجد كيانات تطابق معايير البحث الحالية.',
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pos = controller.points[index];
                return CustomSurfaceCard(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CustomCachedImage.logo(
                        url: pos.posProfileLogoUrl,
                        size: 52,
                        fallbackText: pos.displayName,
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pos.displayName, style: Theme.of(context).textTheme.titleMedium),
                            AppSpacing.vXxs,
                            Text(pos.displayLocation, style: Theme.of(context).textTheme.bodySmall),
                            AppSpacing.vXs,
                            CustomStatusBadge(
                              label: pos.statusLabel ?? pos.status ?? 'غير محدد',
                              tone: pos.isActive ? SemanticTone.success : SemanticTone.warning,
                              isCompact: true,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded, color: context.colors.onSurfaceVariant),
                    ],
                  ),
                );
              },
              childCount: controller.points.length,
            ),
          );
        }),
        SliverToBoxAdapter(
          child: Obx(() => CustomCursorLoadMore(
            hasMore: controller.hasMore,
            isLoading: controller.isLoadingMore.value,
            error: controller.loadMoreError.value,
            onPressed: controller.loadMore,
          )),
        ),
      ],
    ),
  );
}
