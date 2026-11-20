import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/membership/presentation/controllers/pos_members_controller.dart';
import 'package:netsales/features/membership/presentation/widgets/member_card/member_card.dart';
import 'package:netsales/features/membership/presentation/widgets/members_search_filter_header.dart';
import 'package:netsales/features/membership/presentation/widgets/members_summary_strip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';

/// واجهة استعراض وإدارة أعضاء وموظفي نقطة البيع (PosMembersView)
///
/// ودجت عرض نقي 100% لمساحة عمل نقطة البيع (POS Workspace View)
class PosMembersView extends GetView<PosMembersController> {
  const PosMembersView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshMembers,
      scrollKey: const PageStorageKey<String>('pos-members-scroll'),
      slivers: [
        // 1. الترويسة القيادية لفريق نقطة البيع وشريط الملخص وفلاتر البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: 'فريق عمل نقطة البيع',
                subtitle:
                    'إدارة البائعين والمشغلين، تعيين الأدوار، والتحكم في صلاحيات الوصول للفرع.',
                icon: Icons.groups_rounded,
                action: CustomButton.primary(
                  text: 'إضافة عضو +',
                  icon: Icons.person_add_rounded,
                  shape: AppButtonShape.pill,
                  size: AppButtonSize.small,
                  onPressed: controller.openAddMemberSheet,
                ),
              ),

              Obx(
                () => MembersSummaryStrip(
                  totalCount: controller.totalMembersCount,
                  activeCount: controller.activeMembersCount,
                  suspendedCount: controller.suspendedMembersCount,
                  invitedCount: controller.invitedMembersCount,
                  isLoading:
                      controller.isLoading.value && controller.members.isEmpty,
                  selectedStatus: controller.statusFilter.value,
                  onStatusTap: controller.setStatusFilter,
                ),
              ),

              Obx(
                () => MembersSearchFilterHeader(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  selectedStatus: controller.statusFilter.value,
                  onStatusChanged: controller.setStatusFilter,
                  onClearSearch: controller.searchController.clear,
                ),
              ),

              // منتقي نقطة البيع في حال تعدد النقاط المصرح بها
              Obx(() {
                final posList = controller.authorizedPosList;
                if (posList.length <= 1) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CustomDropdown<int>(
                    label: 'تصفية بحسب نقطة البيع',
                    searchEnabled: false,
                    rxValue: controller.selectedPosId,
                    items: posList
                        .map(
                          (p) => DropdownItem<int>(
                            value: p.posId,
                            child: Text(p.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: controller.onPosChanged,
                  ),
                );
              }),
              AppSpacing.vSm,
            ],
          ),
        ),

        // 2. الحالات التفاعلية المركزية (تحميل أولي، خطأ، فراغ) أو قائمة الأعضاء
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final members = controller.filteredMembers;
          final isGlobalEmpty = controller.members.isEmpty;

          if (isLoading && isGlobalEmpty) {
            return const SliverToBoxAdapter(
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 4,
                  cardHeight: 100,
                  maxColumns: 1,
                  hasLeading: true,
                ),
              ),
            );
          }

          if (error != null && isGlobalEmpty) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'تعذر جلب فريق عمل نقطة البيع',
                subtitle: error,
                onRetry: controller.refreshMembers,
              ),
            );
          }

          if (members.isEmpty) {
            final hasFilter = controller.searchQuery.value.isNotEmpty ||
                controller.statusFilter.value != null;

            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: hasFilter
                    ? Icons.person_search_rounded
                    : Icons.group_off_rounded,
                title: hasFilter
                    ? 'لا يوجد أعضاء مطابقون للبحث'
                    : 'لا يوجد أعضاء مسجلون حالياً',
                subtitle: hasFilter
                    ? 'جرّب تعديل كلمات البحث أو تصفية الحالات المعروضة.'
                    : 'يمكنك إضافة بائعين وموظفين جدد لنقطة البيع وتحديد صلاحياتهم.',
                actionLabel: hasFilter
                    ? 'مسح عوامل التصفية'
                    : (controller.canManageMembers ? 'إضافة عضو جديد' : null),
                onAction: hasFilter
                    ? controller.resetFilters
                    : (controller.canManageMembers
                        ? controller.openAddMemberSheet
                        : null),
              ),
            );
          }

          final memberCount = members.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isOdd) return AppSpacing.vSm;
                final memberIndex = index ~/ 2;
                final member = members[memberIndex];

                return Obx(() {
                  final isExpanded = controller.expandedMemberId.value ==
                      member.userId;

                  return MemberCard(
                    key: ValueKey<String>('pos-member-${member.userId}'),
                    member: member,
                    isExpanded: isExpanded,
                    onToggleExpansion: () =>
                        controller.toggleAccordion(member.userId),
                    onUpdateRole: () =>
                        controller.openChangeRoleSheet(member),
                    onToggleStatus: () =>
                        controller.promptToggleMemberStatus(member),
                    onDelete: () =>
                        controller.promptRemoveMember(member),
                  );
                });
              },
              childCount: memberCount == 0 ? 0 : memberCount * 2 - 1,
            ),
          );
        }),
      ],
    );
  }
}
