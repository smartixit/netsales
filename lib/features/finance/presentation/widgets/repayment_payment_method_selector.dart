import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/enums/repayment_payment_method.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// اختيار بصري سريع وواضح لقناة استلام السداد.
class RepaymentPaymentMethodSelector extends StatelessWidget {
  const RepaymentPaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
    this.enabled = true,
  });

  final RepaymentPaymentMethod selectedMethod;
  final ValueChanged<RepaymentPaymentMethod> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactContentWidth =
            AppBreakpoints.mobileSmallMax - AppSpacing.cardPadding * 2;
        final columns = constraints.maxWidth < compactContentWidth ? 2 : 3;
        final gap = AppSpacing.sm;
        final cardWidth = math
            .min(
              (constraints.maxWidth - gap * (columns - 1)) / columns,
              AppBreakpoints.maxFormWidth / 3,
            )
            .toDouble();

        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.sm,
          children: [
            for (final method in RepaymentPaymentMethod.selectableValues)
              SizedBox(
                width: cardWidth,
                child: _PaymentMethodOption(
                  method: method,
                  selected: selectedMethod == method,
                  enabled: enabled,
                  onTap: () => onChanged(method),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.method,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final RepaymentPaymentMethod method;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  IconData get _icon => switch (method) {
    RepaymentPaymentMethod.cash => Icons.payments_outlined,
    RepaymentPaymentMethod.bank => Icons.account_balance_outlined,
    RepaymentPaymentMethod.wallet => Icons.account_balance_wallet_outlined,
    RepaymentPaymentMethod.unknown => Icons.help_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foregroundColor = enabled
        ? (selected ? colors.primary : colors.onSurface)
        : colors.onSurface.withValues(alpha: 0.38);
    final secondaryColor = enabled
        ? colors.onSurfaceVariant
        : colors.onSurfaceVariant.withValues(alpha: 0.38);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '${method.label}، ${method.supportingLabel}',
      child: ExcludeSemantics(
        child: CustomInteractiveBounce(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: AppMotion.duration(context, AppMotion.normal),
            curve: AppMotion.standard,
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primaryContainer.withValues(alpha: 0.24)
                  : colors.surfaceContainerLow,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(
                color: selected
                    ? colors.primary
                    : colors.outlineVariant.withValues(alpha: 0.45),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected ? AppElevation.level1(context) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: AppSpacing.xxxl,
                      height: AppSpacing.xxxl,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primary.withValues(alpha: 0.12)
                            : colors.surfaceContainerHighest,
                        borderRadius: AppRadius.mdRadius,
                      ),
                      child: Icon(
                        _icon,
                        size: AppSpacing.xl,
                        color: foregroundColor,
                      ),
                    ),
                    AnimatedContainer(
                      duration: AppMotion.duration(context, AppMotion.fast),
                      width: AppSpacing.xl,
                      height: AppSpacing.xl,
                      decoration: BoxDecoration(
                        color: selected ? colors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),
                      child: selected
                          ? Icon(
                              Icons.check_rounded,
                              size: AppSpacing.sm,
                              color: colors.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
                AppSpacing.vSm,
                Text(
                  method.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: foregroundColor,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  method.supportingLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: secondaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
