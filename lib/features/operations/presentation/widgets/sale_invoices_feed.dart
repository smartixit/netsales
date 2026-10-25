import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sale_invoice_card.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// قائمة تدفق فواتير المبيعات (SaleInvoicesFeed)
/// ============================================================================
/// تدير حالات التحميل، الفراغ، الخطأ، وعرض قائمة الفواتير التفاعلية.
class SaleInvoicesFeed extends StatelessWidget {
  final OperationsController controller;

  const SaleInvoicesFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل الأولي (الهيكل التشكيلي الموحد)
      if (controller.isLoadingInvoices.value && controller.invoices.isEmpty) {
        return const CustomSkeletonFeed(itemCount: 4, cardHeight: 110);
      }

      // 2. حالة الخطأ مع إمكانية إعادة المحاولة (الودجت الموحد)
      if (controller.invoicesErrorMessage.isNotEmpty &&
          controller.invoices.isEmpty) {
        return CustomErrorState(
          title: 'تعذر تحميل الفواتير',
          subtitle: controller.invoicesErrorMessage.value,
          onRetry: () => controller.loadInvoices(),
        );
      }

      // 3. حالة الفراغ (الودجت الموحد) مع إمكانية إصدار فاتورة فوراً
      if (controller.invoices.isEmpty) {
        return CustomEmptyState(
          title: 'لا توجد فواتير مبيعات مسجلة',
          subtitle: 'لم يتم العثور على أي فواتير تطابق معايير التصفية والبحث المحددة',
          actionLabel: 'إصدار فاتورة جديدة',
          onAction: () => CreateSaleInvoiceSheet.show(context),
        );
      }

      // 4. حالة النجاح وعرض قائمة الفواتير مع السحب للتحديث
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadInvoices(isRefresh: true),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xs,
          ),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: controller.invoices.length,
          separatorBuilder: (_, __) => AppSpacing.vSm,
          itemBuilder: (context, index) {
            final invoice = controller.invoices[index];
            return SaleInvoiceCard(
              invoice: invoice,
              onTap: () => Get.toNamed(
                AppRoutes.saleInvoiceDetails,
                arguments: invoice.invoiceId,
              ),
            );
          },
        ),
      );
    });
  }
}
