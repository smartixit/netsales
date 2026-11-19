import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// إشعار الحوكمة المالية والتسعير المعتمد حصراً من الخادم
class DirectInvoiceFinancialAuthorityNotice extends StatelessWidget {
  const DirectInvoiceFinancialAuthorityNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: colors.primary),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              'الأسعار الرسمية، نسب الخصومات التعاقدية، وإجمالي الفاتورة تُحسب وتُسجل حصرياً عبر خادم النظام.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
