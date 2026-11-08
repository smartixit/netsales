import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_debt_ledger_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/debt_aging_summary_widget.dart';
import 'package:netsales/features/finance/presentation/widgets/debt_scope_selector.dart';
import 'package:netsales/features/finance/presentation/widgets/outstanding_invoice_skeleton.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class PosDebtLedgerScreen extends GetView<PosDebtLedgerController> {
  const PosDebtLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('كشف الذمم والديون المستحقة')),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DebtScopeSelector(controller: controller),
              AppSpacing.vMd,
              Expanded(
                child: Obx(() {
                  if (!controller.hasSelectedScope) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 230,
                          child: CustomEmptyState(
                            icon: Icons.account_balance_wallet_outlined,
                            title: controller.selectedPosId.value == null &&
                                    controller.posOptions.length > 1
                                ? 'حدد نقطة البيع'
                                : 'حدد مزود الشبكة',
                            subtitle:
                                'لن يتم عرض ملخص الذمم أو الفواتير حتى يكتمل '
                                'تحديد نطاق الحساب.',
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final debtSummary = controller.summary.value;
                        if (debtSummary == null &&
                            controller.isLoading.value) {
                          return const CustomSkeletonFeed(itemCount: 1);
                        }
                        if (debtSummary == null &&
                            controller.summaryErrorMessage.value != null) {
                          return CustomErrorState.compact(
                            title: 'تعذر تحميل ملخص الذمم',
                            subtitle: controller.summaryErrorMessage.value,
                            onRetry: controller.loadDebtData,
                          );
                        }
                        if (debtSummary == null) return const SizedBox.shrink();

                        return DebtAgingSummaryWidget(
                          summary: debtSummary,
                          selectedBucket: controller.selectedBucket.value,
                          onBucketSelected: controller.onBucketSelected,
                        );
                      }),
                      AppSpacing.vMd,
                      Text(
                        'فواتير البيع الآجل غير المسددة (أولوية السداد FIFO)',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vSm,
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoadingInvoices.value &&
                              controller.outstandingInvoices.isEmpty) {
                            return const CustomSkeletonFeed(itemCount: 3);
                          }

                          if (controller.outstandingInvoices.isEmpty &&
                              controller.invoicesErrorMessage.value != null) {
                            return CustomErrorState.compact(
                              title: 'تعذر تحميل الفواتير المستحقة',
                              subtitle: controller.invoicesErrorMessage.value,
                              onRetry: () =>
                                  controller.loadInvoices(isRefresh: true),
                            );
                          }

                          if (controller.outstandingInvoices.isEmpty) {
                            return CustomEmptyState(
                              icon: Icons.check_circle_outline,
                              title: 'لا توجد فواتير مستحقة',
                              subtitle: controller.selectedBucket.value != null
                                  ? 'لا توجد أي فواتير مستحقة في هذه الشريحة العمرية المحددة.'
                                  : 'كافة فواتير المشتريات الآجلة مسددة بالكامل!',
                            );
                          }

                          return NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                      scrollInfo.metrics.maxScrollExtent - 200 &&
                                  controller.hasMore &&
                                  controller.invoicesErrorMessage.value == null &&
                                  !controller.isLoadingMore.value) {
                                controller.loadMoreInvoices();
                              }
                              return false;
                            },
                            child: ListView.builder(
                              itemCount:
                                  controller.outstandingInvoices.length +
                                  (controller.hasMore ||
                                          (controller.invoicesErrorMessage.value !=
                                                  null &&
                                              controller.outstandingInvoices
                                                  .isNotEmpty)
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index ==
                                    controller.outstandingInvoices.length) {
                                  if (controller.invoicesErrorMessage.value !=
                                      null) {
                                    return CustomErrorState.compact(
                                      title: 'تعذر تحميل المزيد من الفواتير',
                                      subtitle:
                                          controller.invoicesErrorMessage.value,
                                      onRetry: controller.hasMore
                                          ? controller.loadMoreInvoices
                                          : () => controller.loadInvoices(
                                                isRefresh: true,
                                              ),
                                    );
                                  }
                                  return const OutstandingInvoiceSkeleton();
                                }
                                if (index >
                                    controller.outstandingInvoices.length) {
                                  return const SizedBox.shrink();
                                }

                                final invoice =
                                    controller.outstandingInvoices[index];
                                return InvoiceCard(
                                  invoice: invoice,
                                  isNetworkView: false,
                                  onTap: () {
                                    Get.toNamed<void>(
                                      AppRoutes.purchaseInvoiceDetails,
                                      arguments: invoice,
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
