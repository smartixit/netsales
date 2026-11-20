import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
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
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// واجهة استعراض وإدارة نقاط البيع المرتبطة بشبكة التزويد (Network Workspace View)
class NetworkPosDirectoryView extends GetView<NetworkPosDirectoryController> {
  const NetworkPosDirectoryView({super.key, this.embedded = false});

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
                'network-pos-directory-scroll',
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
                      // 1. الترويسة القيادية لدليل نقاط البيع
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
                                  final challenge = await controller
                                      .createQrInvitation();
                                  if (challenge != null) {
                                    await CustomBottomSheet.show<void>(
                                      title: 'دعوة نقطة بيع عبر الرمز المشفر',
                                      subtitle: 'امسح الرمز أو انسخ كود الدعوة للارتباط المباشر',
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

                      // 2. شريط ملخص المؤشرات
                      Obx(
                        () => CommercialSummaryStrip(
                          isNetworkView: true,
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
                        ),
                      ),

                      // 4. منتقي شبكات المشغل إذا كان يملك أكثر من شبكة
                      Obx(() {
                        final networks = controller.authorizedNetworks;
                        if (networks.length <= 1) {
                          return const SizedBox.shrink();
                        }

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
                            title: 'تعذر جلب نقاط البيع المرتبطة',
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
                                : Icons.storefront_outlined,
                            title: hasFilter
                                ? 'لا توجد نتائج مطابقة لبحثك'
                                : 'لا توجد نقاط بيع مرتبطة بشبكتك حالياً',
                            subtitle: hasFilter
                                ? 'جرّب تعديل كلمات البحث أو إلغاء تصفية حالة النشاط التجاري.'
                                : 'ابدأ بتوليد رمز دعوة تجاري (QR) وشاركه مع نقاط البيع المعتمدة.',
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
                              () => NetworkPosCard(
                                link: link,
                                isExpanded: controller.expandedLinkId.value ==
                                    link.networkPosId,
                                onToggleExpansion: () => controller
                                    .toggleAccordion(link.networkPosId),
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
