import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/pos_debt_ledger_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/debt_aging_summary_widget.dart';
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
        onRefresh: controller.loadDebtData,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final sum = controller.summary.value;
                if (sum == null && controller.isLoading.value) {
                  return const CustomSkeletonFeed(itemCount: 1);
                }
                if (sum == null &&
                    controller.summaryErrorMessage.value != null) {
                  return CustomErrorState.compact(
                    title: 'تعذر تحميل ملخص الذمم',
                    subtitle: controller.summaryErrorMessage.value,
                    onRetry: controller.loadDebtData,
                  );
                }
                if (sum == null) return const SizedBox.shrink();

                return DebtAgingSummaryWidget(
                  summary: sum,
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
                      onRetry: () => controller.loadInvoices(isRefresh: true),
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
                          (controller.hasMore ? 1 : 0) +
                          (controller.invoicesErrorMessage.value != null &&
                                  controller.outstandingInvoices.isNotEmpty
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.outstandingInvoices.length) {
                          if (controller.invoicesErrorMessage.value != null) {
                            return CustomErrorState.compact(
                              title: 'تعذر تحميل المزيد من الفواتير',
                              subtitle: controller.invoicesErrorMessage.value,
                              onRetry: controller.loadMoreInvoices,
                            );
                          }
                          return const OutstandingInvoiceSkeleton();
                        }
                        if (index > controller.outstandingInvoices.length) {
                          return const SizedBox.shrink();
                        }

                        final invoice = controller.outstandingInvoices[index];
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
          ),
        ),
      ),
    );
  }
}
