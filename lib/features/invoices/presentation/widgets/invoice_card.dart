import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة عرض الفاتورة المالية في القوائم (Invoice Card)
class InvoiceCard extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback onTap;
  final bool isNetworkView;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
    this.isNetworkView = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final paymentPresentation =
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          invoice.paymentStatus,
        );
    final saleTypePresentation = EnumPresentationRegistry.resolveSaleType(
      invoice.saleType,
    );

    final partyLabel = isNetworkView ? 'نقطة البيع:' : 'المزود (الشبكة):';
    final partyName = isNetworkView
        ? (invoice.posName ?? 'نقطة بيع #${invoice.posId}')
        : (invoice.networkName ?? 'شبكة #${invoice.networkId}');

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppElevation.level1(context),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة البطاقة: رقم الفاتورة وحالة السداد
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.receipt_outlined,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    AppSpacing.hSm,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فاتورة #${invoice.invoiceUuid}',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (invoice.invoiceDate != null)
                          Text(
                            invoice.invoiceDate!.substring(0, 10),
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                CustomStatusBadge(
                  label:
                      invoice.paymentStatusLabel ?? paymentPresentation.label,
                  tone: paymentPresentation.tone,
                  icon: paymentPresentation.icon,
                ),
              ],
            ),

            AppSpacing.vSm,
            Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
            AppSpacing.vXs,

            // معلومات الطرف التجاري ونوع البيع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        partyLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.hXs,
                      Expanded(
                        child: Text(
                          partyName,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    invoice.saleTypeLabel ?? saleTypePresentation.label,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // ملخص المبالغ المالية
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي الفاتورة',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        AmountFormatter.format(
                          invoice.invoiceTotalAmount.toString(),
                        ),
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (invoice.remainingAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'المتبقي للسداد',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.error,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          AmountFormatter.format(
                            invoice.remainingAmount.toString(),
                          ),
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: colors.primary,
                          size: 16,
                        ),
                        AppSpacing.hXs,
                        Text(
                          'مسددة بالكامل',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
