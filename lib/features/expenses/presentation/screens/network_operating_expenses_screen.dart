import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
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

/// شاشة استعراض وإدارة المصروفات التشغيلية لمشغل الشبكة (Network Operating Expenses Screen)
class NetworkOperatingExpensesScreen
    extends GetView<NetworkOperatingExpensesController> {
  const NetworkOperatingExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    return CustomAppScaffold(
      appBarTitle: 'المصروفات التشغيلية',
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: RefreshIndicator.adaptive(
            displacement: 36.h,
            color: colors.primary,
            backgroundColor: colors.surface,
            strokeWidth: 2.5,
            onRefresh: controller.refreshExpenses,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (scroll.depth == 0 &&
                    scroll.metrics.extentAfter <= 220 &&
                    controller.hasMore) {
                  controller.loadMoreExpenses();
                }
                return false;
              },
              child: CustomScrollView(
                key: const PageStorageKey<String>('network-operating-expenses-scroll'),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      AppSpacing.md,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. الترويسة القيادية للمصروفات التشغيلية
                        CustomPageHeroCard(
                          title: 'المصروفات التشغيلية',
                          subtitle:
                              'تسجيل ومتابعة نفقات ومصروفات الشبكة مع الخصم السيادي التلقائي المباشر من المحفظة.',
                          icon: Icons.payments_outlined,
                          action: controller.canCreateExpense
                              ? CustomButton.primary(
                                  text: 'مصروف جديد +',
                                  icon: Icons.add_rounded,
                                  shape: AppButtonShape.pill,
                                  size: AppButtonSize.small,
                                  onPressed: controller.navigateToCreate,
                                )
                              : null,
                        ),

                        // 2. شريط ملخص المؤشرات
                        Obx(() {
                          final sum = controller.summary.value;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: ExpensesSummaryStrip(
                              totalCount: sum?.totalCount ?? controller.expenses.length,
                              totalAmount: sum?.totalAmount ?? 0.0,
                              thisMonthAmount: sum?.thisMonthAmount ?? 0.0,
                              todayAmount: sum?.todayAmount ?? 0.0,
                              isLoading: controller.isLoading.value,
                            ),
                          );
                        }),

                        // 3. ترويسة البحث
                        Obx(() {
                          return ExpensesSearchFilterHeader(
                            searchController: controller.searchController,
                            searchQuery: controller.searchQuery.value,
                            onClearSearch: () {
                              controller.searchController.clear();
                              controller.searchQuery.value = '';
                            },
                          );
                        }),

                        // 4. محدد الشبكة المتعددة
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
                      ]),
                    ),
                  ),

                  // 5. محتوى قائمة المصروفات
                  Obx(() {
                    if (controller.isLoading.value && controller.expenses.isEmpty) {
                      return SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverToBoxAdapter(
                          child: CustomStateView.loading(
                            presentation: CustomStatePresentation.skeletonOnly,
                            skeleton: CustomStateSkeleton(
                              layout: CustomStateSkeletonLayout.list,
                              itemCount: 4,
                              cardHeight: 160.h,
                              maxColumns: 1,
                            ),
                          ),
                        ),
                      );
                    }

                    if (controller.errorMessage.value != null && controller.expenses.isEmpty) {
                      return SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverToBoxAdapter(
                          child: CustomErrorState(
                            title: 'تعذر جلب المصروفات',
                            subtitle: controller.errorMessage.value,
                            onRetry: controller.refreshExpenses,
                          ),
                        ),
                      );
                    }

                    if (controller.expenses.isEmpty) {
                      return SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverToBoxAdapter(
                          child: CustomEmptyState(
                            icon: Icons.payments_outlined,
                            title: 'لا توجد مصروفات مسجلة',
                            subtitle: 'لم يتم تسجيل أي مصروفات تشغيلية لهذه الشبكة حتى الآن.',
                            actionLabel: controller.canCreateExpense ? 'تسجيل مصروف جديد' : null,
                            onAction: controller.canCreateExpense ? controller.navigateToCreate : null,
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        AppSpacing.xl,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == controller.expenses.length) {
                              return Obx(() {
                                if (controller.isLoadingMore.value) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                    child: Center(
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              });
                            }

                            final expense = controller.expenses[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.md),
                              child: Obx(() {
                                final isExpanded = controller.expandedExpenseId.value == expense.expenseId;
                                return ExpenseCard(
                                  expense: expense,
                                  isExpanded: isExpanded,
                                  onTap: () => controller.navigateToDetails(expense),
                                  onToggleExpansion: () => controller.toggleExpenseExpansion(expense.expenseId),
                                  canDelete: controller.canDeleteExpense,
                                  onDelete: () => controller.deleteExpense(expense.expenseId),
                                );
                              }),
                            );
                          },
                          childCount: controller.expenses.length + 1,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
