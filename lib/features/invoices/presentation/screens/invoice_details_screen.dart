import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/presentation/controllers/invoice_details_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_item_row.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة استعراض تفاصيل الفاتورة وبنودها والعمليات المستندية (Invoice Details Screen)
class InvoiceDetailsScreen extends GetView<InvoiceDetailsController> {
  final bool isNetworkPerspective;

  const InvoiceDetailsScreen({super.key, this.isNetworkPerspective = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoading.value && controller.invoice.value == null) {
        return CustomAppScaffold(
          appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomSkeletonFeed(itemCount: 3),
          ),
        );
      }

      final invoice = controller.invoice.value;
      if (invoice == null) {
        return CustomAppScaffold(
          appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
          body: Center(
            child: CustomEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'الفاتورة غير موجودة',
              subtitle: 'تعذر العثور على بيانات الفاتورة المحددة.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      final paymentPresentation =
          EnumPresentationRegistry.resolveInvoicePaymentStatus(
            invoice.paymentStatus,
          );
      final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
        invoice.saleType,
      );

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text('فاتورة #${invoice.invoiceId}'),
          actions: [
            // زر الطباعة
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'طباعة الفاتورة',
              onPressed: controller.printInvoice,
            ),
            // زر المشاركة
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'مشاركة الفاتورة',
              onPressed: controller.shareInvoice,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => controller.loadInvoiceDetails(invoice.invoiceId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. بطاقة ترويسة الفاتورة والحالة السيادية
                Container(
                  padding: EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فاتورة مبيعات معتمدة',
                                style: AppTypography.titleMedium.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (invoice.invoiceUuid != null)
                                Text(
                                  invoice.invoiceUuid!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                          CustomStatusBadge(
                            label:
                                invoice.paymentStatusLabel ??
                                paymentPresentation.label,
                            tone: paymentPresentation.tone,
                            icon: paymentPresentation.icon,
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Divider(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      AppSpacing.vXs,
                      _buildInfoRow(
                        'تاريخ الإصدار:',
                        invoice.invoiceDate ?? invoice.createdAt ?? '-',
                        context,
                      ),
                      _buildInfoRow(
                        'نوع البيع:',
                        invoice.saleTypeLabel ?? saleTypePresentation.label,
                        context,
                      ),
                      if (invoice.requestId != null)
                        InkWell(
                          onTap: () {
                            Get.toNamed<void>(
                              AppRoutes.voucherRequestDetails,
                              arguments: invoice.requestId,
                            );
                          },
                          child: _buildInfoRow(
                            'طلب التوريد المرتبط:',
                            'طلب #${invoice.requestId} (عرض)',
                            context,
                            isHighlight: true,
                          ),
                        ),
                    ],
                  ),
                ),

                AppSpacing.vMd,

                // 2. بطاقة الأطراف التجارية (المزود ونقطة البيع)
                Container(
                  padding: EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أطراف المعاملة التجارية',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vSm,
                      _buildInfoRow(
                        'المزود (الشبكة):',
                        invoice.networkName ?? 'شبكة #${invoice.networkId}',
                        context,
                      ),
                      _buildInfoRow(
                        'العميل (نقطة البيع):',
                        invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                        context,
                      ),
                      if (invoice.posPhoneNumber != null)
                        _buildInfoRow(
                          'هاتف نقطة البيع:',
                          invoice.posPhoneNumber!,
                          context,
                        ),
                    ],
                  ),
                ),

                AppSpacing.vMd,

                // 3. جدول بنود الفاتورة
                Text(
                  'بنود الفاتورة (${invoice.items.length})',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vXs,

                // رأس جدول البنود
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'الباقة',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'الكمية',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'الخصم',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'الإجمالي',
                          textAlign: TextAlign.end,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vXs,

                if (invoice.items.isEmpty)
                  Container(
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    alignment: Alignment.center,
                    child: Text(
                      'لا توجد بنود تفصيلية معروضة لهذه الفاتورة.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invoice.items.length,
                    separatorBuilder: (context, index) => AppSpacing.vXs,
                    itemBuilder: (context, index) {
                      return InvoiceItemRow(
                        item: invoice.items[index],
                        index: index,
                      );
                    },
                  ),

                AppSpacing.vLg,

                // 4. ملخص المبالغ المالية السيادية
                Container(
                  padding: EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي الفاتورة:',
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AmountFormatter.format(
                              invoice.invoiceTotalAmount.toString(),
                            ),
                            style: AppTypography.titleLarge.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ المسدد:',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            AmountFormatter.format(
                              invoice.paidAmount.toString(),
                            ),
                            style: AppTypography.bodyMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vXs,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ المتبقي للسداد:',
                            style: AppTypography.bodyMedium.copyWith(
                              color: invoice.remainingAmount > 0
                                  ? colors.error
                                  : colors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AmountFormatter.format(
                              invoice.remainingAmount.toString(),
                            ),
                            style: AppTypography.titleMedium.copyWith(
                              color: invoice.remainingAmount > 0
                                  ? colors.error
                                  : colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AppSpacing.vLg,

                // 5. زر تصدير الفاتورة كـ PDF
                CustomButton(
                  text: 'تصدير وحفظ الفاتورة كـ PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: controller.exportPdf,
                ),

                AppSpacing.vXl,
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(
    String label,
    String value,
    BuildContext context, {
    bool isHighlight = false,
  }) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: isHighlight ? colors.primary : colors.onSurface,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
