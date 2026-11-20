import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/membership/presentation/controllers/network_members_controller.dart';
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

/// واجهة استعراض وإدارة أعضاء وفريق شبكة التزويد (NetworkMembersView)
///
/// ودجت عرض نقي 100% لمساحة عمل الشبكة (Network Workspace View)
class NetworkMembersView extends GetView<NetworkMembersController> {
  const NetworkMembersView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshMembers,
      scrollKey: const PageStorageKey<String>('network-members-scroll'),
      slivers: [
        // 1. الترويسة القيادية لفريق الشبكة وشريط الملخص وفلاتر البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: 'فريق عمل الشبكة',
                subtitle:
                    'إدارة الموظفين، تحديد الصلاحيات التشغيلية، ومتابعة نشاط الأعضاء المعتمدين.',
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

              // منتقي الشبكة في حال تعدد الشبكات المصرح بها
              Obx(() {
                final networks = controller.authorizedNetworks;
                if (networks.length <= 1) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CustomDropdown<int>(
                    label: 'تصفية بحسب الشبكة',
                    searchEnabled: false,
                    rxValue: controller.selectedNetworkId,
                    items: networks
                        .map(
                          (n) => DropdownItem<int>(
                            value: n.networkId,
                            child: Text(n.networkName),
                          ),
                        )
                        .toList(),
                    onChanged: controller.onNetworkChanged,
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
                title: 'تعذر جلب فريق عمل الشبكة',
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
                    : 'يمكنك إضافة موظفين ومشغلين جدد للشبكة ومنحهم الصلاحيات المناسبة.',
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
                    key: ValueKey<String>('network-member-${member.userId}'),
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
