import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
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
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// واجهة استعراض ومتابعة شبكات التزويد المرتبطة بنقطة البيع (POS Workspace View)
class PosLinkedNetworksView extends GetView<PosLinkedNetworksController> {
  const PosLinkedNetworksView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final topPadding = embedded
        ? MediaQuery.paddingOf(context).top + 20.h
        : AppSpacing.md;
    final bottomPadding = embedded
        ? 115.h + MediaQuery.paddingOf(context).bottom
        : MediaQuery.paddingOf(context).bottom + AppSpacing.xl;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: RefreshIndicator.adaptive(
          edgeOffset: embedded ? topPadding - 14.h : 0.0,
          displacement: 36.h,
          color: colors.primary,
          backgroundColor: colors.surface,
          strokeWidth: 2.5,
          onRefresh: controller.refreshLinks,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.depth == 0 &&
                  scroll.metrics.extentAfter <= 220 &&
                  controller.hasMore) {
                controller.loadMoreLinks();
              }
              return false;
            },
            child: CustomScrollView(
              key: const PageStorageKey<String>(
                'pos-linked-networks-scroll',
              ),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. الترويسة القيادية لشبكات التزويد المرتبطة
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
                                  final codeController =
                                      TextEditingController();
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
                                          final payload =
                                              codeController.text.trim();
                                          if (payload.isNotEmpty) {
                                            final res = await controller
                                                .previewChallenge(payload);
                                            previewRx.value = res;
                                          }
                                        },
                                        onConfirm: () async {
                                          if (previewRx.value != null) {
                                            await controller.confirmChallenge(
                                                previewRx.value!.challengeUuid);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              )
                            : null,
                      ),

                      // 2. شريط ملخص المؤشرات
                      Obx(
                        () => CommercialSummaryStrip(
                          isNetworkView: false,
                          totalCount: controller.totalCount,
                          activeCount: controller.activeCount,
                          inactiveCount: controller.inactiveCount,
                          isLoading: controller.isLoading.value &&
                              controller.links.isEmpty,
                          selectedStatus: controller.statusFilter.value,
                          onStatusTap: controller.setStatusFilter,
                        ),
                      ),

                      // 3. شريط البحث والتصفية
                      Obx(
                        () => CommercialSearchFilterHeader(
                          searchController: controller.searchController,
                          searchQuery: controller.searchQuery.value,
                          selectedStatus: controller.statusFilter.value,
                          onStatusChanged: controller.setStatusFilter,
                          onClearSearch: controller.searchController.clear,
                          searchHint: 'بحث باسم الشبكة، الهاتف، أو الرمز...',
                        ),
                      ),

                      // 4. منتقي نقاط البيع إذا كان المستخدم يملك أكثر من نقطة
                      Obx(() {
                        final posList = controller.authorizedPosList;
                        if (posList.length <= 1) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: CustomDropdown<int>(
                            label: 'تصفية بحسب نقطة البيع',
                            searchEnabled: false,
                            rxValue: controller.selectedPosId,
                            items: posList.map((pos) {
                              return DropdownItem<int>(
                                value: pos.posId,
                                child: Text(pos.posName),
                              );
                            }).toList(),
                            onChanged: controller.onPosFilterChanged,
                          ),
                        );
                      }),
                    ]),
                  ),
                ),

                // 5. محتوى القائمة
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.links.isEmpty) {
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.xs,
                        horizontalPadding,
                        bottomPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CustomStateView.loading(
                          presentation: CustomStatePresentation.skeletonOnly,
                          skeleton: CustomStateSkeleton(
                            layout: CustomStateSkeletonLayout.list,
                            itemCount: 3,
                            cardHeight: 140.h,
                            maxColumns: 1,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.errorMessage.value != null &&
                      controller.links.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            AppSpacing.lg,
                            horizontalPadding,
                            bottomPadding,
                          ),
                          child: CustomErrorState(
                            title: 'تعذر جلب شبكات التزويد المرتبطة',
                            subtitle: controller.errorMessage.value,
                            onRetry: controller.refreshLinks,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.links.isEmpty) {
                    final hasFilter = controller.statusFilter.value != null ||
                        controller.searchQuery.value.trim().isNotEmpty;

                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            AppSpacing.lg,
                            horizontalPadding,
                            bottomPadding,
                          ),
                          child: CustomEmptyState(
                            icon: hasFilter
                                ? Icons.search_off_rounded
                                : Icons.hub_outlined,
                            title: hasFilter
                                ? 'لا توجد نتائج مطابقة لبحثك'
                                : 'لا توجد شبكات تزويد مرتبطة بنقطة بيعك حالياً',
                            subtitle: hasFilter
                                ? 'جرّب تعديل كلمات البحث أو تصفية حالة النشاط.'
                                : 'قم بمسح رمز دعوة (QR) من مزود الشبكة لتفعيل تزويدك بالكروت.',
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      AppSpacing.xs,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    sliver: SliverList(
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
                                onToggleExpansion: () => controller
                                    .toggleAccordion(link.networkPosId),
                                onDelete: () =>
                                    controller.promptDeleteLink(link),
                                onTap: () {
                                  CustomBottomSheet.show<void>(
                                    title: 'ملف شبكة التزويد',
                                    subtitle: 'البيانات الرسمية للمزود المعتمد',
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
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
