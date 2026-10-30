import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/features/operations/presentation/widgets/sale_invoice_ledger_tile.dart';
import 'package:netsales/features/operations/presentation/widgets/sheets/create_sale_invoice_sheet.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';

/// ============================================================================
/// قائمة تدفق فواتير المبيعات بالسجل السيادي المصنف (SaleInvoicesFeed)
/// ============================================================================
/// تعرض فواتير المبيعات مجمعة زمنياً داخل أسطح مالية متصلة ومفتوحة
/// مما يضاعف مساحة الرؤية ويمنح تجربة تصفح هادئة ومريحة للعين.
class SaleInvoicesFeed extends StatelessWidget {
  final OperationsController controller;

  const SaleInvoicesFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // 1. حالة التحميل (الهيكل التشكيلي الموحد المتوافق تماماً في الحجم والهوامش)
      if (controller.isLoadingInvoices.value) {
        return const CustomSkeletonFeed(
          itemCount: 4,
          cardHeight: 110,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
        );
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

      // 3. حالة الفراغ الموحدة
      if (controller.invoices.isEmpty) {
        return CustomEmptyState(
          title: 'لا توجد فواتير مبيعات مسجلة',
          subtitle:
              'لم يتم العثور على أي فواتير تطابق معايير التصفية والبحث المحددة',
          actionLabel: 'إصدار فاتورة جديدة',
          onAction: () => CreateSaleInvoiceSheet.show(context),
        );
      }

      // تجميع الفواتير زمنياً عبر المتحكم المعتمد
      final groups = controller.groupedInvoices;
      final groupKeys = groups.keys.toList();

      // 4. السجل المالي المصنف زمنياً مع السحب للتحديث
      return RefreshIndicator(
        color: colors.primary,
        onRefresh: () => controller.loadInvoices(isRefresh: true),
        child: ListView.separated(
          padding: EdgeInsets.only(top: AppSpacing.xs, bottom: 130.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemCount: groupKeys.length,
          separatorBuilder: (_, __) => AppSpacing.vSm,
          itemBuilder: (context, groupIndex) {
            final key = groupKeys[groupIndex];
            final groupItems = groups[key]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ترويسة المجموعة الزمنية
                Padding(
                  padding: EdgeInsets.only(
                    bottom: AppSpacing.xs,
                    right: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Text(
                        key,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.sp,
                        ),
                      ),
                      AppSpacing.hXs,
                      Text(
                        '(${groupItems.length})',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // بطاقات الفواتير المستقلة الفاخرة بنمط الأكورديون الحصري
                ...groupItems.map(
                  (invoice) => Obx(
                    () => SaleInvoiceLedgerTile(
                      key: ValueKey(invoice.invoiceId),
                      invoice: invoice,
                      isExpanded:
                          controller.expandedInvoiceId.value ==
                          invoice.invoiceId,
                      onToggleExpand: () =>
                          controller.toggleInvoiceExpansion(invoice.invoiceId),
                      onTap: () => controller.openInvoiceDetails(invoice.invoiceId),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
