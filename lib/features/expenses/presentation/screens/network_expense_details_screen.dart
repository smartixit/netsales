import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_details_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_details/expense_details_action_bar.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_details/expense_details_attachment_card.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_details/expense_details_hero.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_details/expense_details_item_card.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_details/expense_details_metrics_strip.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة استعراض تفاصيل المصروف التشغيلي وسند الصرف والمرفقات
class NetworkExpenseDetailsScreen
    extends GetView<NetworkExpenseDetailsController> {
  const NetworkExpenseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الهيكلي (Skeleton Loading State)
      if (controller.isLoading.value && controller.expense.value == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل المصروف',
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 4,
                cardHeight: 140,
              ),
            ),
          ),
        );
      }

      final expense = controller.expense.value;

      // 2. حالة عدم العثور على المصروف
      if (expense == null) {
        return CustomAppScaffold(
          appBarTitle: 'تفاصيل المصروف',
          body: Center(
            child: CustomEmptyState(
              icon: Icons.payments_outlined,
              title: 'المصروف غير موجود',
              subtitle: 'تعذر العثور على بيانات المصروف المحدد أو تم حذفه.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final displayReference = expense.displayReference;

      // 3. عرض صفحة التفاصيل المتكاملة بالمعايير العالمية
      return CustomAppScaffold(
        appBarTitle: displayReference,
        showBackButton: true,
        bottomNavigationBar: ExpenseDetailsActionBar(controller: controller),
        body: RefreshIndicator.adaptive(
          color: colors.primary,
          backgroundColor: colors.surface,
          strokeWidth: 2.5,
          onRefresh: controller.refreshDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.cardPadding,
              AppSpacing.cardPadding,
              AppSpacing.cardPadding,
              AppSpacing.xl,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الترويسة القيادية بالعمق اللوني المتكيف
                    ExpenseDetailsHero(expense: expense),
                    AppSpacing.vMd,

                    // 2. شريط المؤشرات المالية والتشغيلية والتفقيط
                    ExpenseDetailsMetricsStrip(expense: expense),
                    AppSpacing.vLg,

                    // 3. عنوان قسم بنود المصروف
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18.r,
                          color: colors.primary,
                        ),
                        AppSpacing.hXs,
                        Expanded(
                          child: Text(
                            'بنود المصروف (${expense.items.length})',
                            style: AppTypography.titleMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vSm,

                    // 4. قائمة بطاقات بنود المصروف
                    if (expense.items.isEmpty)
                      Container(
                        padding: EdgeInsets.all(AppSpacing.cardPadding),
                        alignment: Alignment.center,
                        child: Text(
                          'لا توجد بنود تفصيلية مسجلة لهذا المصروف.',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      for (int i = 0; i < expense.items.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ExpenseDetailsItemCard(
                            item: expense.items[i],
                            index: i,
                          ),
                        ),

                    // 5. قسم المرفقات والوثائق إن وجدت
                    if (expense.attachments.isNotEmpty) ...[
                      AppSpacing.vLg,
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            size: 18.r,
                            color: colors.primary,
                          ),
                          AppSpacing.hXs,
                          Expanded(
                            child: Text(
                              'المرفقات والوثائق (${expense.attachments.length})',
                              style: AppTypography.titleMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      for (final att in expense.attachments)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ExpenseDetailsAttachmentCard(
                            attachment: att,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
