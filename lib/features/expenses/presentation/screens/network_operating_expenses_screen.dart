import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card.dart';
import 'package:netsales/features/expenses/presentation/widgets/expenses_search_filter_header.dart';
import 'package:netsales/features/expenses/presentation/widgets/expenses_summary_strip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// شاشة استعراض وإدارة المصروفات التشغيلية لمشغل الشبكة (Network Operating Expenses Screen)
class NetworkOperatingExpensesScreen
    extends GetView<NetworkOperatingExpensesController> {
  const NetworkOperatingExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      appBarTitle: 'المصروفات التشغيلية',
      body: CustomRefreshablePage.slivers(
        onRefresh: controller.refreshExpenses,
        scrollKey:
            const PageStorageKey<String>('network-operating-expenses-scroll'),
        onNotification: (scroll) {
          if (scroll.depth == 0 &&
              scroll.metrics.extentAfter <= 220 &&
              controller.hasMore) {
            controller.loadMoreExpenses();
          }
          return false;
        },
        slivers: [
          // 1. الترويسة وبطاقات الملخص وفلاتر البحث
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomPageHeroCard(
                  title: 'المصروفات التشغيلية',
                  subtitle:
                      'إدارة وتسجيل مصروفات الشبكة، تتبع بنود الصرف، والرقابة المالية المباشرة.',
                  icon: Icons.payments_rounded,
                  action: controller.canCreateExpense
                      ? CustomButton.primary(
                          text: 'تسجيل مصروف +',
                          icon: Icons.add_rounded,
                          shape: AppButtonShape.pill,
                          size: AppButtonSize.small,
                          onPressed: controller.navigateToCreate,
                        )
                      : null,
                ),
                Obx(() {
                  final sum = controller.summary.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: ExpensesSummaryStrip(
                      totalCount: sum?.totalCount ?? controller.expenses.length,
                      totalAmount: sum?.totalAmount ?? 0.0,
                      thisMonthAmount: sum?.thisMonthAmount ?? 0.0,
                      todayAmount: sum?.todayAmount ?? 0.0,
                      isLoading: controller.isLoading.value &&
                          controller.expenses.isEmpty,
                    ),
                  );
                }),
                Obx(
                  () => ExpensesSearchFilterHeader(
                    searchController: controller.searchController,
                    searchQuery: controller.searchQuery.value,
                    onClearSearch: () {
                      controller.searchController.clear();
                      controller.searchQuery.value = '';
                    },
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

          // 2. الحالات التفاعلية المركزية (تحميل أولي، خطأ، فراغ) أو القائمة
          Obx(() {
            if (controller.isLoading.value && controller.expenses.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomStateView.loading(
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: CustomStateSkeleton(
                    layout: CustomStateSkeletonLayout.list,
                    itemCount: 4,
                    cardHeight: 160.h,
                    maxColumns: 1,
                  ),
                ),
              );
            }

            if (controller.errorMessage.value != null &&
                controller.expenses.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomErrorState(
                  title: 'تعذر جلب المصروفات',
                  subtitle: controller.errorMessage.value,
                  onRetry: controller.refreshExpenses,
                ),
              );
            }

            if (controller.expenses.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomEmptyState(
                  icon: Icons.payments_outlined,
                  title: 'لا توجد مصروفات مسجلة',
                  subtitle:
                      'لم يتم تسجيل أي مصروفات تشغيلية لهذه الشبكة حتى الآن.',
                  actionLabel: controller.canCreateExpense
                      ? 'تسجيل مصروف جديد'
                      : null,
                  onAction: controller.canCreateExpense
                      ? controller.navigateToCreate
                      : null,
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final expense = controller.expenses[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Obx(() {
                      final isExpanded = controller.expandedExpenseId.value ==
                          expense.expenseId;
                      return ExpenseCard(
                        expense: expense,
                        isExpanded: isExpanded,
                        onTap: () => controller.navigateToDetails(expense),
                        onToggleExpansion: () => controller
                            .toggleExpenseExpansion(expense.expenseId),
                        canDelete: controller.canDeleteExpense,
                        onDelete: () =>
                            controller.deleteExpense(expense.expenseId),
                      );
                    }),
                  );
                },
                childCount: controller.expenses.length,
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
                onPressed: controller.loadMoreExpenses,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
