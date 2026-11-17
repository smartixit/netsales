import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

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
      final isCompact = MediaQuery.sizeOf(context).width <= AppBreakpoints.mobileMax;
      final summaryRows = <Widget>[
        _SummaryRow(label: 'الإجمالي قبل الخصم', value: quoteReady ? AmountFormatter.formatValue(quote.grossTotal) : '—', currency: currency),
        _SummaryRow(label: 'إجمالي الخصم', value: quoteReady ? AmountFormatter.formatValue(quote.discountTotal) : '—', currency: currency, isDiscount: true),
        _SummaryRow(label: 'صافي الطلب التقديري', value: quoteReady ? AmountFormatter.formatValue(quote.netTotal) : (controller.isQuotePending.value || controller.isLoadingQuote.value ? 'جارٍ تحديث العرض…' : 'بانتظار عرض السعر'), currency: currency, isEmphasized: true),
      ];

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
                ...summaryRows,
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, required this.currency, this.isDiscount = false, this.isEmphasized = false});
  final String label, value, currency;
  final bool isDiscount, isEmphasized;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(children: [
        Expanded(child: Text(label, style: (isEmphasized ? AppTypography.labelLarge : AppTypography.labelSmall).copyWith(color: isEmphasized ? colors.onSurface : colors.onSurfaceVariant, fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w600))),
        Text(value, style: (isEmphasized ? AppTypography.titleSmall : AppTypography.labelMedium).copyWith(color: isDiscount ? colors.tertiary : (isEmphasized ? colors.primary : colors.onSurface), fontWeight: FontWeight.w900)),
        AppSpacing.hXxs,
        Text(currency, style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant)),
      ]),
    );
  }
}
