import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// تنبيه يوضح فصل الطلب الأصلي عن فاتورة الاعتماد النهائية.
class ProcurementRequestInvoiceCallout extends StatelessWidget {
  const ProcurementRequestInvoiceCallout({
    super.key,
    required this.onOpenInvoice,
  });

  final VoidCallback onOpenInvoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.success.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.receipt_long_rounded, color: colors.success, size: 22),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'أُنشئت فاتورة مرتبطة بهذا الطلب. قد تختلف قيمتها وبنودها عن الطلب الأصلي بعد مراجعة الشبكة؛ وتبقى الفاتورة المرجع النهائي للتسوية.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          SizedBox(
            width: double.infinity,
            child: CustomButton.outline(
              text: 'عرض الفاتورة المرتبطة',
              icon: Icons.open_in_new_rounded,
              onPressed: onOpenInvoice,
            ),
          ),
        ],
      ),
    );
  }
}
