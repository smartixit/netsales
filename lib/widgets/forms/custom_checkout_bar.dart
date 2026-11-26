import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/forms/models/checkout_metric_data.dart';
import 'package:netsales/widgets/indicators/custom_amount_to_words_banner.dart';

export 'package:netsales/widgets/forms/models/checkout_metric_data.dart';

/// شريط ملخص الطلب والفوترة والتأكيد الثابت أسفل الشاشة (CustomCheckoutBar)
///
/// المرجع التصميمي المعتمد القابل لإعادة الاستخدام في كافة شاشات النماذج والعمليات:
/// - حماية كاملة ضد الإطارات العلوية والسفلية عبر [SafeArea].
/// - إطار علوي بحواف دائرية [AppRadius.lg] وظل علوي بارز.
/// - تكيف تلقائي مع مقاسات الشاشات (عمودي على الهواتف، وأفقي على الشاشات الأوسع).
/// - دعم صفوف القياس المالي (الإجمالي، الخصم، الصافي) مع عملة موحدة.
/// - دعم تفقيط المبلغ المالي [amountForWords] عبر [CustomAmountToWordsBanner].
/// - دعم زر إجراء رئيسي مع زر ثانوي اختياري أو أزرار مخصصة [customActions].
class CustomCheckoutBar extends StatelessWidget {
  const CustomCheckoutBar({
    super.key,
    this.metrics = const [],
    this.customLeading,
    this.warningWidget,
    this.amountForWords,
    this.currencyCode = 'YER',
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
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customActions,
    this.maxContentWidth,
  });

  final List<CheckoutMetricData> metrics;
  final Widget? customLeading;
  final Widget? warningWidget;
  final double? amountForWords;
  final String currencyCode;
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
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final List<Widget>? customActions;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompact =
        MediaQuery.sizeOf(context).width <= AppBreakpoints.mobileMax;
    final hasLeading =
        warningWidget != null ||
        customLeading != null ||
        metrics.isNotEmpty ||
        (amountForWords != null && amountForWords! > 0);

    final leadingSection = _CheckoutLeadingSection(
      warningWidget: warningWidget,
      customLeading: customLeading,
      metrics: metrics,
      amountForWords: amountForWords,
      currencyCode: currencyCode,
      itemCount: itemCount,
      itemCountLabel: itemCountLabel,
      unitCount: unitCount,
      unitCountLabel: unitCountLabel,
    );

    final actionsSection = _CheckoutActionsSection(
      isCompact: isCompact,
      hasLeading: hasLeading,
      actionLabel: actionLabel,
      actionIcon: actionIcon,
      isLoading: isLoading,
      isActionEnabled: isActionEnabled,
      onAction: onAction,
      actionWidth: actionWidth,
      secondaryActionLabel: secondaryActionLabel,
      secondaryActionIcon: secondaryActionIcon,
      onSecondaryAction: onSecondaryAction,
      customActions: customActions,
    );

    final bodyContent = !hasLeading
        ? actionsSection
        : isCompact
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [leadingSection, AppSpacing.vSm, actionsSection],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: leadingSection),
              AppSpacing.hMd,
              actionsSection,
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
          border: Border(top: BorderSide(color: colors.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, -7),
            ),
          ],
        ),
        child: maxContentWidth != null
            ? Align(
                alignment: Alignment.center,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth!),
                  child: bodyContent,
                ),
              )
            : bodyContent,
      ),
    );
  }
}

class _CheckoutLeadingSection extends StatelessWidget {
  const _CheckoutLeadingSection({
    this.warningWidget,
    this.customLeading,
    required this.metrics,
    this.amountForWords,
    required this.currencyCode,
    this.itemCount,
    required this.itemCountLabel,
    this.unitCount,
    required this.unitCountLabel,
  });

  final Widget? warningWidget;
  final Widget? customLeading;
  final List<CheckoutMetricData> metrics;
  final double? amountForWords;
  final String currencyCode;
  final int? itemCount;
  final String itemCountLabel;
  final int? unitCount;
  final String unitCountLabel;

