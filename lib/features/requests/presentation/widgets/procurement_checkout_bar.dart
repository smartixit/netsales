import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_checkout_summary_metric.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';

/// ملخص الطلب وإرساله؛ يبقى ثابتاً ويعرض صفوف الإجمالي والخصم والصافي.
class ProcurementCheckoutBar extends GetView<PosNewProcurementOrderController> {
  const ProcurementCheckoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final gross = controller.checkoutGrossAmount;
      final discount = controller.checkoutDiscountAmount;
      final net = controller.checkoutNetAmount;
      final count = controller.checkoutTotalVouchers;
      final currency = controller.checkoutCurrency;
      final isCompact =
          MediaQuery.sizeOf(context).width <= AppBreakpoints.mobileMax;
      final summaryRows = Row(
        children: [
          Expanded(
            child: ProcurementCheckoutSummaryMetric(
              label: 'الإجمالي',
              value: AmountFormatter.formatValue(gross),
              currency: currency,
            ),
          ),
          AppSpacing.hXs,
          Expanded(
            child: ProcurementCheckoutSummaryMetric(
              label: 'الخصم',
              value: AmountFormatter.formatValue(discount),
              currency: currency,
              isDiscount: true,
            ),
          ),
          AppSpacing.hXs,
          Expanded(
            child: ProcurementCheckoutSummaryMetric(
              label: 'الصافي التقديري',
              value: AmountFormatter.formatValue(net),
              currency: currency,
              isNet: true,
            ),
          ),
        ],
      );

      return SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.sm,
            AppSpacing.cardPadding,
            AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            border: Border(
              top: BorderSide(
                color: colors.outlineVariant.withValues(alpha: .4),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .10),
                blurRadius: 22,
                offset: const Offset(0, -7),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final metrics = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.needsPricingRefresh) ...[
                    CustomStateView.pricingExpired(
                      title: controller.isRefreshingCartPricing.value
                          ? 'جارٍ تحديث التعرفة'
                          : 'انتهت صلاحية التعرفة',
                      subtitle: controller.isRefreshingCartPricing.value
                          ? 'نحدّث أسعار الباقات المختارة مع الحفاظ على كميات السلة.'
                          : controller.cartPricingRefreshError.value ??
                                'حدّث التعرفة الحالية قبل إرسال طلب التوريد.',
                      actionLabel: controller.isRefreshingCartPricing.value
                          ? 'جارٍ التحديث...'
                          : 'تحديث التعرفة',
                      presentation: CustomStatePresentation.compact,
                      onAction: controller.isRefreshingCartPricing.value
                          ? null
                          : controller.refreshNetworkPackages,
                    ),
                    AppSpacing.vXs,
                  ],
                  summaryRows,
                  AppSpacing.vXs,
                  Row(
                    children: [
                      Icon(
                        Icons.layers_rounded,
                        size: 16.r,
                        color: colors.primary,
                      ),
                      AppSpacing.hXs,
                      Text(
                        '$count كرت',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${controller.cartPackagesCount} باقة مختارة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              );
              final action = CustomButton(
                text: controller.isEditing.value
                    ? 'حفظ التعديلات'
                    : 'إرسال طلب التوريد',
                icon: Icons.send_rounded,
                width: isCompact ? double.infinity : 190,
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
                  children: [metrics, AppSpacing.vSm, action],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: metrics),
                  AppSpacing.hMd,
                  action,
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
