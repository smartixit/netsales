import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_linked_networks_controller.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_search_filter_header.dart';
import 'package:netsales/features/commercial/presentation/widgets/commercial_summary_strip.dart';
import 'package:netsales/features/commercial/presentation/widgets/pos_linked_network_card/pos_linked_network_card.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/commercial_partner_details_sheet.dart';
import 'package:netsales/features/commercial/presentation/widgets/sheets/pos_qr_confirm_link_sheet.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// واجهة استعراض ومتابعة شبكات التزويد المرتبطة بنقطة البيع (POS Workspace View)
class PosLinkedNetworksView extends GetView<PosLinkedNetworksController> {
  const PosLinkedNetworksView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshLinks,
      scrollKey: const PageStorageKey<String>('pos-linked-networks-scroll'),
      onNotification: (scroll) {
        if (scroll.depth == 0 &&
            scroll.metrics.extentAfter <= 220 &&
            controller.hasMore) {
          controller.loadMoreLinks();
        }
        return false;
      },
      slivers: [
        // 1. الترويسة القيادية لشبكات التزويد المرتبطة وشريط الملخص وفلاتر البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: 'الشبكات المزودة المرتبطة',
                subtitle:
                    'استعراض ومتابعة شبكات التزويد، فحص رموز الارتباط (QR)، والاتصال بمزودين جدد.',
                icon: Icons.hub_rounded,
                action: controller.canManageCommercial
                    ? CustomButton.primary(
                        text: 'ربط مزود جديد +',
                        icon: Icons.qr_code_scanner_rounded,
                        shape: AppButtonShape.pill,
                        size: AppButtonSize.small,
                        onPressed: () {
                          final codeController = TextEditingController();
                          final previewRx = Rxn<NetworkPosLinkPreviewEntity>();

                          CustomBottomSheet.show<void>(
                            title: 'ربط مزود شبكة جديد',
                            subtitle:
                                'أدخل كود الدعوة أو الصق الرمز المشفر لفحص بيانات الشبكة',
                            child: Obx(
                              () => PosQrConfirmLinkSheet(
                                codeController: codeController,
                                preview: previewRx.value,
                                onPreview: () async {
                                  final p = await controller.previewChallenge(
                                    codeController.text.trim(),
                                  );
                                  previewRx.value = p;
                                },
                                onConfirm: () async {
                                  final p = previewRx.value;
                                  if (p != null) {
                                    final ok = await controller.confirmChallenge(
                                      p.challengeUuid,
                                    );
                                    if (ok) {
                                      Get.back<void>();
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : null,
              ),

              Obx(
                () => CommercialSummaryStrip(
                  isNetworkView: false,
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
                final posList = controller.authorizedPosList;
                if (posList.length <= 1) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CustomDropdown<int>(
                    label: 'تصفية بحسب نقطة البيع',
                    searchEnabled: false,
                    rxValue: controller.selectedPosId,
                    items: posList.map((pos) {
                      return DropdownItem<int>(
                        value: pos.posId,
                        child: Text(pos.displayName),
                      );
                    }).toList(),
                    onChanged: controller.onPosFilterChanged,
                  ),
                );
              }),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. الحالات التفاعلية المركزية (تحميل أولي، خطأ، فراغ) أو قائمة الشبكات
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
                title: 'تعذر جلب شبكات التزويد',
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
                    : Icons.hub_outlined,
                title: 'لا توجد شبكات تزويد مرتبطة',
                subtitle: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'لم يتم العثور على أي مزود يطابق خيارات التصفية المحددة.'
                    : 'يمكنك طلب كود الارتباط من مزود شبكتك ومسحه هنا للانضمام.',
                actionLabel: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'إعادة التعيين'
                    : (controller.canManageCommercial
                        ? 'ربط مزود الآن'
                        : null),
                onAction: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? controller.resetFilters
                    : (controller.canManageCommercial
                        ? () {
                            final codeController = TextEditingController();
                            final previewRx =
                                Rxn<NetworkPosLinkPreviewEntity>();

                            CustomBottomSheet.show<void>(
                              title: 'ربط مزود شبكة جديد',
                              subtitle:
                                  'أدخل كود الدعوة أو الصق الرمز المشفر لفحص بيانات الشبكة',
                              child: Obx(
                                () => PosQrConfirmLinkSheet(
                                  codeController: codeController,
                                  preview: previewRx.value,
                                  onPreview: () async {
                                    final p = await controller.previewChallenge(
                                      codeController.text.trim(),
                                    );
                                    previewRx.value = p;
                                  },
                                  onConfirm: () async {
                                    final p = previewRx.value;
                                    if (p != null) {
                                      final ok =
                                          await controller.confirmChallenge(
                                        p.challengeUuid,
                                      );
                                      if (ok) {
                                        Get.back<void>();
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
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
                    () => PosLinkedNetworkCard(
                      link: link,
                      isExpanded: controller.expandedLinkId.value ==
                          link.networkPosId,
                      onToggleExpansion: () =>
                          controller.toggleAccordion(link.networkPosId),
                      onDelete: () =>
                          controller.promptDeleteLink(link),
                      onTap: () {
                        CustomBottomSheet.show<void>(
                          title: 'ملف مزود الشبكة',
                          subtitle: 'البيانات التجارية المعتمدة للشريك',
                          child: CommercialPartnerDetailsSheet(
                            link: link,
                            isNetworkView: false,
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
