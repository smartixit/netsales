import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_network_scope_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

class NetworkOperatingExpensesScreen
    extends GetView<NetworkOperatingExpensesController> {
  const NetworkOperatingExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      appBarTitle: 'المصروفات التشغيلية',
      appBarSubtitle: 'سجل النفقات وبنود الصرف',
      actions: [
        if (controller.canCreate)
          Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: CustomButton.primary(
              text: 'مصروف جديد',
              prefix: Icons.add_rounded,
              onPressed: controller.navigateToCreateForm,
            ),
          ),
      ],
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          children: [
            ExpenseNetworkScopeHeader(controller: controller),
            AppSpacing.vMd,
            CustomTextField(
              controller: controller.searchTextController,
              label: 'بحث في المصروفات',
              hint: 'ابحث بوصف البند أو رقم المصروف',
              prefixIcon: const Icon(Icons.search_rounded),
              isRequired: false,
              onChanged: controller.onSearchChanged,
              onFieldSubmitted: (v) => controller.applyFilters(search: v),
            ),
            AppSpacing.vSm,
            Obx(
              () => CustomResultsCounterBar(
                count: controller.expenses.length,
                recordLabel: 'مصروف',
                isFiltered: controller.searchQuery.value.isNotEmpty ||
                    controller.fromDate.value != null ||
                    controller.toDate.value != null,
                isLoading: controller.isLoading.value && controller.expenses.isEmpty,
                onClear: controller.resetFilters,
              ),
            ),
            AppSpacing.vSm,
            Expanded(
              child: Obx(() {
                if (controller.isLoadingNetworks.value) {
                  return const CustomSkeletonFeed(itemCount: 3);
                }
                if (controller.networkError.value != null &&
                    controller.networks.isEmpty) {
                  return CustomErrorState.compact(
                    title: 'تعذر تحميل الشبكات',
                    subtitle: controller.networkError.value,
                    onRetry: controller.initializeNetworks,
                  );
                }
                if (controller.networks.isEmpty) {
                  return const CustomEmptyState.compact(
                    title: 'لا توجد شبكة متاحة',
                    subtitle: 'لا توجد شبكة مصرح بها لهذا الحساب.',
                  );
                }
                if (!controller.hasSelectedNetwork) {
                  return const CustomEmptyState.compact(
                    title: 'اختر الشبكة',
                    subtitle:
                        'حدد شبكة لعرض مصروفاتها. لا يتم اختيار شبكة تلقائياً عند تعدد الشبكات.',
                    icon: Icons.account_tree_outlined,
                  );
                }
                if (controller.isLoading.value && controller.expenses.isEmpty) {
                  return const CustomSkeletonFeed(itemCount: 5);
                }
                if (controller.error.value != null &&
                    controller.expenses.isEmpty) {
                  return CustomErrorState.compact(
                    title: 'تعذر تحميل المصروفات',
                    subtitle: controller.error.value,
                    onRetry: () => controller.loadExpenses(refresh: true),
                  );
                }
                if (controller.expenses.isEmpty) {
                  return CustomEmptyState(
                    title: 'لا توجد مصروفات مسجلة',
                    subtitle: 'ستظهر هنا سندات الصرف الخاصة بالشبكة المحددة.',
                    icon: Icons.receipt_long_outlined,
                    actionLabel:
                        controller.canCreate ? 'تسجيل أول مصروف' : null,
                    onAction: controller.canCreate
                        ? controller.navigateToCreateForm
                        : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => controller.loadExpenses(refresh: true),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >=
                              n.metrics.maxScrollExtent - 180 &&
                          controller.hasMore &&
                          !controller.isLoadingMore.value &&
                          controller.loadMoreError.value == null) {
                        controller.loadExpenses();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount: controller.expenses.length +
                          ((controller.hasMore ||
                                  controller.loadMoreError.value != null)
                              ? 1
                              : 0),
                      separatorBuilder: (_, _) => AppSpacing.vSm,
                      itemBuilder: (context, index) {
                        if (index == controller.expenses.length) {
                          if (controller.loadMoreError.value != null) {
                            return CustomErrorState.compact(
                              title: 'تعذر تحميل بقية السجلات',
                              subtitle: controller.loadMoreError.value,
                              onRetry: () {
                                controller.loadMoreError.value = null;
                                controller.loadExpenses();
                              },
                            );
                          }
                          return const CustomSkeletonFeed(itemCount: 1);
                        }
                        final expense = controller.expenses[index];
                        return ExpenseCard(
                          expense: expense,
                          onTap: () =>
                              controller.navigateToDetails(expense.expenseId),
                          onDelete: controller.canDelete
                              ? () => controller.confirmAndDeleteExpense(
                                    expense.expenseId,
                                  )
                              : null,
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
