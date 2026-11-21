import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/widgets/pos_quick_action_card.dart';

/// POS dashboard quick actions, grouped and adapted as one feature section.
class PosQuickActionsSection extends StatelessWidget {
  const PosQuickActionsSection({
    super.key,
    required this.onCreateOrder,
    required this.onOpenInvoices,
  });

  final VoidCallback onCreateOrder;
  final VoidCallback onOpenInvoices;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: colors.primary, size: 20.r),
              AppSpacing.hSm,
              Text(
                'العمليات السريعة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vMd,
        LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < AppBreakpoints.mobileSmallMax;
            final order = PosQuickActionCard(
              icon: Icons.add_shopping_cart_rounded,
              title: 'طلب توريد',
              onTap: onCreateOrder,
            );
            final invoices = PosQuickActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'فواتيري',
              onTap: onOpenInvoices,
            );

            if (compact) {
              return Column(
                children: [
                  order,
                  AppSpacing.vSm,
                  invoices,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: order),
                AppSpacing.hMd,
                Expanded(child: invoices),
              ],
            );
          },
        ),
      ],
    );
  }
}
