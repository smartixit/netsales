import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/indicators/custom_amount_to_words_banner.dart';

/// إجمالي الطلب الأصلي كما أرسله POS، وليس إجمالي فاتورة الاعتماد.
class ProcurementOriginalRequestAmountPanel extends StatelessWidget {
  const ProcurementOriginalRequestAmountPanel({
    super.key,
    required this.amount,
  });

  final double amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'قيمة الطلب عند الإرسال',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                AmountFormatter.format(amount.toString()),
                style: AppTypography.titleLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          CustomAmountToWordsBanner(
            amount: amount,
            currencyCode: 'YER',
          ),
        ],
      ),
    );
  }
}
