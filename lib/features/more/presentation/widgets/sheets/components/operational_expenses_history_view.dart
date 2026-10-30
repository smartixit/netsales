import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/features/more/presentation/widgets/sheets/components/expense_history_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// سجل المصروفات التشغيلية (OperationalExpensesHistoryView)
/// ============================================================================
/// ودجت تفاعلي مستقل يغطي كافة حالات الواجهة (تحميل / خطأ / فراغ / بيانات)
/// ويستمع لحالة [MoreController] عبر [Obx] دون أي منطق أعمال محلي.
class OperationalExpensesHistoryView extends StatelessWidget {
  const OperationalExpensesHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MoreController>();

    return Obx(() {
      final isLoading = controller.isLoadingExpenses.value;
      final errorMessage = controller.expensesErrorMessage.value;
      final expenses = controller.expenses;

      if (isLoading && expenses.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: const CustomSkeletonFeed(itemCount: 4, cardHeight: 90),
        );
      }

      if (errorMessage.isNotEmpty && expenses.isEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل سجل المصروفات',
          subtitle: errorMessage,
          onRetry: () => controller.loadExpenses(isRefresh: true),
        );
      }

      if (expenses.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: const CustomEmptyState(
            title: 'لا توجد مصروفات تشغيلية مسجلة حالياً.',
            subtitle: 'سجّل أول مصروف من تبويب «قيد مصروف جديد».',
          ),
        );
      }

      return Column(
        children: expenses
            .map(
              (expense) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: ExpenseHistoryCard(expense: expense),
              ),
            )
            .toList(),
      );
    });
  }
}
