import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/cards/custom_metric_display_card.dart';
import 'package:netsales/widgets/indicators/custom_amount_to_words_banner.dart';

/// شريط المؤشرات المالية والتشغيلية المعتمد في شاشة تفاصيل الفاتورة
class InvoiceDetailsMetricsStrip extends StatelessWidget {
  const InvoiceDetailsMetricsStrip({super.key, required this.invoice});

  final InvoiceEntity invoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── شبكة البطاقات الإحصائية الأربع ──
        Row(
          children: [
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'إجمالي الفاتورة',
                  value: invoice.formattedTotalAmount,
                  icon: Icons.receipt_long_rounded,
                  accentColor: colors.primary,
                  isPrimary: true,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'المبلغ المسدد',
                  value: invoice.formattedPaidAmount,
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: colors.success,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'المتبقي للسداد',
                  value: invoice.formattedRemainingAmount,
                  icon: Icons.hourglass_bottom_rounded,
                  accentColor: invoice.remainingAmount > 0
                      ? colors.error
                      : colors.onSurfaceVariant,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'إجمالي الكروت',
                  value: invoice.totalVouchersCount.toString(),
                  unit: 'كرت',
                  icon: Icons.confirmation_number_outlined,
                  accentColor: colors.secondary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSm,

        // شريط تفقيط المبلغ المالي المعتمد
        CustomAmountToWordsBanner(
          amount: invoice.invoiceTotalAmount,
          currencyCode: 'YER',
        ),
      ],
    );
  }
}
