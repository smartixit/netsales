import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_account_creation_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_account_profile_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_entitlements_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_financial_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_invoice_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_plan_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_subscription_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_collection_status_options.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// Composition-only content for the billing workspace.
class BillingWorkspaceContent extends StatelessWidget {
  const BillingWorkspaceContent({
    super.key,
    required this.controller,
  });

  final BillingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.account.value == null) {
        return const CustomSkeletonFeed(itemCount: 4, shrinkWrap: true);
      }

      if (controller.errorMessage.value != null &&
          controller.account.value == null) {
        return CustomErrorState.boxed(
          title: 'تعذر تحميل مساحة الفوترة',
          subtitle: controller.errorMessage.value,
          onRetry: controller.load,
        );
      }

      final account = controller.account.value;
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الاشتراك والفوترة',
                    style: AppTypography.titleLarge,
                  ),
                ),
                CustomButton.outline(
                  text: 'تحديث',
                  prefix: Icons.refresh_rounded,
                  loading: controller.isLoading.value,
                  onPressed:
                      controller.isLoading.value ? null : controller.load,
                ),
              ],
            ),
            if (controller.errorMessage.value != null)
              CustomErrorState.compact(
                title: 'تعذر إكمال العملية',
                subtitle: controller.errorMessage.value,
                onRetry: controller.load,
              ),
            if (account == null) ...[
              BillingAccountCreationSection(controller: controller),
            ] else ...[
              BillingAccountProfileSection(
                controller: controller,
                account: account,
              ),
              BillingPlanSection(controller: controller),
              BillingSubscriptionSection(controller: controller),
              BillingEntitlementsSection(controller: controller),
              BillingInvoiceSection(controller: controller),
              BillingFinancialSection(
                title: 'الإشعارات الدائنة',
                emptyTitle: 'لا توجد إشعارات دائنة',
                page: controller.creditNotesPage,
                onLoadMore: controller.loadMoreCreditNotes,
                loadMoreLabel: 'تحميل المزيد من الإشعارات الدائنة',
                referenceKey: 'credit_note_number',
                fallbackTitle: 'إشعار دائن',
                amountKey: 'total',
                filterState: controller.creditNotesFilter,
                statusOptions: BillingCollectionStatusOptions.build(
                  controller.creditNotesFilter.statusValues,
                ),
                onSearchChanged: controller.searchCreditNotes,
                onStatusChanged: controller.setCreditNoteStatus,
                onRefresh: controller.refreshCreditNotes,
                searchHint: 'ابحث برقم الإشعار أو سببه',
              ),
              BillingFinancialSection(
                title: 'الاستردادات',
                emptyTitle: 'لا توجد استردادات',
                page: controller.refundsPage,
                onLoadMore: controller.loadMoreRefunds,
                loadMoreLabel: 'تحميل المزيد من الاستردادات',
                referenceKey: 'refund_reference',
                fallbackTitle: 'استرداد',
                amountKey: 'amount',
                filterState: controller.refundsFilter,
                statusOptions: BillingCollectionStatusOptions.build(
                  controller.refundsFilter.statusValues,
                ),
                onSearchChanged: controller.searchRefunds,
                onStatusChanged: controller.setRefundStatus,
                onRefresh: controller.refreshRefunds,
                searchHint: 'ابحث بمرجع الاسترداد أو سببه',
              ),
              BillingFinancialSection(
                title: 'المدفوعات',
                emptyTitle: 'لا توجد مدفوعات',
                page: controller.paymentsPage,
                onLoadMore: controller.loadMorePayments,
                loadMoreLabel: 'تحميل المزيد من المدفوعات',
                referenceKey: 'payment_reference',
                fallbackTitle: 'دفعة',
                amountKey: 'amount_minor',
                filterState: controller.paymentsFilter,
                statusOptions: BillingCollectionStatusOptions.build(
                  controller.paymentsFilter.statusValues,
                ),
                onSearchChanged: controller.searchPayments,
                onStatusChanged: controller.setPaymentStatus,
                onRefresh: controller.refreshPayments,
                searchHint: 'ابحث بمرجع الدفعة أو مرجع التحويل أو الفاتورة',
              ),
            ],
          ],
        ),
      );
    });
  }
}
