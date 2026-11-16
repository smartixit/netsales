import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/procurement_request_details_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_original_items_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_original_request_amount_panel.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_invoice_callout.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_overview_panel.dart';
import 'package:netsales/features/requests/presentation/widgets/request_modification_summary_panel.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة تفاصيل الطلب: تنسيق الصفحة وربط أقسامها فقط.
class ProcurementRequestDetailsScreen
    extends GetView<ProcurementRequestDetailsController> {
  const ProcurementRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoading.value && controller.request.value == null) {
        return CustomAppScaffold(
          appBar: AppBar(title: const Text('تفاصيل طلب التوريد')),
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomSkeletonFeed(itemCount: 3),
          ),
        );
      }

      final request = controller.request.value;
      if (request == null) {
        return CustomAppScaffold(
          appBar: AppBar(title: const Text('تفاصيل طلب التوريد')),
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'الطلب غير موجود',
              subtitle: 'تعذر العثور على بيانات طلب التوريد المحدد.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            'طلب توريد #${request.requestUuid ?? request.requestId}',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            CustomButton.icon(
              icon: Icons.refresh_rounded,
              tooltip: 'تحديث التفاصيل',
              backgroundColor: Colors.transparent,
              foregroundColor: colors.onSurfaceVariant,
              onPressed: () => controller.loadRequestDetails(request.requestId),
            ),
            AppSpacing.hXs,
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () => controller.loadRequestDetails(request.requestId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProcurementRequestOverviewPanel(request: request),
                if (request.isApproved &&
                    request.modificationSummary != null) ...[
                  AppSpacing.vMd,
                  RequestModificationSummaryPanel(
                    summary: request.modificationSummary!,
                  ),
                ],
                if (request.isApproved && request.invoiceId != null) ...[
                  AppSpacing.vMd,
                  ProcurementRequestInvoiceCallout(
                    onOpenInvoice: controller.openLinkedInvoice,
                  ),
                ],
                AppSpacing.vLg,
                ProcurementOriginalItemsSection(items: request.items),
                AppSpacing.vLg,
                ProcurementOriginalRequestAmountPanel(
                  amount: request.requestTotalAmount,
                ),
                AppSpacing.vXl,
              ],
            ),
          ),
        ),
      );
    });
  }
}
