import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// سطر البند الفردي داخل الأكورديون مع تفاصيل الكميات والأوراق والقيمة
class ProcurementOrderCardAccordionItemRow extends StatelessWidget {
  const ProcurementOrderCardAccordionItemRow({super.key, required this.item});

  final RequestItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final package = item.voucherPackage;
    final packageName = package?.packageName ?? 'باقة #${item.packageId}';
    final sheetSize = (package?.packageVoucherCount ?? 0) > 0
        ? package!.packageVoucherCount
        : 1;
    final sheetDescription = VoucherSheetCalculator.describe(
      item.voucherCount,
      sheetSize,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // علامة لون الباقة
        Container(
          width: 4.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: CustomColorPicker.parseHex(
              package?.packageColor,
              fallback: colors.primary,
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        AppSpacing.hSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                packageName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.vXxs,
              Text(
                '${item.voucherCount} كرت ($sheetDescription)',
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.hSm,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                AmountFormatter.formatValue(item.itemTotalAmount),
                style: AppTypography.labelLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (item.itemDiscount > 0)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'خصم: ${AmountFormatter.formatValue(item.itemDiscount)}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
