import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expenses_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة المصروفات التشغيلية لمزود الشبكة (ExpensesScreen)
///
/// تجسد المعمارية المؤسسية النظيفة (Enterprise Clean Architecture):
/// - كلاس واحد في ملف واحد بمسؤولية واحدة واضحة (One Public Class Per File).
/// - واجهة تصريحية بحتة (Pure Declarative UI) خالية تماماً من منطق الأعمال والشروط المتفرعة.
/// - تستهلك متحكم المصروفات المباشر [NetworkExpensesController] الخاص بمزود الشبكة.
class ExpensesScreen extends GetView<NetworkExpensesController> {
  const ExpensesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: () => controller.loadExpenses(isRefresh: true),
      onLoadMore: controller.loadMoreExpenses,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey: const PageStorageKey<String>('expenses-scroll-key'),
      slivers: [
        // 1. ترويسة الصفحة وبطاقات المؤشرات والبحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: controller.pageTitle,
                subtitle: controller.pageSubtitle,
                icon: controller.pageIcon,
                action: controller.headerAction,
              ),

              Obx(
                () => CustomStatusSummaryStrip(
                  cards: controller.buildKpiCards(context),
                  isLoading:
                      controller.isLoading.value && controller.expenses.isEmpty,
                ),
              ),

              Obx(
                () => CustomSearchFilterBar<String?>(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  searchHint: controller.searchHint,
                  filterOptions: controller.buildFilterOptions(context),
                  onClearSearch: controller.searchController.clear,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. حالات القائمة (تحميل، خطأ، فراغ) أو عناصر المصروفات
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.expenses.isEmpty;
          final hasFilter = controller.searchQuery.value.trim().isNotEmpty;

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
                title: 'تعذر جلب المصروفات',
                subtitle: error,
                onRetry: () => controller.loadExpenses(isRefresh: true),
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: hasFilter
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                title: hasFilter
                    ? 'لا توجد مصروفات مطابقة للبحث'
                    : 'لا توجد مصروفات مسجلة حالياً',
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو رقم السند.'
                    : 'ستظهر هنا سندات المصروفات التشغيلية فور تسجيلها.',
                actionLabel: hasFilter ? 'مسح البحث' : null,
                onAction: hasFilter ? controller.resetFilters : null,
              ),
            );
          }

          final expenseCount = controller.expenses.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) return AppSpacing.vSm;
              final expenseIndex = index ~/ 2;
              final expense = controller.expenses[expenseIndex];

              final isExpanded =
                  controller.expandedExpenseId.value == expense.expenseId;

              return ExpenseCard(
                key: ValueKey<String>('expense-${expense.expenseId}'),
                expense: expense,
                isExpanded: isExpanded,
                onToggleExpand: () =>
                    controller.toggleExpenseExpansion(expense.expenseId),
                onDetails: () => controller.openExpenseDetails(expense),
                onPrint: () => controller.printExpense(expense),
                onShare: () => controller.shareExpense(expense),
                actions: controller.buildCardActions(context, expense),
              );
            }, childCount: expenseCount == 0 ? 0 : expenseCount * 2 - 1),
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
    );

    if (embedded) return content;

    return CustomAppScaffold(appBarTitle: controller.pageTitle, body: content);
  }
}
