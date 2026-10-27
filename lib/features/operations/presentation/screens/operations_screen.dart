import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_kpi_summary_strip.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_search_and_filter_bar.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_segmented_header.dart';
import 'package:netsales/features/operations/presentation/widgets/sale_invoices_feed.dart';
import 'package:netsales/features/operations/presentation/widgets/voucher_requests_feed.dart';
import 'package:netsales/widgets/foundation/home_tab_shell.dart';

/// ============================================================================
/// شاشة مركز العمليات والمبيعات (OperationsScreen)
/// ============================================================================
/// مجمّع تركيبي رشيق (Lean Composite Assembler) لمركز العمليات والمبيعات الميدانية،
/// يربط الرصيف التبادلي التنفيذي، شريط النبض المالي ومسار التوريد،
/// ورصيف البحث والتصفية، وقوائم السجلات المستقلة، خالٍ تماماً من دوال البناء المساعدة.
class OperationsScreen extends GetView<OperationsController> {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeTabShell.fixed(
      useHorizontalPadding: true,
      child: Column(
        children: [
          // 1. الرصيف التبادلي التنفيذي مع زر الإجراء السياقي المباشر
          OperationsSegmentedHeader(controller: controller),
          AppSpacing.vSm,

          // 2. شريط النبض المالي ومسار التوريد التشغيلي المتكيف
          OperationsKpiSummaryStrip(controller: controller),
          AppSpacing.vSm,

          // 3. رصيف البحث والتصفية المتطورة
          OperationsSearchAndFilterBar(controller: controller),
          AppSpacing.vSm,

          // 4. الحاوية التفاعلية لقوائم العمليات والطلبات
          Expanded(
            child: Obx(() {
              if (controller.activeSegmentIndex.value == 0) {
                return SaleInvoicesFeed(controller: controller);
              }
              return VoucherRequestsFeed(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}
