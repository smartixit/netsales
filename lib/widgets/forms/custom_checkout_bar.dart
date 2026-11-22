import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/forms/models/checkout_metric_data.dart';

export 'package:netsales/widgets/forms/models/checkout_metric_data.dart';

/// شريط ملخص الطلب والفوترة والتأكيد الثابت أسفل الشاشة (CustomCheckoutBar)
///
/// المرجع التصميمي المعتمد لجميع عمليات الشراء والإصدار المباشر:
/// - حماية كاملة ضد الإطارات العلوية والسفلية عبر [SafeArea].
/// - إطار علوي بحواف دائرية [AppRadius.lg] وظل علوي بارز.
/// - تكيف تلقائي مع مقاسات الشاشات (عمودي على الهواتف، وأفقي على الشاشات الأوسع).
/// - دعم صفوف القياس المالي (الإجمالي، الخصم، الصافي) مع عملة موحدة.
/// - دعم تنبيهات انتهاء الصلاحية [warningWidget] وحساب عدد الباقات والكروت.
class CustomCheckoutBar extends StatelessWidget {
  const CustomCheckoutBar({
    super.key,
    this.metrics = const [],
    this.customLeading,
    this.warningWidget,
    this.itemCount,
    this.itemCountLabel = 'باقة مختارة',
    this.unitCount,
    this.unitCountLabel = 'كرت',
    required this.actionLabel,
    this.actionIcon,
    this.isLoading = false,
    this.isActionEnabled = true,
    this.onAction,
    this.actionWidth,
  });

  final List<CheckoutMetricData> metrics;
  final Widget? customLeading;
  final Widget? warningWidget;
  final int? itemCount;
  final String itemCountLabel;
  final int? unitCount;
  final String unitCountLabel;
  final String actionLabel;
  final IconData? actionIcon;
  final bool isLoading;
  final bool isActionEnabled;
  final VoidCallback? onAction;
  final double? actionWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompact =
        MediaQuery.sizeOf(context).width <= AppBreakpoints.mobileMax;

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
            top: BorderSide(color: colors.outlineVariant.withValues(alpha: .4)),
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
            final leadingSection = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (warningWidget != null) ...[warningWidget!, AppSpacing.vXs],
                if (customLeading != null)
                  customLeading!
                else if (metrics.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      const chunkSize = 3;
                      final chunks = <List<CheckoutMetricData>>[];
                      for (var i = 0; i < metrics.length; i += chunkSize) {
                        chunks.add(
                          metrics.sublist(
                            i,
                            i + chunkSize > metrics.length
                                ? metrics.length
                                : i + chunkSize,
                          ),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var c = 0; c < chunks.length; c++) ...[
                            if (c > 0) SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                for (var i = 0; i < chunks[c].length; i++) ...[
                                  if (i > 0) AppSpacing.hXs,
                                  Expanded(
                                    child: _CheckoutMetricItem(
                                      metric: chunks[c][i],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  if (unitCount != null || itemCount != null) ...[
                    AppSpacing.vXs,
                    Row(
                      children: [
                        if (unitCount != null) ...[
                          Icon(
                            Icons.layers_rounded,
                            size: 16.r,
                            color: colors.primary,
                          ),
                          AppSpacing.hXs,
                          Text(
                            '$unitCount $unitCountLabel',
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (itemCount != null)
                          Text(
                            '$itemCount $itemCountLabel',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ],
            );

            final actionButton = CustomButton(
              text: actionLabel,
              icon: actionIcon,
              width: isCompact ? double.infinity : (actionWidth ?? 190),
              loading: isLoading,
              enabled: isActionEnabled,
              onPressed: isActionEnabled ? onAction : null,
            );

            if (isCompact) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [leadingSection, AppSpacing.vSm, actionButton],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: leadingSection),
                AppSpacing.hMd,
                actionButton,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CheckoutMetricItem extends StatelessWidget {
  const _CheckoutMetricItem({required this.metric});

  final CheckoutMetricData metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = metric.isDiscount
        ? colors.error
        : (metric.isNet ? colors.primary : colors.onSurface);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.label,
            style: AppTypography.caption.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 9.5.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metric.value,
                  style: AppTypography.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  metric.currency,
                  style: AppTypography.caption.copyWith(
                    color: textColor.withValues(alpha: .8),
                    fontSize: 8.5.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
