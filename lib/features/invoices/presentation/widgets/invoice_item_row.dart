import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';

/// سطر عرض بند الفاتورة المالية (Invoice Item Row)
class InvoiceItemRow extends StatelessWidget {
  final InvoiceItemEntity item;
  final int index;

  const InvoiceItemRow({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: index.isEven
            ? colors.surfaceContainerLowest
            : colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        children: [
          // اسم الباقة ومعرّفها
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.packageName ?? 'باقة #${item.packageId}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'سعر الكرت: ${AmountFormatter.format(item.voucherPrice.toString())}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // الكمية
          Expanded(
            flex: 2,
            child: Text(
              '${item.voucherCount} كرت',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // الخصم
          Expanded(
            flex: 2,
            child: Text(
              item.itemDiscount > 0
                  ? AmountFormatter.format(item.itemDiscount.toString())
                  : '-',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: item.itemDiscount > 0
                    ? colors.error
                    : colors.onSurfaceVariant,
              ),
            ),
          ),

          // الإجمالي
          Expanded(
            flex: 3,
            child: Text(
              AmountFormatter.format(item.itemTotalAmount.toString()),
              textAlign: TextAlign.end,
              style: AppTypography.titleSmall.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