  @override
  Widget build(BuildContext context) {
    final showWords = amountForWords != null && amountForWords! > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (warningWidget != null) ...[warningWidget!, AppSpacing.vXs],
        if (customLeading != null)
          customLeading!
        else if (metrics.isNotEmpty) ...[
          _CheckoutMetricsGrid(metrics: metrics),
          if (unitCount != null || itemCount != null) ...[
            AppSpacing.vXs,
            _CheckoutCountsRow(
              unitCount: unitCount,
              unitCountLabel: unitCountLabel,
              itemCount: itemCount,
              itemCountLabel: itemCountLabel,
            ),
          ],
        ],
        if (showWords) ...[
          AppSpacing.vXs,
          CustomAmountToWordsBanner(
            amount: amountForWords!,
            currencyCode: currencyCode,
          ),
        ],
      ],
    );
  }
}

class _CheckoutMetricsGrid extends StatelessWidget {
  const _CheckoutMetricsGrid({required this.metrics});

  final List<CheckoutMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    const chunkSize = 3;
    final chunks = <List<CheckoutMetricData>>[];
    for (var i = 0; i < metrics.length; i += chunkSize) {
      chunks.add(
        metrics.sublist(
          i,
          i + chunkSize > metrics.length ? metrics.length : i + chunkSize,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var c = 0; c < chunks.length; c++) ...[
          if (c > 0) AppSpacing.vXs,
          Row(
            children: [
              for (var i = 0; i < chunks[c].length; i++) ...[
                if (i > 0) AppSpacing.hXs,
                Expanded(child: _CheckoutMetricItem(metric: chunks[c][i])),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _CheckoutCountsRow extends StatelessWidget {
  const _CheckoutCountsRow({
    this.unitCount,
    required this.unitCountLabel,
    this.itemCount,
    required this.itemCountLabel,
  });

  final int? unitCount;
  final String unitCountLabel;
  final int? itemCount;
  final String itemCountLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        if (unitCount != null) ...[
          Icon(Icons.layers_rounded, size: 16.r, color: colors.primary),
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
    );
  }
}

class _CheckoutActionsSection extends StatelessWidget {
  const _CheckoutActionsSection({
    required this.isCompact,
    required this.hasLeading,
    required this.actionLabel,
    this.actionIcon,
    required this.isLoading,
    required this.isActionEnabled,
    this.onAction,
    this.actionWidth,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.customActions,
  });

  final bool isCompact;
  final bool hasLeading;
  final String actionLabel;
  final IconData? actionIcon;
  final bool isLoading;
  final bool isActionEnabled;
  final VoidCallback? onAction;
  final double? actionWidth;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final List<Widget>? customActions;

  @override
  Widget build(BuildContext context) {
    if (customActions != null && customActions!.isNotEmpty) {
      return Row(
        mainAxisSize: isCompact || !hasLeading
            ? MainAxisSize.max
            : MainAxisSize.min,
        children: customActions!,
      );
    }

    final primaryButton = CustomButton(
      text: actionLabel,
      icon: actionIcon,
      width: (isCompact || !hasLeading) ? double.infinity : (actionWidth ?? 190),
      loading: isLoading,
      enabled: isActionEnabled,
      onPressed: isActionEnabled ? onAction : null,
    );

    if (secondaryActionLabel == null) {
      return primaryButton;
    }

    final secondaryButton = CustomButton.outline(
      text: secondaryActionLabel!,
      icon: secondaryActionIcon,
      shape: AppButtonShape.rounded,
      size: AppButtonSize.medium,
      onPressed: isLoading ? null : onSecondaryAction,
    );

    if (isCompact || !hasLeading) {
      return Row(
        children: [
          Expanded(child: secondaryButton),
          AppSpacing.hSm,
          Expanded(
            flex: 2,
            child: CustomButton.primary(
              text: actionLabel,
              icon: actionIcon,
              shape: AppButtonShape.rounded,
              size: AppButtonSize.medium,
              loading: isLoading,
              enabled: isActionEnabled,
              onPressed: isActionEnabled ? onAction : null,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        secondaryButton,
        AppSpacing.hSm,
        primaryButton,
      ],
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.30),
        ),
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
          AppSpacing.vXxs,
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
                AppSpacing.hXxs,
                Text(
                  metric.currency,
                  style: AppTypography.caption.copyWith(
                    color: textColor.withValues(alpha: 0.8),
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
