import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_directory_controller.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
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

class NetworkDirectoryScreen extends GetView<NetworkDirectoryController> {
  const NetworkDirectoryScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshDirectory,
      onLoadMore: controller.loadMore,
      hasMorePredicate: () => controller.hasMore,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomPageHeroCard(
                title: 'الشبكات',
                subtitle: 'إدارة الكيانات وبياناتها الأساسية ومتابعة دورة حياتها.',
                icon: Icons.hub_rounded,
              ),
              Obx(() => controller.canCreate && !controller.showArchived.value
                  ? CustomButton.primary(
                      text: 'إنشاء شبكة',
                      prefix: Icons.add_rounded,
                      onPressed: () async {
                        final saved = await Get.toNamed(AppRoutes.networkEntityCreate);
                        if (saved == true) await controller.refreshDirectory();
                      },
                    )
                  : const SizedBox.shrink()),
              Obx(() => CustomButton.secondary(
                text: controller.showArchived.value ? 'العودة إلى الشبكات النشطة' : 'عرض أرشيف الشبكات',
                prefix: controller.showArchived.value ? Icons.arrow_forward_rounded : Icons.archive_outlined,
                onPressed: controller.toggleArchiveView,
              )),
              AppSpacing.vSm,
              Obx(() => CustomSearchFilterBar<String?>(
                searchController: controller.searchController,
                searchQuery: controller.searchQuery.value,
                searchHint: 'ابحث باسم الشبكة أو بياناتها...',
                onClearSearch: controller.clearSearch,
                selectedFilter: controller.showArchived.value ? null : controller.statusFilter.value,
                filterOptions: controller.showArchived.value ? const [] : const [
                  CustomSearchFilterOption(value: null, label: 'الكل'),
                  CustomSearchFilterOption(value: 'ACTIVE', label: 'نشطة'),
                  CustomSearchFilterOption(value: 'PENDING', label: 'قيد المراجعة'),
                  CustomSearchFilterOption(value: 'INACTIVE', label: 'مجمّدة'),
                  CustomSearchFilterOption(value: 'REJECTED', label: 'مرفوضة'),
                  CustomSearchFilterOption(value: 'BANNED', label: 'محظورة'),
                ],
                onFilterChanged: controller.setStatusFilter,
              )),
              AppSpacing.vSm,
            ],
          ),
        ),
        Obx(() {
          if (controller.isLoading.value && controller.networks.isEmpty) {
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
          if (controller.errorMessage.value != null && controller.networks.isEmpty) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'تعذر تحميل الشبكات',
                subtitle: controller.errorMessage.value,
                onRetry: controller.refreshDirectory,
              ),
            );
          }
          if (controller.networks.isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: controller.showArchived.value ? Icons.archive_outlined : Icons.hub_outlined,
                title: controller.showArchived.value ? 'أرشيف الشبكات فارغ' : 'لا توجد شبكات',
                subtitle: controller.showArchived.value
                    ? 'لا توجد شبكات مؤرشفة يمكن استعادتها.'
                    : 'لا توجد كيانات تطابق معايير البحث الحالية.',
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final network = controller.networks[index];
                if (controller.showArchived.value) {
                  return CustomSurfaceCard(
                    margin: EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CustomCachedImage.logo(
                          url: network.networkProfileLogoUrl,
                          size: 52,
                          fallbackText: network.displayName,
                        ),
                        AppSpacing.hMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(network.displayName, style: Theme.of(context).textTheme.titleMedium),
                              AppSpacing.vXxs,
                              Text(network.displayLocation, style: Theme.of(context).textTheme.bodySmall),
                              AppSpacing.vXs,
                              CustomStatusBadge(
                                label: network.statusLabel ?? network.typedStatus.label,
                                tone: network.typedStatus.tone,
                                isCompact: true,
                              ),
                            ],
                          ),
                        ),
                        if (controller.canRestore)
                          CustomButton.secondary(
                            text: 'استعادة',
                            prefix: Icons.restore_rounded,
                            onPressed: controller.isRestoring.value
                                ? null
                                : () => controller.restoreNetwork(network),
                          ),
                      ],
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () async {
                    final changed = await Get.toNamed(AppRoutes.networkEntityDetails.replaceFirst(':id', network.networkId.toString()));
                    if (changed == true) await controller.refreshDirectory();
                  },
                  child: CustomSurfaceCard(
                  margin: EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CustomCachedImage.logo(
                        url: network.networkProfileLogoUrl,
                        size: 52,
                        fallbackText: network.displayName,
                      ),
                      AppSpacing.hMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(network.displayName, style: Theme.of(context).textTheme.titleMedium),
                            AppSpacing.vXxs,
                            Text(network.displayLocation, style: Theme.of(context).textTheme.bodySmall),
                            AppSpacing.vXs,
                            CustomStatusBadge(
                              label: network.statusLabel ?? network.typedStatus.label,
                              tone: network.typedStatus.tone,
                              isCompact: true,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded, color: context.colors.onSurfaceVariant),
                    ],
                  ),
                  ),
                );
              },
              childCount: controller.networks.length,
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
    );
    if (embedded) return content;
    return CustomAppScaffold(
      appBarTitle: 'إدارة الشبكات',
      body: content,
    );
  }
}
