import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/network_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/controllers/pos_memberships_controller.dart';
import 'package:netsales/features/membership/presentation/flows/membership_presentation_coordinator.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_card.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_card_actions.dart';
import 'package:netsales/features/membership/presentation/widgets/membership_kpi_strip.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

/// واجهة استعراض وإدارة أعضاء مساحة العمل الموحدة (MembershipsScreen)
///
/// تجسد المعمارية المؤسسية النظيفة (Enterprise Clean Architecture):
/// - كلاس واحد في ملف واحد بمسؤولية واحدة واضحة (One Public Class Per File).
/// - واجهة تصريحية بحتة (Pure Declarative UI) خالية تماماً من منطق الأعمال والشروط المتفرعة.
/// - تعتمد نمط الاستراتيجية (Strategy Pattern) باستهلاك العقد المعماري الموحد [BaseMembershipsController].
class MembershipsScreen extends GetView<BaseMembershipsController> {
  const MembershipsScreen({super.key, this.embedded = false, this.isNetwork, this.controllerTag});

  final bool embedded;
  final bool? isNetwork;
  final String? controllerTag;

  @override
  BaseMembershipsController get controller {
    if (isNetwork == true) {
      return Get.find<NetworkMembershipsController>(tag: controllerTag);
    }
    if (isNetwork == false) {
      return Get.find<PosMembershipsController>(tag: controllerTag);
    }
    return super.controller;
  }

  @override
  Widget build(BuildContext context) {
    final actions = MembershipPresentationCoordinator(controller);
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshMembers,
      scrollKey: const PageStorageKey<String>('memberships-screen-scroll'),
      slivers: [
        // 1. ترويسة الصفحة وبطاقات المؤشرات والبحث والتصفية
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: controller.pageTitle,
                subtitle: controller.pageSubtitle,
                icon: controller.pageIcon,
                action: controller.canAddMember
                    ? CustomButton.primary(
                        text: 'إضافة عضو',
                        icon: Icons.person_add_alt_1_rounded,
                        shape: AppButtonShape.rounded,
                        size: AppButtonSize.small,
                        onPressed: actions.openAddMemberSheet,
                      )
                    : null,
              ),

              MembershipKpiStrip(controller: controller),

              Obx(
                () => CustomSearchFilterBar<String?>(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  searchHint: controller.searchHint,
                  selectedFilter: controller.statusFilter.value,
                  filterOptions: controller.buildFilterOptions(),
                  onFilterChanged: controller.setStatusFilter,
                  onClearSearch: controller.searchController.clear,
                ),
              ),

              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. حالات القائمة (تحميل، خطأ، فراغ) أو عناصر بطاقات الأعضاء
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.members.isEmpty;
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
                title: 'تعذر جلب قائمة الأعضاء',
                subtitle: error,
                onRetry: controller.refreshMembers,
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: hasFilter
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                title: hasFilter
                    ? 'لا يوجد أعضاء مطابقون'
                    : 'لا يوجد أعضاء مسجلون حالياً',
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                    : 'يمكنك البدء بإضافة أعضاء وتعيين أدوارهم وصلاحياتهم.',
                actionLabel: hasFilter ? 'مسح عوامل التصفية' : null,
                onAction: hasFilter ? controller.resetFilters : null,
              ),
            );
          }

          final memberCount = controller.members.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) return AppSpacing.vSm;
              final memberIndex = index ~/ 2;
              final member = controller.members[memberIndex];

              return Obx(() {
                final isExpanded =
                    controller.expandedMemberId.value == member.id;

                return MembershipCard(
                  key: ValueKey<String>('workspace-member-${member.id}'),
                  member: member,
                  isNetworkView: controller.isNetworkView,
                  isExpanded: isExpanded,
                  onToggleExpand: () => controller.toggleAccordion(member.id),
                  onDetails: () => actions.openMemberDetails(member),
                  actions: MembershipCardActions(
                    member: member,
                    isNetworkView: controller.isNetworkView,
                    onDetails: () => actions.openMemberDetails(member),
                    onMoreActions: () => actions.showMemberActions(member),
                    onChangeRole: controller.canChangeMemberRole && !member.isOwner
                        ? () => actions.openChangeRoleSheet(member)
                        : null,
                    onToggleStatus: controller.canChangeMemberStatus && !member.isOwner
                        ? () => actions.promptToggleMemberStatus(member)
                        : null,
                    onRemove: controller.canRemoveMember && !member.isOwner
                        ? () => actions.promptRemoveMember(member)
                        : null,
                  ),
                );
              });
            }, childCount: memberCount == 0 ? 0 : memberCount * 2 - 1),
          );
        }),
      ],
    );

    if (embedded) return content;

    return Obx(
      () => CustomAppScaffold(appBarTitle: controller.pageTitle, body: content),
    );
  }
}
