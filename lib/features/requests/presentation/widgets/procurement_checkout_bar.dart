import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// ملخص الطلب وإرساله؛ يبقى ثابتاً ويعرض صفوف الإجمالي والخصم والصافي.
class ProcurementCheckoutBar extends GetView<PosProcurementController> {
  const ProcurementCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final lines = controller.procurementCart;
      final quote = controller.serverQuote.value;
      final count = lines.fold<int>(0, (sum, line) => sum + line.voucherCount);
      final currency = quote?.currency ?? 'ر.ي';
      final quoteReady = controller.hasCurrentServerQuote && quote != null;
      final estimate = lines.fold<(double, double, double)>((0, 0, 0), (sum, line) {
        final custom = controller.discountForPackage(line.package.packageId);
        final base = custom?.originalPackagePrice ?? (line.package.procurementBaseUnitPriceMinor != null ? line.package.procurementBaseUnitPriceMinor! / 100 : line.package.packageVoucherPrice);
        final unit = controller.selectedSaleType.value == SaleType.cash
            ? (custom?.effectiveCashPrice ??
                (line.package.procurementCashUnitPriceMinor != null
                    ? line.package.procurementCashUnitPriceMinor! / 100
                    : line.package.effectiveCashPrice))
            : (custom?.effectiveCreditPrice ??
                (line.package.procurementCreditUnitPriceMinor != null
                    ? line.package.procurementCreditUnitPriceMinor! / 100
                    : line.package.effectiveCreditPrice));
        final gross = base * line.voucherCount;
        final net = unit * line.voucherCount;
        return (sum.$1 + gross, sum.$2 + (gross - net), sum.$3 + net);
      });
      final quoteExpired = quote?.expiresAt != null &&
          !DateTime.now().isBefore(quote!.expiresAt!);
      final isCompact = MediaQuery.sizeOf(context).width <= AppBreakpoints.mobileMax;
      final gross = quoteReady ? quote.grossTotal : estimate.$1;
      final discount = quoteReady ? quote.discountTotal : estimate.$2;
      final net = quoteReady ? quote.netTotal : estimate.$3;
      final summaryRows = Row(
        children: [
          Expanded(child: _SummaryMetric(label: 'الإجمالي', value: AmountFormatter.formatValue(gross), currency: currency)),
          AppSpacing.hXs,
          Expanded(child: _SummaryMetric(label: 'الخصم', value: AmountFormatter.formatValue(discount), currency: currency, isDiscount: true)),
          AppSpacing.hXs,
          Expanded(child: _SummaryMetric(label: 'الصافي التقديري', value: AmountFormatter.formatValue(net), currency: currency, isNet: true)),
        ],
      );

      return SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(AppSpacing.cardPadding, AppSpacing.sm, AppSpacing.cardPadding, AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            border: Border(top: BorderSide(color: colors.outlineVariant.withValues(alpha: .4))),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .10), blurRadius: 22, offset: const Offset(0, -7))],
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            final metrics = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quoteExpired && !controller.isQuotePending.value) ...[
                  CustomStateView.pricingExpired(
                    presentation: CustomStatePresentation.compact,
                    onAction: controller.fetchServerQuote,
                  ),
                  AppSpacing.vXs,
                ],
                summaryRows,
                AppSpacing.vXs,
                Row(children: [
                  Icon(Icons.layers_rounded, size: 16.r, color: colors.primary),
                  AppSpacing.hXs,
                  Text('$count كرت', style: AppTypography.labelMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('${lines.length} باقة مختارة', style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                ]),
              ],
            );
            final action = CustomButton(
              text: controller.isEditing.value ? 'حفظ التعديلات' : 'إرسال طلب التوريد',
              icon: Icons.send_rounded,
              width: isCompact ? double.infinity : 190,
              loading: controller.isSubmitting.value,
              enabled: controller.canSubmitOrder,
              onPressed: controller.canSubmitOrder ? controller.submitOrderAndClose : null,
            );
            if (isCompact) {
              return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                metrics,
                AppSpacing.vSm,
                action,
              ]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: metrics),
              AppSpacing.hMd,
              action,
            ]);
          }),
        ),
      );
    });
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.currency,
    this.isDiscount = false,
    this.isNet = false,
  });

  final String label;
  final String value;
  final String currency;
  final bool isDiscount;
  final bool isNet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = isNet ? colors.primary : (isDiscount ? colors.tertiary : colors.onSurface);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isNet ? colors.primary.withValues(alpha: .08) : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: isNet ? colors.primary.withValues(alpha: .24) : colors.outlineVariant.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w700)),
          AppSpacing.vXxs,
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: AppTypography.titleSmall.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Text(currency, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
