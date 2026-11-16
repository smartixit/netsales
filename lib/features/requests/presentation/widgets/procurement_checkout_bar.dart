import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط ملخص السلة وتقديم طلب التوريد.
class ProcurementCheckoutBar extends GetView<PosProcurementController> {
  const ProcurementCheckoutBar({super.key});

  @override
  /// شريط الدفع والإتمام المثبت في أسفل الشاشة (Sticky Bottom Checkout Bar)
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditMode = controller.isEditing.value;
      final cartLines = controller.procurementCart;
      final totalVouchers = cartLines.fold<int>(
        0,
        (sum, item) => sum + item.voucherCount,
      );
      final quote = controller.serverQuote.value;
      final quoteSummary = cartLines.isEmpty
          ? 'السلة فارغة'
          : controller.isLoadingQuote.value
              ? 'جاري احتساب السعر المعتمد...'
              : quote == null
                  ? (controller.getProcurementQuoteUseCase == null
                      ? 'سيحتسب الخادم السعر عند التقديم'
                      : 'عرض السعر غير متاح')
                  : AmountFormatter.format(quote.netTotal.toString());

      return Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.cardPadding,
          AppSpacing.sm,
          AppSpacing.cardPadding,
          AppSpacing.cardPadding + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth <=
                AppBreakpoints.mobileSmallMax + (AppSpacing.cardPadding * 2);

            final summary = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalVouchers > 0
                      ? '$totalVouchers كرت • ${cartLines.length} باقة'
                      : 'السلة فارغة',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  quoteSummary,
                  style: AppTypography.titleMedium.copyWith(
                    color: quote == null
                        ? colors.onSurfaceVariant
                        : colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );

            final submitButton = CustomButton(
              text: isEditMode ? 'حفظ تعديلات الطلب' : 'تقديم طلب التوريد',
              icon: isEditMode ? Icons.check_circle_rounded : Icons.send_rounded,
              width: isCompact ? double.infinity : null,
              loading: controller.isSubmitting.value,
              enabled: controller.canSubmitOrder,
              onPressed: controller.canSubmitOrder
                  ? controller.submitOrderAndClose
                  : null,
            );

            if (isCompact) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  summary,
                  AppSpacing.vSm,
                  submitButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: summary),
                AppSpacing.hMd,
                submitButton,
              ],
            );
          },
        ),
      );
    });
  }
}
