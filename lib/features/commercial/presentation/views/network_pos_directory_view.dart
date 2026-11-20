import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_pos_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_search_filter_header.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_summary_strip.dart';
import 'package:netsales/features/commercial/presentation/widgets/network_pos_card/network_pos_card.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/commercial_partner_details_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/network_pos_qr_invitation_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// واجهة استعراض وإدارة نقاط البيع المرتبطة بشبكة التزويد (Network Workspace View)
class NetworkPosDirectoryView extends GetView<NetworkPosDirectoryController> {
  const NetworkPosDirectoryView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshLinks,
      onLoadMore: controller.loadMoreLinks,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey:
          const PageStorageKey<String>('network-pos-directory-scroll'),
      slivers: [
        // 1. الترويسة القيادية لدليل نقاط البيع وشريط الملخص وفلاتر البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: 'دليل نقاط البيع والشركاء',
                subtitle:
                    'إدارة ومتابعة نقاط البيع المرتبطة، حالة النشاط التجاري، وتوليد رموز الانضمام (QR).',
                icon: Icons.storefront_rounded,
                action: controller.canManageCommercial
                    ? CustomButton.primary(
                        text: 'دعوة نقطة بيع +',
                        icon: Icons.qr_code_rounded,
                        shape: AppButtonShape.pill,
                        size: AppButtonSize.small,
                        onPressed: () async {
                          final challenge =
                              await controller.createQrInvitation();
                          if (challenge != null) {
                            await CustomBottomSheet.show<void>(
                              title: 'دعوة نقطة بيع عبر الرمز المشفر',
                              subtitle:
                                  'امسح الرمز أو انسخ كود الدعوة للارتباط المباشر',
                              child: NetworkPosQrInvitationSheet(
                                challenge: challenge,
                                onRevoke: () => controller
                                    .revokeChallenge(challenge.challengeUuid),
                              ),
                            );
                          }
                        },
                      )
                    : null,
              ),

              Obx(
                () => CommercialSummaryStrip(
                  isNetworkView: true,
                  totalCount: controller.totalCount,
                  activeCount: controller.activeCount,
                  inactiveCount: controller.inactiveCount,
                  isLoading:
                      controller.isLoading.value && controller.links.isEmpty,
                  selectedStatus: controller.statusFilter.value,
                  onStatusTap: controller.setStatusFilter,
                ),
              ),

              Obx(
                () => CommercialSearchFilterHeader(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  selectedStatus: controller.statusFilter.value,
                  onStatusChanged: controller.setStatusFilter,
                  onClearSearch: controller.searchController.clear,
                ),
              ),

              Obx(() {
                final networks = controller.authorizedNetworks;
                if (networks.length <= 1) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CustomDropdown<int>(
                    label: 'تصفية بحسب الشبكة',
                    searchEnabled: false,
                    rxValue: controller.selectedNetworkId,
                    items: networks.map((net) {
                      return DropdownItem<int>(
                        value: net.networkId,
                        child: Text(net.networkName),
                      );
                    }).toList(),
                    onChanged: controller.onNetworkFilterChanged,
                  ),
                );
              }),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. الحالات التفاعلية المركزية (تحميل أولي، خطأ، فراغ) أو قائمة نقاط البيع
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.links.isEmpty;

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
                title: 'تعذر جلب نقاط البيع',
                subtitle: error,
                onRetry: controller.refreshLinks,
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? Icons.search_off_rounded
                    : Icons.storefront_outlined,
                title: 'لا توجد نقاط بيع مسجلة',
                subtitle: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'لم يتم العثور على أي شريك يطابق خيارات التصفية المحددة.'
                    : 'قم بمشاركة رمز دعوة الانضمام لربط أول نقطة بيع بشبكتك.',
                actionLabel: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'إعادة التعيين'
                    : (controller.canManageCommercial
                        ? 'دعوة نقطة بيع الآن'
                        : null),
                onAction: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? controller.resetFilters
                    : (controller.canManageCommercial
                        ? () async {
                            final ch = await controller.createQrInvitation();
                            if (ch != null) {
                              await CustomBottomSheet.show<void>(
                                title: 'دعوة نقطة بيع عبر الرمز المشفر',
                                subtitle: 'امسح الرمز أو انسخ كود الدعوة للارتباط',
                                child: NetworkPosQrInvitationSheet(
                                  challenge: ch,
                                  onRevoke: () => controller
                                      .revokeChallenge(ch.challengeUuid),
                                ),
                              );
                            }
                          }
                        : null),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final link = controller.links[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Obx(
                    () => NetworkPosCard(
                      link: link,
                      isExpanded: controller.expandedLinkId.value ==
                          link.networkPosId,
                      onToggleExpansion: () =>
                          controller.toggleAccordion(link.networkPosId),
                      onToggleStatus: () =>
                          controller.promptToggleStatus(link),
                      onDelete: () =>
                          controller.promptDeleteLink(link),
                      onTap: () {
                        CustomBottomSheet.show<void>(
                          title: 'ملف نقطة البيع',
                          subtitle: 'البيانات التجارية المعتمدة للشريك',
                          child: CommercialPartnerDetailsSheet(
                            link: link,
                            isNetworkView: true,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: controller.links.length,
            ),
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
  }
}
