import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_kpi_summary_strip.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_search_and_filter_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_segmented_header.dart';
import 'package:netsales/features/operations/presentation/widgets/sale_invoices_feed.dart';
import 'package:netsales/features/operations/presentation/widgets/voucher_requests_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class OperationsScreen extends GetView<OperationsController> {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            OperationsSegmentedHeader(controller: controller),
            AppSpacing.vSm,
            OperationsSearchAndFilterBar(controller: controller),
            AppSpacing.vSm,
            OperationsKpiSummaryStrip(controller: controller),
            AppSpacing.vSm,
            Expanded(
              child: Obx(() {
                if (controller.activeSegmentIndex.value == 0) {
                  return SaleInvoicesFeed(controller: controller);
                }
                return const VoucherRequestsFeed();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
